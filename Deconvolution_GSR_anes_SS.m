clear ;close all;clc
excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
startInd = 1;
freqLow = 0.04;
calMax = 4;
hbMax = 0.5;
hrfMax = 0.02;
nVx = 128;
nVy = 128;
samplingRate =25;
freq = 10;
t = (-3*freq:(30-3)*freq-1)/freq;
load('AtlasandIsbrain.mat','AtlasSeeds_Big')
mask_SS = (AtlasSeeds_Big==5) + (AtlasSeeds_Big==15);


for excelRow = [202 195 204 230 234 240]
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    if ~exist(strcat(saveDir,'\SS_HRF'),'dir')
        mkdir(strcat(saveDir,'\SS_HRF'))
    end
    for n = 1:3
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        load(fullfile(saveDir,processedName),'xform_datahb','xform_jrgeco1aCorr')
        maskDir = strcat('L:\RGECO\Kenny\', recDate, '\');
        if exist(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'file')
            load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'xform_isbrain');
            
        else
            maskDir = saveDir;
            maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
            load(fullfile(maskDir,maskName),'affineMarkers','xform_isbrain')
        end
        HbT = squeeze(xform_datahb(:,:,1,:)+xform_datahb(:,:,2,:))*10^6;% convert to muM
        clear xform_datahb
        Calcium = squeeze(xform_jrgeco1aCorr)*100; % convert to DeltaF/F%
        clear xform_jrgeco1aCorr
        
        % Filter 0.02-2Hz, downsample to 10 Hz
        HbT =  filterData(HbT,freqLow,2,samplingRate);
        Calcium = filterData(Calcium,freqLow,2,samplingRate);
        
        HbT = resample(HbT,freq,samplingRate,'Dimension',3); %resample to 10 Hz
        Calcium = resample(Calcium,freq,samplingRate,'Dimension',3); %resample to 10 Hz
        
        % Reshape into 30 seconds
        HbT=reshape(HbT,128,128,30*freq,[]);
        Calcium=reshape(Calcium,128,128,30*freq,[]);
        
        % GSR
        HbT = gsr(HbT,xform_isbrain);
        Calcium = gsr(Calcium,xform_isbrain);
        
        r_GSR_SS_HRF = zeros(1,11-startInd);
        HRF_GSR_SS = zeros(11-startInd,length(Calcium));
        jj = 1;
        for ii = startInd:10
            
            % reshape
            HbT_SS = reshape(HbT(:,:,:,ii),128*128,[]);
            Calcium_SS = reshape(Calcium(:,:,:,ii),128*128,[]);
            
            % SS only
            HbT_SS = mean(HbT_SS(mask_SS(:),:));
            Calcium_SS = mean(Calcium_SS(mask_SS(:),:));
            
            % starting point to be zero
            HbT_SS = tukeywin(length(HbT_SS),.3).*squeeze(HbT_SS');
            Calcium_SS = tukeywin(length(Calcium_SS),.3).*squeeze(Calcium_SS');
            
            % HRF
            X = convmtx(Calcium_SS,length(Calcium_SS));% why calculating convolution matrix for input? 599*300?
            %X = X(151:450,:);
            X = X(1:length(Calcium_SS),1:length(Calcium_SS));% make it square?
            [~,S,~]=svd(X);
            lambda = 0.01;
            h_region_SS = (X'*S*X+(S(1,1).^3)*lambda*eye(length(Calcium_SS))) \ (X'*S*[zeros(3*freq,1); HbT_SS(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
            HRF_GSR_SS(jj,:) = h_region_SS;
            
            % Predicted HbT
            HbT_SS_pred = conv(Calcium_SS,h_region_SS);
            HbT_SS_pred = HbT_SS_pred(1:(length(HbT_SS)+3*freq));
            r_region_SS = corr(HbT_SS,HbT_SS_pred(3*freq+1:end));
            r_GSR_SS_HRF(jj) = r_region_SS;
            
            jj = jj+1;
            figure('units','normalized','outerposition',[0 0 1 1])
            subplot(2,2,1)
            plot((1:300)/10,HbT_SS,'k')
            ylabel('\Delta\muM')
            ylim([-hbMax hbMax])
            hold on
            yyaxis right
            plot((1:300)/10,Calcium_SS,'m')
            legend('HbT','jRGECO1a')
            ylim([-calMax calMax])
            ylabel('\DeltaF/F%')
            xlabel('Time(s)')
            title('Time Course for SS Cortex')
            
            subplot(2,2,2)
            plot(t,h_region_SS)
            xlim([-3 10])
            ylim([-hrfMax hrfMax])
            ylabel('\Delta\muM/\DeltaF/F%')
            xlabel('Time(s)')
            title('HRF for SS Cortex')
            
            subplot(2,2,3)
            plot((1:300)/10,HbT_SS,'k')
            hold on
            plot((1:300)/10,HbT_SS_pred(3*freq+1:3*freq+length(HbT_SS)),'Color',[0 0.5 0])
            xlabel('Time(s)')
            ylabel('\Delta\muM')
            legend('Actual HbT','Predicted HbT')
            title(strcat('r = ',num2str(r_region_SS)))
            ylim([-hbMax hbMax])
            
            sgtitle(strcat('HRF for SS Region, ',num2str(freqLow),'-2Hz, GSR, lambda = ',num2str(lambda),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
            saveName =  fullfile(saveDir,'SS_HRF', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-SS-GSR-HRF'));
            saveas(gcf,strcat(saveName,'.fig'))
            saveas(gcf,strcat(saveName,'.png'))
        end
        close all
        save(fullfile(saveDir,'SS_HRF', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_SS_HRF','.mat')),'r_GSR_SS_HRF','HRF_GSR_SS')
    end
end

%%
totalNum = 0;
HRF_GSR_SS_0p6 = [];
miceName = [];
for excelRow = [202 195 204 230 234 240]
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = strcat(miceName,'-',mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    if ~exist(strcat(saveDir,'\SS_HRF'),'dir')
        mkdir(strcat(saveDir,'\SS_HRF'))
    end
    for n = 1:3
        load(fullfile(saveDir,'SS_HRF', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_SS_HRF','.mat')),'r_GSR_SS_HRF','HRF_GSR_SS')
        totalNum = totalNum + length(r_GSR_SS_HRF);
        HRF_GSR_SS_0p6 = cat(1,HRF_GSR_SS_0p6,HRF_GSR_SS(r_GSR_SS_HRF>0.6,:));
    end
end
qualifiedNum = size(HRF_GSR_SS_0p6,1);
HRF_GSR_SS_0p6_median = median(HRF_GSR_SS_0p6);
save(strcat('L:\RGECO\cat\SS_HRF\',recDate,miceName,'-SS_HRF.mat'),'HRF_GSR_SS_0p6','qualifiedNum','totalNum');

[pks,locs,w,p] = findpeaks(HRF_GSR_SS_0p6_median,t,'MinPeakProminence',0.01);

figure
plot_distribution_prctile(t,HRF_GSR_SS_0p6)
legend('25%-75%')
xlim([-3 10])
xlabel('Time(s)')
grid on
title(strcat(num2str(qualifiedNum),'/',num2str(totalNum),' has r>0.6, Median: T=',num2str(locs),'s, W=',num2str(w),'s, A=',num2str(pks)))


%%
load('191030-R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-SS_HRF.mat')
HRF_GSR_SS_0p6_awake =HRF_GSR_SS_0p6;
qualifiedNum_awake = qualifiedNum;
totalNum_awake = totalNum;
HRF_GSR_SS_0p6_median_awake = median(HRF_GSR_SS_0p6_awake);
[pks_awake,locs_awake,w_awake,p_awake] = findpeaks(HRF_GSR_SS_0p6_median_awake,t,'MinPeakProminence',0.01);

load('191030-R5M2285-anes-R5M2286-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-SS_HRF.mat')
HRF_GSR_SS_0p6_anes =HRF_GSR_SS_0p6;
qualifiedNum_anes = qualifiedNum;
totalNum_anes = totalNum;
HRF_GSR_SS_0p6_median_anes = median(HRF_GSR_SS_0p6_anes);
[pks_anes,locs_anes,w_anes,p_anes] = findpeaks(HRF_GSR_SS_0p6_median_anes,t,'MinPeakProminence',0.01);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,2,1)
plot_distribution_prctile(t,HRF_GSR_SS_0p6_awake,'Color',[1 0 0])
legend('25%-75%')
xlim([-3 7])
xlabel('Time(s)')
grid on
title(strcat('For awake:  ',num2str(qualifiedNum_awake),'/',num2str(totalNum_awake),' has r>0.6, Median: T=',num2str(locs_awake,'%4.2f'),'s, W=',num2str(w_awake,'%4.2f'),'s, A=',num2str(pks_awake,'%4.2f')))

subplot(2,2,2)
plot_distribution_prctile(t,HRF_GSR_SS_0p6_anes,'Color',[0 0 1])
legend('25%-75%')
xlim([-3 7])
xlabel('Time(s)')
grid on
title(strcat('For awake:  ',num2str(qualifiedNum_anes),'/',num2str(totalNum_anes),' has r>0.6, Median: T=',num2str(locs_anes,'%4.2f'),'s, W=',num2str(w_anes,'%4.2f'),'s, A=',num2str(pks_anes,'%4.2f')))

subplot(2,2,3)
plot_distribution_prctile(t,HRF_GSR_SS_0p6_awake,'Color',[1 0 0])
hold on
plot_distribution_prctile(t,HRF_GSR_SS_0p6_anes,'Color',[0 0 1])
xlim([-3 7])
xlabel('Time(s)')
grid on
title('HRF, Awake vs. Anesthetized')
sgtitle('HRF for Somatosensory after GSR')
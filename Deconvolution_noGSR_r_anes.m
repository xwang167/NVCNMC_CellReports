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
load('AtlasandIsbrain.mat','AtlasSeeds')
mask_barrel = AtlasSeeds==9;


for excelRow = [202 195 204 230 234 240]
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    if ~exist(strcat(saveDir,'\Barrel_HRF'),'dir')
        mkdir(strcat(saveDir,'\Barrel_HRF'))
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
        
        r_NoGSR_Barrel_HRF = zeros(1,11-startInd);
        HRF_NoGSR_Barrel = zeros(11-startInd,length(Calcium));
        jj = 1;
        for ii = startInd:10
            
            % reshape
            HbT_barrel = reshape(HbT(:,:,:,ii),128*128,[]);
            Calcium_barrel = reshape(Calcium(:,:,:,ii),128*128,[]);
            
            % Barrel only
            HbT_barrel = mean(HbT_barrel(mask_barrel(:),:));
            Calcium_barrel = mean(Calcium_barrel(mask_barrel(:),:));
            
            % starting point to be zero
            HbT_barrel = tukeywin(length(HbT_barrel),.3).*squeeze(HbT_barrel');
            Calcium_barrel = tukeywin(length(Calcium_barrel),.3).*squeeze(Calcium_barrel');
            
            % HRF
            X = convmtx(Calcium_barrel,length(Calcium_barrel));% why calculating convolution matrix for input? 599*300?
            %X = X(151:450,:);
            X = X(1:length(Calcium_barrel),1:length(Calcium_barrel));% make it square?
            [~,S,~]=svd(X);
            lambda = 0.01;
            h_region_barrel = (X'*S*X+(S(1,1).^3)*lambda*eye(length(Calcium_barrel))) \ (X'*S*[zeros(3*freq,1); HbT_barrel(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
            HRF_NoGSR_Barrel(jj,:) = h_region_barrel;
            
            % Predicted HbT
            HbT_barrel_pred = conv(Calcium_barrel,h_region_barrel);
            HbT_barrel_pred = HbT_barrel_pred(1:(length(HbT_barrel)+3*freq));
            r_region_barrel = corr(HbT_barrel,HbT_barrel_pred(3*freq+1:end));
            r_NoGSR_Barrel_HRF(jj) = r_region_barrel;
            
            jj = jj+1;
            figure('units','normalized','outerposition',[0 0 1 1])
            subplot(2,2,1)
            plot((1:300)/10,HbT_barrel,'k')
            ylabel('\Delta\muM')
            ylim([-hbMax hbMax])
            hold on
            yyaxis right
            plot((1:300)/10,Calcium_barrel,'m')
            legend('HbT','jRGECO1a')
            ylim([-calMax calMax])
            ylabel('\DeltaF/F%')
            xlabel('Time(s)')
            title('Time Course for Barrel Cortex')
            
            subplot(2,2,2)
            plot(t,h_region_barrel)
            xlim([-3 10])
            ylim([-hrfMax hrfMax])
            ylabel('\Delta\muM/\DeltaF/F%')
            xlabel('Time(s)')
            title('HRF for Barrel Cortex')
            
            subplot(2,2,3)
            plot((1:300)/10,HbT_barrel,'k')
            hold on
            plot((1:300)/10,HbT_barrel_pred(3*freq+1:3*freq+length(HbT_barrel)),'Color',[0 0.5 0])
            xlabel('Time(s)')
            ylabel('\Delta\muM')
            legend('Actual HbT','Predicted HbT')
            title(strcat('r = ',num2str(r_region_barrel)))
            ylim([-hbMax hbMax])
            
            sgtitle(strcat('HRF for Barrel Region, ',num2str(freqLow),'-2Hz, NoGSR, lambda = ',num2str(lambda),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
            saveName =  fullfile(saveDir,'Barrel_HRF', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-Barrel-NoGSR-HRF'));
            saveas(gcf,strcat(saveName,'.fig'))
            saveas(gcf,strcat(saveName,'.png'))
        end
        close all
        save(fullfile(saveDir,'Barrel_HRF', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_Barrel_HRF','.mat')),'r_NoGSR_Barrel_HRF','HRF_NoGSR_Barrel','-append')
    end
end

%%
totalNum_NoGSR = 0;
HRF_NoGSR_Barrel_0p6 = [];
miceName = [];
for excelRow = [202 195 204 230 234 240]
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = strcat(miceName,'-',mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    if ~exist(strcat(saveDir,'\Barrel_HRF'),'dir')
        mkdir(strcat(saveDir,'\Barrel_HRF'))
    end
    for n = 1:3
        load(fullfile(saveDir,'Barrel_HRF', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_Barrel_HRF','.mat')),'r_NoGSR_Barrel_HRF','HRF_NoGSR_Barrel')
        totalNum_NoGSR = totalNum_NoGSR + length(r_NoGSR_Barrel_HRF);
        HRF_NoGSR_Barrel_0p6 = cat(1,HRF_NoGSR_Barrel_0p6,HRF_NoGSR_Barrel(r_NoGSR_Barrel_HRF>0.6,:));
    end
end
qualifiedNum_NoGSR = size(HRF_NoGSR_Barrel_0p6,1);
HRF_NoGSR_Barrel_0p6_median = median(HRF_NoGSR_Barrel_0p6);
save(strcat('L:\RGECO\cat\Barrel_HRF\',recDate,miceName,'-Barrel_HRF.mat'),'HRF_NoGSR_Barrel_0p6','qualifiedNum_NoGSR','totalNum_NoGSR','-append');

[pks,locs,w,p] = findpeaks(HRF_NoGSR_Barrel_0p6_median,t,'MinPeakProminence',0.005);

figure
plot_distribution_prctile(t,HRF_NoGSR_Barrel_0p6)
legend('25%-75%')
xlim([-3 10])
xlabel('Time(s)')
grid on
title(strcat(num2str(qualifiedNum),'/',num2str(totalNum),' has r>0.6, Median: T=',num2str(locs),'s, W=',num2str(w),'s, A=',num2str(pks)))


%%
load('191030-R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-Barrel_HRF.mat')
HRF_NoGSR_Barrel_0p6_awake =HRF_NoGSR_Barrel_0p6;
qualifiedNum_NoGSR_awake = qualifiedNum_NoGSR;
totalNum_NoGSR_awake = totalNum_NoGSR;
HRF_NoGSR_Barrel_0p6_median_awake = median(HRF_NoGSR_Barrel_0p6_awake);
[pks_awake,locs_awake,w_awake,p_awake] = findpeaks(HRF_NoGSR_Barrel_0p6_median_awake,t,'MinPeakProminence',0.01);

load('191030-R5M2285-anes-R5M2286-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-Barrel_HRF.mat')
HRF_NoGSR_Barrel_0p6_anes =HRF_NoGSR_Barrel_0p6;
qualifiedNum_NoGSR_anes = qualifiedNum_NoGSR;
totalNum_NoGSR_anes = totalNum_NoGSR;
HRF_NoGSR_Barrel_0p6_median_anes = median(HRF_NoGSR_Barrel_0p6_anes);
[pks_anes,locs_anes,w_anes,p_anes] = findpeaks(HRF_NoGSR_Barrel_0p6_median_anes,t,'MinPeakProminence',0.005);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,2,1)
plot_distribution_prctile(t,HRF_NoGSR_Barrel_0p6_awake,'Color',[1 0 0])
legend('25%-75%')
xlim([-3 7])
xlabel('Time(s)')
grid on
title(strcat('For awake:  ',num2str(qualifiedNum_NoGSR_awake),'/',num2str(totalNum_NoGSR_awake),' has r>0.6, Median: T=',num2str(locs_awake,'%4.2f'),'s, W=',num2str(w_awake,'%4.2f'),'s, A=',num2str(pks_awake,'%4.2f')))

subplot(2,2,2)
plot_distribution_prctile(t,HRF_NoGSR_Barrel_0p6_anes,'Color',[0 0 1])
legend('25%-75%')
xlim([-3 7])
xlabel('Time(s)')
grid on
title(strcat('For anesthetized:  ',num2str(qualifiedNum_NoGSR_anes),'/',num2str(totalNum_NoGSR_anes),' has r>0.6, Median: T=',num2str(locs_anes,'%4.2f'),'s, W=',num2str(w_anes,'%4.2f'),'s, A=',num2str(pks_anes,'%4.2f')))

subplot(2,2,3)
plot_distribution_prctile(t,HRF_NoGSR_Barrel_0p6_awake,'Color',[1 0 0])
hold on
plot_distribution_prctile(t,HRF_NoGSR_Barrel_0p6_anes,'Color',[0 0 1])
xlim([-3 7])
xlabel('Time(s)')
grid on
title('HRF, Awake vs. Anesthetized')
sgtitle('HRF for Left Barrel Cortex, NoGSR')
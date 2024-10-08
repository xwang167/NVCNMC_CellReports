clear ;close all;clc
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
startInd = 2;
freqLow = 0.02;
calMax = 8;
hbMax  = 1.5;
FADMax = 1;
hrfMax = 0.2;
mrfMax = 0.08;
samplingRate =25;
freq         = 10;
freq_new     = 250;
t_kernel = 30;
t_HRF = (-3*freq        :(t_kernel-3)*freq        -1)/freq        ;
t_MRF = (-3*samplingRate:(t_kernel-3)*samplingRate-1)/samplingRate;
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\noVasculatureMask.mat",'mask_new')
load('AtlasandIsbrain.mat','AtlasSeedsFilled')
AtlasSeedsFilled(AtlasSeedsFilled==0) = nan;
AtlasSeedsFilled(:,65:128) = AtlasSeedsFilled(:,65:128)+20;

% Mask for different regions
mask_M2_L = AtlasSeedsFilled==4;
mask_M1_L = AtlasSeedsFilled==5;
mask_SS_L = AtlasSeedsFilled==6 | AtlasSeedsFilled==7 | AtlasSeedsFilled==8 | AtlasSeedsFilled==9 | AtlasSeedsFilled==10 | AtlasSeedsFilled==11;
mask_P_L  = AtlasSeedsFilled==13 | AtlasSeedsFilled==14 | AtlasSeedsFilled==15;
mask_V1_L = AtlasSeedsFilled==17;
mask_V2_L = AtlasSeedsFilled==16|AtlasSeedsFilled==18;

mask_M2_R = AtlasSeedsFilled==24;
mask_M1_R = AtlasSeedsFilled==25;
mask_SS_R = AtlasSeedsFilled==26 | AtlasSeedsFilled==27 | AtlasSeedsFilled==28 | AtlasSeedsFilled==29 | AtlasSeedsFilled==30 | AtlasSeedsFilled==31;
mask_P_R  = AtlasSeedsFilled==33 | AtlasSeedsFilled==34 | AtlasSeedsFilled==35;
mask_V1_R = AtlasSeedsFilled==37;
mask_V2_R = AtlasSeedsFilled==36|AtlasSeedsFilled==38;


for excelRow = [181 183 185 228 232 236 202 195 204 230 234 240]

    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    if ~exist(strcat(saveDir,'\Barrel_HRF'),'dir')
        mkdir(strcat(saveDir,'\Barrel_HRF'))
    end
    for n = 1:3
        disp(strcat(mouseName,', run#',num2str(n)))
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        load(fullfile(saveDir,processedName),'xform_datahb','xform_FADCorr','xform_jrgeco1aCorr','xform_isbrain')
        HbT = squeeze(xform_datahb(:,:,1,:)+xform_datahb(:,:,2,:))*10^6;% convert to muM
        clear xform_datahb
        FAD = xform_FADCorr*100;
        clear xform_FADCorr
        Calcium = squeeze(xform_jrgeco1aCorr)*100; % convert to DeltaF/F%
        clear xform_jrgeco1aCorr
        % Pad one more frame to full 10 mins
        HbT    (:,:,end+1) = HbT    (:,:,end);
        FAD    (:,:,end+1) = FAD    (:,:,end);
        Calcium(:,:,end+1) = Calcium(:,:,end);
        % Filter 0.02-2Hz, downsample to 10 Hz
        HbT     = filterData(HbT,   freqLow,2,samplingRate);
        FAD     = filterData(FAD,   freqLow,2,samplingRate);
        Calcium = filterData(Calcium,freqLow,2,samplingRate);
        
        % resample
        HbT_resample = resample(HbT,freq,samplingRate,'Dimension',3); %resample to 10 Hz
        Calcium_resample = resample(Calcium,freq,samplingRate,'Dimension',3); %resample to 10 Hz

        % Reshape into 30 seconds
        HbT_resample=reshape(HbT_resample,128,128,t_kernel*freq,[]);
        Calcium_resample=reshape(Calcium_resample,128,128,t_kernel*freq,[]);

        FAD     = reshape(FAD    ,128,128,t_kernel*samplingRate,[]);
        Calcium = reshape(Calcium,128,128,t_kernel*samplingRate,[]);

        % Regions within brain without vasculature
        mask_M2_L = logical(mask_M2_L.*mask_new.*xform_isbrain);
        mask_M1_L = logical(mask_M1_L.*mask_new.*xform_isbrain);
        mask_SS_L = logical(mask_SS_L.*mask_new.*xform_isbrain);
        mask_P_L  = logical(mask_P_L .*mask_new.*xform_isbrain);
        mask_V1_L = logical(mask_V1_L.*mask_new.*xform_isbrain);
        mask_V2_L = logical(mask_V2_L.*mask_new.*xform_isbrain);

        mask_M2_R = logical(mask_M2_R.*mask_new.*xform_isbrain);
        mask_M1_R = logical(mask_M1_R.*mask_new.*xform_isbrain);
        mask_SS_R = logical(mask_SS_R.*mask_new.*xform_isbrain);
        mask_P_R  = logical(mask_P_R .*mask_new.*xform_isbrain);
        mask_V1_R = logical(mask_V1_R.*mask_new.*xform_isbrain);
        mask_V2_R = logical(mask_V2_R.*mask_new.*xform_isbrain);

        % Initialize HRF
        r_HRF_M2_L = zeros(1,21-startInd);
        r_HRF_M1_L = zeros(1,21-startInd);
        r_HRF_SS_L = zeros(1,21-startInd);
        r_HRF_P_L  = zeros(1,21-startInd);
        r_HRF_V1_L = zeros(1,21-startInd);
        r_HRF_V2_L = zeros(1,21-startInd);

        r_HRF_M2_R = zeros(1,21-startInd);
        r_HRF_M1_R = zeros(1,21-startInd);
        r_HRF_SS_R = zeros(1,21-startInd);
        r_HRF_P_R  = zeros(1,21-startInd);
        r_HRF_V1_R = zeros(1,21-startInd);
        r_HRF_V2_R = zeros(1,21-startInd);

        HRF_M2_L = zeros(21-startInd,freq_new*t_kernel);
        HRF_M1_L = zeros(21-startInd,freq_new*t_kernel);
        HRF_SS_L = zeros(21-startInd,freq_new*t_kernel);
        HRF_P_L  = zeros(21-startInd,freq_new*t_kernel);
        HRF_V1_L = zeros(21-startInd,freq_new*t_kernel);
        HRF_V2_L = zeros(21-startInd,freq_new*t_kernel);

        HRF_M2_R = zeros(21-startInd,freq_new*t_kernel);
        HRF_M1_R = zeros(21-startInd,freq_new*t_kernel);
        HRF_SS_R = zeros(21-startInd,freq_new*t_kernel);
        HRF_P_R  = zeros(21-startInd,freq_new*t_kernel);
        HRF_V1_R = zeros(21-startInd,freq_new*t_kernel);
        HRF_V2_R = zeros(21-startInd,freq_new*t_kernel);
        
        % Initialize MRF
        r_MRF_M2_L = zeros(1,21-startInd);
        r_MRF_M1_L = zeros(1,21-startInd);
        r_MRF_SS_L = zeros(1,21-startInd);
        r_MRF_P_L  = zeros(1,21-startInd);
        r_MRF_V1_L = zeros(1,21-startInd);
        r_MRF_V2_L = zeros(1,21-startInd);

        r_MRF_M2_R = zeros(1,21-startInd);
        r_MRF_M1_R = zeros(1,21-startInd);
        r_MRF_SS_R = zeros(1,21-startInd);
        r_MRF_P_R  = zeros(1,21-startInd);
        r_MRF_V1_R = zeros(1,21-startInd);
        r_MRF_V2_R = zeros(1,21-startInd);

        MRF_M2_L = zeros(21-startInd,freq_new*t_kernel);
        MRF_M1_L = zeros(21-startInd,freq_new*t_kernel);
        MRF_SS_L = zeros(21-startInd,freq_new*t_kernel);
        MRF_P_L  = zeros(21-startInd,freq_new*t_kernel);
        MRF_V1_L = zeros(21-startInd,freq_new*t_kernel);
        MRF_V2_L = zeros(21-startInd,freq_new*t_kernel);

        MRF_M2_R = zeros(21-startInd,freq_new*t_kernel);
        MRF_M1_R = zeros(21-startInd,freq_new*t_kernel);
        MRF_SS_R = zeros(21-startInd,freq_new*t_kernel);
        MRF_P_R  = zeros(21-startInd,freq_new*t_kernel);
        MRF_V1_R = zeros(21-startInd,freq_new*t_kernel);
        MRF_V2_R = zeros(21-startInd,freq_new*t_kernel);
        jj = 1;
        for ii = startInd:20

            % reshape for each window
            HbT_resample_temp     = reshape(HbT_resample    (:,:,:,ii),128*128,[]);
            Calcium_resample_temp = reshape(Calcium_resample(:,:,:,ii),128*128,[]);

            FAD_temp     = reshape(FAD    (:,:,:,ii),128*128,[]);
            Calcium_temp = reshape(Calcium(:,:,:,ii),128*128,[]);
            %% Calculate and visualize HRF
            [HRF_M2_L(jj,:),r_HRF_M2_L(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_M2_L,freq,freq_new,freqLow,'M2 L',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_M1_L(jj,:),r_HRF_M1_L(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_M1_L,freq,freq_new,freqLow,'M1 L',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_SS_L(jj,:),r_HRF_SS_L(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_SS_L,freq,freq_new,freqLow,'SS L',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_P_L(jj,:) ,r_HRF_P_L(jj) ] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_P_L ,freq,freq_new,freqLow,'P L' ,hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_V1_L(jj,:),r_HRF_V1_L(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_V1_L,freq,freq_new,freqLow,'V1 L',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_V2_L(jj,:),r_HRF_V2_L(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_V2_L,freq,freq_new,freqLow,'V2 L',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);

            [HRF_M2_R(jj,:),r_HRF_M2_R(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_M2_R,freq,freq_new,freqLow,'M2 R',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_M1_R(jj,:),r_HRF_M1_R(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_M1_R,freq,freq_new,freqLow,'M1 R',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_SS_R(jj,:),r_HRF_SS_R(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_SS_R,freq,freq_new,freqLow,'SS R',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_P_R(jj,:) ,r_HRF_P_R(jj) ] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_P_R ,freq,freq_new,freqLow,'P R' ,hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_V1_R(jj,:),r_HRF_V1_R(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_V1_R,freq,freq_new,freqLow,'V1 R',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [HRF_V2_R(jj,:),r_HRF_V2_R(jj)] = calcVisHRF(HbT_resample_temp,Calcium_resample_temp,mask_V2_R,freq,freq_new,freqLow,'V2 R',hbMax,calMax,hrfMax,t_HRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            
            %% Calculate and visualize MRF
            [MRF_M2_L(jj,:),r_MRF_M2_L(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_M2_L,samplingRate,freq_new,freqLow,'M2 L',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_M1_L(jj,:),r_MRF_M1_L(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_M1_L,samplingRate,freq_new,freqLow,'M1 L',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_SS_L(jj,:),r_MRF_SS_L(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_SS_L,samplingRate,freq_new,freqLow,'SS L',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_P_L(jj,:) ,r_MRF_P_L(jj) ] = calcVisMRF(FAD_temp,Calcium_temp,mask_P_L ,samplingRate,freq_new,freqLow,'P L' ,FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_V1_L(jj,:),r_MRF_V1_L(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_V1_L,samplingRate,freq_new,freqLow,'V1 L',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_V2_L(jj,:),r_MRF_V2_L(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_V2_L,samplingRate,freq_new,freqLow,'V2 L',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);

            [MRF_M2_R(jj,:),r_MRF_M2_R(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_M2_R,samplingRate,freq_new,freqLow,'M2 R',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_M1_R(jj,:),r_MRF_M1_R(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_M1_R,samplingRate,freq_new,freqLow,'M1 R',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_SS_R(jj,:),r_MRF_SS_R(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_SS_R,samplingRate,freq_new,freqLow,'SS R',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_P_R(jj,:) ,r_MRF_P_R(jj) ] = calcVisMRF(FAD_temp,Calcium_temp,mask_P_R ,samplingRate,freq_new,freqLow,'P R' ,FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_V1_R(jj,:),r_MRF_V1_R(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_V1_R,samplingRate,freq_new,freqLow,'V1 R',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);
            [MRF_V2_R(jj,:),r_MRF_V2_R(jj)] = calcVisMRF(FAD_temp,Calcium_temp,mask_V2_R,samplingRate,freq_new,freqLow,'V2 R',FADMax,calMax,mrfMax,t_MRF,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType);

            jj = jj+1;
        end
        clear HbT FAD Calcium
        % save HRF
        save(fullfile(saveDir,'HRF_Regions', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'HRF_Regions','.mat')),...
            'HRF_M2_L','HRF_M1_L','HRF_SS_L','HRF_P_L','HRF_V1_L','HRF_V2_L',...
            'HRF_M2_R','HRF_M1_R','HRF_SS_R','HRF_P_R','HRF_V1_R','HRF_V2_R',...
            'r_HRF_M2_L','r_HRF_M1_L','r_HRF_SS_L','r_HRF_P_L','r_HRF_V1_L','r_HRF_V2_L',...
            'r_HRF_M2_R','r_HRF_M1_R','r_HRF_SS_R','r_HRF_P_R','r_HRF_V1_R','r_HRF_V2_R')

        % save MRF
        save(fullfile(saveDir,'MRF_Regions', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'MRF_Regions','.mat')),...
            'MRF_M2_L','MRF_M1_L','MRF_SS_L','MRF_P_L','MRF_V1_L','MRF_V2_L',...
            'MRF_M2_R','MRF_M1_R','MRF_SS_R','MRF_P_R','MRF_V1_R','MRF_V2_R',...
            'r_MRF_M2_L','r_MRF_M1_L','r_MRF_SS_L','r_MRF_P_L','r_MRF_V1_L','r_MRF_V2_L',...
            'r_MRF_M2_R','r_MRF_M1_R','r_MRF_SS_R','r_MRF_P_R','r_MRF_V1_R','r_MRF_V2_R')
    end
end


function [h,r] = calcVisHRF(HbT_temp,Calcium_temp,mask,freq,freq_new,freqLow,regionName,hbMax,calMax,hrfMax,t,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType)
% Average the signal for each region
HbT     = mean(HbT_temp    (mask(:),:));
Calcium = mean(Calcium_temp(mask(:),:));

% starting point to be zero
HbT     = tukeywin(length(HbT)    ,.3).*squeeze(HbT'    );
Calcium = tukeywin(length(Calcium),.3).*squeeze(Calcium');

% HRF
X = convmtx(Calcium,length(Calcium));

%X = X(151:450,:);

% make it square
X = X(1:length(Calcium),1:length(Calcium));
[~,S,~]=svd(X);
lambda = 0.01;
h = (X'*S*X+(S(1,1).^2)*lambda*eye(length(Calcium))) \ (X'*S*[zeros(3*freq,1); HbT(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
% Predicted HbT
HbT_pred = conv(Calcium,h);
HbT_pred = HbT_pred(1:(length(HbT)+3*freq));
r = corr(HbT,HbT_pred(3*freq+1:end));
figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,2,1)
imagesc(mask)
axis image off
title(regionName)

subplot(2,2,2)
plot((1:t_kernel*freq)/freq,HbT    ,'k')
ylabel('\Delta\muM')
ylim([-hbMax hbMax])
hold on
yyaxis right
plot((1:t_kernel*freq)/freq,Calcium,'m')
legend('HbT','jRGECO1a')
ylim([-calMax calMax])
ylabel('\DeltaF/F%')
xlabel('Time(s)')
title(strcat('Time Course for',{' '},regionName))

subplot(2,2,3)
plot(t,h)
xlim([-3 10])
ylim([-hrfMax hrfMax])
ylabel('\Delta\muM/\DeltaF/F%')
xlabel('Time(s)')
title(strcat('HRF for',{' '},regionName))

subplot(2,2,4)
plot((1:t_kernel*freq)/freq,HbT,'k')
hold on
plot((1:t_kernel*freq)/freq,HbT_pred(3*freq+1:3*freq+length(HbT)),'Color',[0 0.5 0])
xlabel('Time(s)')
ylabel('\Delta\muM')
legend('Actual HbT','Predicted HbT')
title(strcat('r = ',num2str(r)))
ylim([-hbMax hbMax])

sgtitle(strcat('HRF for Region',{' '},regionName,',',{' '},num2str(freqLow),'-2Hz, no GSR, lambda = ',num2str(lambda),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
if ~exist(fullfile(saveDir,'HRF_Regions'))
    mkdir(fullfile(saveDir,'HRF_Regions'))
end
saveName =  fullfile(saveDir,'HRF_Regions', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-',regionName,'-NoGSR-HRF'));
saveas(gcf,strcat(saveName,'.fig'))
saveas(gcf,strcat(saveName,'.png'))
close all
h = resample(h,freq_new,freq);
end

function  [h,r] = calcVisMRF(FAD_temp,Calcium_temp,mask,samplingRate,freq_new,freqLow,regionName,FADMax,calMax,mrfMax,t,t_kernel,mouseName,n,ii,saveDir,recDate,sessionType)
% Average the signal for each region
FAD     = mean(FAD_temp    (mask(:),:));
Calcium = mean(Calcium_temp(mask(:),:));

% starting point to be zero
FAD     = tukeywin(length(FAD)    ,.3).*squeeze(FAD'    );
Calcium = tukeywin(length(Calcium),.3).*squeeze(Calcium');

% HRF
X = convmtx(Calcium,length(Calcium));

%X = X(151:450,:);

% make it square
X = X(1:length(Calcium),1:length(Calcium));
[~,S,~]=svd(X);
lambda = 5e-7;
h = (X'*S*X+(S(1,1).^2)*lambda*eye(length(Calcium))) \ (X'*S*[zeros(3*samplingRate,1); FAD(1:end-3*samplingRate)]);% why add 3s of zeros? Do we need to shift it?
% Predicted HbT
FAD_pred = conv(Calcium,h);
FAD_pred = FAD_pred(1:(length(FAD)+3*samplingRate));
r = corr(FAD,FAD_pred(3*samplingRate+1:end));
figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,2,1)
imagesc(mask)
axis image off
title(regionName)

subplot(2,2,2)
plot((1:t_kernel*samplingRate)/samplingRate,FAD    ,'Color',[0 0.5 0])
ylabel('FAD(\DeltaF/F%)')
ylim([-FADMax FADMax])
hold on
yyaxis right
plot((1:t_kernel*samplingRate)/samplingRate,Calcium,'m')
legend('HbT','jRGECO1a')
ylim([-calMax calMax])
ylabel('Calcium(\DeltaF/F%)')
xlabel('Time(s)')
title(strcat('Time Course for',{' '},regionName))

subplot(2,2,3)
plot(t,h)
xlim([-3 10])
ylim([-mrfMax mrfMax])
xlabel('Time(s)')
title(strcat('MRF for',{' '},regionName))

subplot(2,2,4)
plot((1:t_kernel*samplingRate)/samplingRate,FAD,'Color',[0 0.5 0])
hold on
plot((1:t_kernel*samplingRate)/samplingRate,FAD_pred(3*samplingRate+1:3*samplingRate+length(FAD)),'k')
xlabel('Time(s)')
ylabel('\DeltaF/F%')
legend('Actual FAD','Predicted FAD')
title(strcat('r = ',num2str(r)))
ylim([-FADMax FADMax])

sgtitle(strcat('MRF for Region',{' '},regionName,',',{' '},num2str(freqLow),'-2Hz, no GSR, lambda = ',num2str(lambda),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
if ~exist(fullfile(saveDir,'MRF_Regions'))
    mkdir(fullfile(saveDir,'MRF_Regions'))
end
saveName =  fullfile(saveDir,'MRF_Regions', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-',regionName,'-NoGSR-MRF'));
saveas(gcf,strcat(saveName,'.fig'))
saveas(gcf,strcat(saveName,'.png'))
close all
h = resample(h,freq_new,samplingRate);

end




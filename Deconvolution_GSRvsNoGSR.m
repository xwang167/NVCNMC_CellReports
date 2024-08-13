clear ;close all;clc
excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
startInd = 2;
freqLow = 0.02;
lowPass = 0.5;
calMax = 4;
hbMax = 4;
hrfMax = 0.06;
nVx = 128;
nVy = 128;
samplingRate =25;
freq = 10;
t = (-3*freq:(30-3)*freq-1)/freq;
load('AtlasandIsbrain.mat','AtlasSeeds')
mask_barrel = AtlasSeeds==9;
% n = 2;
% startInd = 1;
% freqLow = 0.04;
% calMax = 4;
% hbMax = 0.5;
% hrfMax = 0.02;


for excelRow = [183]%181 183 185
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    if ~exist(strcat(saveDir,'\Barrel_HRF'),'dir')
        mkdir(strcat(saveDir,'\Barrel_HRF'))
    end
    for n = 3
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
        HbT_NoGSR=reshape(HbT,128,128,30*freq,[]);
        Calcium_NoGSR=reshape(Calcium,128,128,30*freq,[]);
        
        % GSR
        HbT_GSR = gsr(HbT_NoGSR,xform_isbrain);
        Calcium_GSR = gsr(Calcium_NoGSR,xform_isbrain);
        
        jj = 1;
        for ii = startInd:10
            
            % reshape
            HbT_barrel_GSR = reshape(HbT_GSR(:,:,:,ii),128*128,[]);
            Calcium_barrel_GSR = reshape(Calcium_GSR(:,:,:,ii),128*128,[]);
            
            HbT_barrel_NoGSR = reshape(HbT_NoGSR(:,:,:,ii),128*128,[]);
            Calcium_barrel_NoGSR = reshape(Calcium_NoGSR(:,:,:,ii),128*128,[]);
            
            
            % Barrel only
            HbT_barrel_GSR = mean(HbT_barrel_GSR(mask_barrel(:),:));
            Calcium_barrel_GSR = mean(Calcium_barrel_GSR(mask_barrel(:),:));
            
            HbT_barrel_NoGSR = mean(HbT_barrel_NoGSR(mask_barrel(:),:));
            Calcium_barrel_NoGSR = mean(Calcium_barrel_NoGSR(mask_barrel(:),:));
            % starting point to be zero
            HbT_barrel_GSR = tukeywin(length(HbT_barrel_GSR),.3).*squeeze(HbT_barrel_GSR');
            Calcium_barrel_GSR = tukeywin(length(Calcium_barrel_GSR),.3).*squeeze(Calcium_barrel_GSR');
            
            HbT_barrel_NoGSR = tukeywin(length(HbT_barrel_NoGSR),.3).*squeeze(HbT_barrel_NoGSR');
            Calcium_barrel_NoGSR = tukeywin(length(Calcium_barrel_NoGSR),.3).*squeeze(Calcium_barrel_NoGSR');
            % HRF
            X_GSR = convmtx(Calcium_barrel_GSR,length(Calcium_barrel_GSR));
            X_NoGSR = convmtx(Calcium_barrel_NoGSR,length(Calcium_barrel_NoGSR));
            %X = X(151:450,:);
            X_GSR = X_GSR(1:length(Calcium_barrel_GSR),1:length(Calcium_barrel_GSR));
            X_NoGSR = X_NoGSR(1:length(Calcium_barrel_NoGSR),1:length(Calcium_barrel_NoGSR));
            
            [~,S_GSR,~]=svd(X_GSR);
            [~,S_NoGSR,~]=svd(X_NoGSR);
            
            lambda = 0.01;
            
            h_region_barrel_GSR = (X_GSR'*S_GSR*X_GSR+(S_GSR(1,1).^3)*lambda*eye(length(Calcium_barrel_GSR))) \ (X_GSR'*S_GSR*[zeros(3*freq,1); HbT_barrel_GSR(1:end-3*freq)]);
            h_region_barrel_NoGSR = (X_NoGSR'*S_NoGSR*X_NoGSR+(S_NoGSR(1,1).^3)*lambda*eye(length(Calcium_barrel_NoGSR))) \ (X_NoGSR'*S_NoGSR*[zeros(3*freq,1); HbT_barrel_NoGSR(1:end-3*freq)]);
            
            % Predicted HbT
            HbT_barrel_pred_GSR = conv(Calcium_barrel_GSR,h_region_barrel_GSR);
            HbT_barrel_pred_NoGSR = conv(Calcium_barrel_NoGSR,h_region_barrel_NoGSR);
            
            HbT_barrel_pred_GSR = HbT_barrel_pred_GSR(1:(length(HbT_barrel_GSR)+3*freq));
            HbT_barrel_pred_NoGSR = HbT_barrel_pred_NoGSR(1:(length(HbT_barrel_NoGSR)+3*freq));
            
            r_region_barrel_GSR = corr(HbT_barrel_GSR,HbT_barrel_pred_GSR(3*freq+1:end));
            r_region_barrel_NoGSR = corr(HbT_barrel_NoGSR,HbT_barrel_pred_NoGSR(3*freq+1:end));
            
            figure('units','normalized','outerposition',[0 0 1 1])
            subplot(2,3,1)
            plot((1:300)/10,HbT_barrel_NoGSR,'k')
            ylabel('\Delta\muM')
            ylim([-hbMax hbMax])
            hold on
            yyaxis right
            plot((1:300)/10,Calcium_barrel_NoGSR,'m')
            legend('HbT','jRGECO1a')
            ylim([-calMax calMax])
            ylabel('\DeltaF/F%')
            xlabel('Time(s)')
            title('Time Course for Barrel Cortex, No GSR')
            
            subplot(2,3,2)
            plot(t,h_region_barrel_NoGSR)
            xlim([-3 7])
            ylim([-hrfMax hrfMax])
            ylabel('\Delta\muM/\DeltaF/F%')
            xlabel('Time(s)')
            title('HRF for Barrel Cortex, No GSR')
            
            subplot(2,3,3)
            plot((1:300)/freq,zscore(HbT_barrel_NoGSR),'k')
            hold on
            plot((1:300)/freq,zscore(HbT_barrel_pred_NoGSR(3*freq+1:3*freq+length(HbT_barrel_NoGSR))),'Color',[0 0.5 0])
            xlabel('Time(s)')
            ylabel('\Delta\muM')
            legend('Actual HbT','Predicted HbT')
            title(strcat('r = ',num2str(r_region_barrel_NoGSR)))
            ylim([-hbMax hbMax])
      
            
            subplot(2,3,4)
            plot((1:300)/freq,HbT_barrel_GSR,'k')
            ylabel('\Delta\muM')
            ylim([-hbMax hbMax])
            hold on
            yyaxis right
            plot((1:300)/freq,Calcium_barrel_GSR,'m')
            legend('HbT','jRGECO1a')
            ylim([-calMax calMax])
            ylabel('\DeltaF/F%')
            xlabel('Time(s)')
            title('Time Course for Barrel Cortex, GSR')
            
            subplot(2,3,5)
            plot(t,h_region_barrel_GSR)
            xlim([-3 7])
            ylim([-hrfMax hrfMax])
            ylabel('\Delta\muM/\DeltaF/F%')
            xlabel('Time(s)')
            title('HRF for Barrel Cortex, GSR')
            
            subplot(2,3,6)
            plot((1:300)/freq,zscore(HbT_barrel_GSR),'k')
            hold on
            plot((1:300)/freq,zscore(HbT_barrel_pred_GSR(3*freq+1:3*freq+length(HbT_barrel_GSR))),'Color',[0 0.5 0])
            xlabel('Time(s)')
            ylabel('\Delta\muM')
            legend('Actual HbT','Predicted HbT')
            title(strcat('r = ',num2str(r_region_barrel_GSR)))
            ylim([-hbMax hbMax])
            
            
        end
    end
end



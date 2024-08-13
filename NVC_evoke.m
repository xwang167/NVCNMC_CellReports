
%close all;clear all;clc

excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
excelRows = [203 205 231 235 241];

for excelRow = excelRows
    
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':U',num2str(excelRow)]);
    
    rawdataloc = excelRaw{3};
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    processedName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_processed_mouse','.mat');
    sessionInfo.stimblocksize = excelRaw{11};
    sessionInfo.stimbaseline=excelRaw{12};
    sessionInfo.stimduration = excelRaw{13};
    xform_datahb_mouse_GSR = [];
    xform_datahb_mouse_NoGSR = [];
    if ~exist(fullfile(saveDir,processedName_mouse),'file')
        for n = runs
            processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
            sessionInfo.stimblocksize = excelRaw{11};
            disp('loading processed data')
            
            load(fullfile(saveDir, processedName),'xform_datahb')
            numBlocks = size(xform_datahb,4)/sessionInfo.stimblocksize;
            
            xform_datahb_NoGSR = reshape(xform_datahb,128,128,2,[],numBlocks);
            
            clear xform_datahb
            
            xform_datahb_baseline = mean(xform_datahb_NoGSR(:,:,:,1:sessionInfo.stimbaseline,:),4);
            xform_datahb_baseline = repmat(xform_datahb_baseline,1,1,1,size(xform_datahb_NoGSR,4),1);
            
            xform_datahb_NoGSR = xform_datahb_NoGSR - xform_datahb_baseline;
            
            
            xform_datahb_mouse_NoGSR = cat(5,xform_datahb_mouse_NoGSR,xform_datahb_NoGSR);
            
            
            
            load(fullfile(saveDir,strcat(recDate,'-',mouseName,'-stim',num2str(n),'_processed.mat')),'xform_datahb_GSR')
            
            xform_datahb_GSR = reshape(xform_datahb_GSR,128,128,2,[],numBlocks);
            
            
            xform_datahb_GSR_baseline = mean(xform_datahb_GSR(:,:,:,1:sessionInfo.stimbaseline,:),4);
            xform_datahb_GSR_baseline = repmat(xform_datahb_GSR_baseline,1,1,1,size(xform_datahb_GSR,4),1);
            
            xform_datahb_GSR = xform_datahb_GSR - xform_datahb_GSR_baseline;
            
            xform_datahb_mouse_GSR = cat(5,xform_datahb_mouse_GSR,xform_datahb_GSR);
            clear xform_datahb_GSR
        end
        xform_datahb_mouse_NoGSR = mean(xform_datahb_mouse_NoGSR,5);
        xform_datahb_mouse_GSR = mean(xform_datahb_mouse_GSR,5);
        if exist(fullfile(saveDir,processedName_mouse),'file')
            save(fullfile(saveDir,processedName_mouse),'xform_datahb_mouse_GSR','xform_datahb_mouse_NoGSR','-append');
        else
            save(fullfile(saveDir,processedName_mouse),'xform_datahb_mouse_GSR','xform_datahb_mouse_NoGSR','-v7.3')
        end
    end
end
%% 241
for excelRow = 241
    
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':U',num2str(excelRow)]);
    
    rawdataloc = excelRaw{3};
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    processedName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_processed_mouse','.mat');
    sessionInfo.stimblocksize = excelRaw{11};
    sessionInfo.stimbaseline=excelRaw{12};
    sessionInfo.stimduration = excelRaw{13};
    xform_datahb_mouse_GSR = [];
    xform_datahb_mouse_NoGSR = [];
    
    for n = runs
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        sessionInfo.stimblocksize = excelRaw{11};
        disp('loading processed data')
        
        load(fullfile(saveDir, processedName),'xform_datahb')
        numBlocks = size(xform_datahb,4)/sessionInfo.stimblocksize;
        
        xform_datahb_NoGSR = reshape(xform_datahb,128,128,2,[],numBlocks);
        
        clear xform_datahb
        
        xform_datahb_baseline = mean(xform_datahb_NoGSR(:,:,:,1:sessionInfo.stimbaseline,:),4);
        xform_datahb_baseline = repmat(xform_datahb_baseline,1,1,1,size(xform_datahb_NoGSR,4),1);
        
        xform_datahb_NoGSR = xform_datahb_NoGSR - xform_datahb_baseline;
        
        
        xform_datahb_mouse_NoGSR = cat(5,xform_datahb_mouse_NoGSR,xform_datahb_NoGSR);
        
        
        
        load(fullfile(saveDir,strcat(recDate,'-',mouseName,'-stim',num2str(n),'_processed.mat')),'xform_datahb_GSR')
        
        xform_datahb_GSR = reshape(xform_datahb_GSR,128,128,2,[],numBlocks);
        
        
        xform_datahb_GSR_baseline = mean(xform_datahb_GSR(:,:,:,1:sessionInfo.stimbaseline,:),4);
        xform_datahb_GSR_baseline = repmat(xform_datahb_GSR_baseline,1,1,1,size(xform_datahb_GSR,4),1);
        
        xform_datahb_GSR = xform_datahb_GSR - xform_datahb_GSR_baseline;
        
        xform_datahb_mouse_GSR = cat(5,xform_datahb_mouse_GSR,xform_datahb_GSR);
        clear xform_datahb_GSR
    end
    xform_datahb_mouse_NoGSR = mean(xform_datahb_mouse_NoGSR,5);
    xform_datahb_mouse_GSR = mean(xform_datahb_mouse_GSR,5);
    if exist(fullfile(saveDir,processedName_mouse),'file')
        save(fullfile(saveDir,processedName_mouse),'xform_datahb_mouse_GSR','xform_datahb_mouse_NoGSR','-append');
    else
        save(fullfile(saveDir,processedName_mouse),'xform_datahb_mouse_GSR','xform_datahb_mouse_NoGSR','-v7.3')
    end
    
end

%% mice
xform_datahb_mice_GSR = nan(128,128,2,750,5);
xform_datahb_mice_NoGSR = nan(128,128,2,750,5);
ll = 1;
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    rawdataloc = excelRaw{3};
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType =excelRaw{6}; sessionType = sessionType(3:end-2);
    processedName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_processed_mouse','.mat');
    load(fullfile(saveDir,processedName_mouse),...
        'xform_datahb_mouse_GSR','xform_datahb_mouse_NoGSR')
    xform_datahb_mice_GSR(:,:,:,:,ll) = xform_datahb_mouse_GSR;
    xform_datahb_mice_NoGSR(:,:,:,:,ll) = xform_datahb_mouse_NoGSR;
    ll = ll+1;
end

xform_datahb_mice_GSR = mean(xform_datahb_mice_GSR,5);
xform_datahb_mice_NoGSR = mean(xform_datahb_mice_NoGSR,5);
save('191030--R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-stim_processed_mice.mat',...
    'xform_datahb_mice_GSR','xform_datahb_mice_NoGSR','-append')


%% anes ROI evoke
xform_HbT = squeeze(xform_datahb_mice_NoGSR(:,:,1,:)+xform_datahb_mice_NoGSR(:,:,2,:));
xform_HbT = reshape(xform_HbT,128*128,[]);
xform_jrgeco1aCorr_mice_NoGSR = reshape(xform_jrgeco1aCorr_mice_NoGSR,128*128,[]);
calcium_anes_evoke = mean(xform_jrgeco1aCorr_mice_NoGSR(ROI_contour(:),:),1);
HbT_anes_evoke = mean(xform_HbT(ROI_contour(:),:),1);

xform_FADCorr_mice_NoGSR = reshape(xform_FADCorr_mice_NoGSR,128*128,[]);
FAD_anes_evoke = mean(xform_FADCorr_mice_NoGSR(ROI_contour(:),:),1);


%% interpolation,anes
calcium_anes_evoke = calcium_anes_evoke*100;
HbT_anes_evoke = HbT_anes_evoke*10^6;
xq = 126:0.01:128;
vq_calcium_anes = interp1([126,127,128],calcium_anes_evoke(126:128),xq,'spline');
max_calcium_anes = max(vq_calcium_anes);
ind = 79;
xq(79)/25

figure
plot(HbT_anes_evoke)

HbT_anes_evoke_filter = lowpass(HbT_anes_evoke,1,25);

FAD_anes_evoke = FAD_anes_evoke*100;
xq = 126:0.01:132;
vq_FAD_anes = interp1(126:132,FAD_anes_evoke(126:132),xq,'spline');
max_FAD_anes = max(vq_FAD_anes);

stimFrequency = 3;
stimduration = 5;
stimbaseline = 125;
framerate = 25;
minimum = -0.3;
maxmum = 0.3;

figure
plot(FAD_anes_evoke);
for i  = 0:1/stimFrequency:stimduration-1/stimFrequency
    hold on
    line([stimbaseline/framerate+i stimbaseline/framerate+i]*25,[ 1.1*minimum 1.1*maxmum]);
    
end
hold on
plot(xq,vq_FAD_anes,'g')


%% awake ROI evoke
xform_HbT = squeeze(xform_datahb_mice_NoGSR(:,:,1,:)+xform_datahb_mice_NoGSR(:,:,2,:));
xform_HbT = reshape(xform_HbT,128*128,[]);
xform_jrgeco1aCorr_mice_NoGSR = reshape(xform_jrgeco1aCorr_mice_NoGSR,128*128,[]);
calcium_awake_evoke = mean(xform_jrgeco1aCorr_mice_NoGSR(ROI_GSR(:),:),1);
HbT_awake_evoke = mean(xform_HbT(ROI_GSR(:),:),1);
%%interpolation, awake
calcium_awake_evoke = calcium_awake_evoke*100;
HbT_awake_evoke = HbT_awake_evoke*10^6;

calcium_awake_evoke = calcium_awake_evoke - mean(calcium_awake_evoke(1:125));
HbT_awake_evoke = HbT_awake_evoke - mean(HbT_awake_evoke(1:125));


xq = 126:0.01:130;
vq_calcium_awake= interp1(126:130,calcium_awake_evoke(126:130),xq,'spline');
max_calcium_awake = max(vq_calcium_awake);
figure
plot(calcium_awake_evoke)
xlim([100 200])
hold on
plot(xq,vq_calcium_awake,'m')
ind = 79;
xq(79)/25

HbT_awake_evoke_filter = lowpass(HbT_awake_evoke,1,25);
figure
plot(HbT_awake_evoke)
hold on
plot(HbT_awake_evoke_filter,'k')

%FAD
xform_FADCorr_mice_NoGSR = reshape(xform_FADCorr_mice_NoGSR,128*128,[]);
FAD_awake_evoke = mean(xform_FADCorr_mice_NoGSR(ROI_contour(:),:),1);

FAD_awake_evoke = FAD_awake_evoke*100;
xq = 126:0.01:132;
vq_FAD_awake = interp1(126:132,FAD_awake_evoke(126:132),xq,'spline');
max_FAD_awake = max(vq_FAD_awake);

stimFrequency = 3;
stimduration = 5;
stimbaseline = 125;
framerate = 25;
minimum = -0.2;
maxmum = 0.45;

figure
plot(FAD_awake_evoke);
for i  = 0:1/stimFrequency:stimduration-1/stimFrequency
    hold on
    line([stimbaseline/framerate+i stimbaseline/framerate+i]*25,[ 1.1*minimum 1.1*maxmum]);
    
end
hold on
plot(xq,vq_FAD_awake,'g')

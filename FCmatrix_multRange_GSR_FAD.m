
close all;clear all;clc
import mouse.*
excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
excelRows = [195 202 204 230 234 240 181 183 185 228 232 236];%[185,228,232,236,181];%321:327;
runs = 1:3;
load('L:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc.mat',...
    'xform_isbrain_mice')
xform_isbrain_mice_awake = xform_isbrain_mice;
load('L:\RGECO\cat\191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc.mat',...
    'xform_isbrain_mice')
xform_isbrain_mice_anes = xform_isbrain_mice;
xform_isbrain_mice = xform_isbrain_mice_awake.*xform_isbrain_mice_anes;
%

for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.darkFrameNum = excelRaw{15};
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    sessionInfo.framerate = excelRaw{7};
    systemInfo.numLEDs = 4;
    fs = excelRaw{7};
    
    
    for n = runs
        visName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n));
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        disp('loading processed data')
        load(fullfile(saveDir,processedName),'xform_FADCorr');
        xform_FADCorr(isinf(xform_FADCorr)) = 0;
        xform_FADCorr(isnan(xform_FADCorr)) = 0;
        FCMatrix_FAD_ISA_old = calcFCMatrix(squeeze(xform_FADCorr),0.009,0.08,fs,xform_isbrain_mice);
        FCMatrix_FAD_Delta_old = calcFCMatrix(squeeze(xform_FADCorr),0.4,4,fs,xform_isbrain_mice);
        FCMatrix_FAD_0p02 = calcFCMatrix(squeeze(xform_FADCorr),0.02,0.08,fs,xform_isbrain_mice);
        FCMatrix_FAD_0p04 = calcFCMatrix(squeeze(xform_FADCorr),0.04,0.16,fs,xform_isbrain_mice);
        FCMatrix_FAD_0p08 = calcFCMatrix(squeeze(xform_FADCorr),0.08,0.32,fs,xform_isbrain_mice);
        FCMatrix_FAD_0p16 = calcFCMatrix(squeeze(xform_FADCorr),0.16,0.64,fs,xform_isbrain_mice);
        FCMatrix_FAD_0p32 = calcFCMatrix(squeeze(xform_FADCorr),0.32,1.28,fs,xform_isbrain_mice);
        FCMatrix_FAD_0p64 = calcFCMatrix(squeeze(xform_FADCorr),0.64,2.56,fs,xform_isbrain_mice);
        FCMatrix_FAD_1p28 = calcFCMatrix(squeeze(xform_FADCorr),1.28,5.12,fs,xform_isbrain_mice);
        clear xform_FADCorr
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        if exist(fullfile(saveDir,processedName_fcMatrix),'file')
            save(fullfile(saveDir,processedName_fcMatrix),...
                'FCMatrix_FAD_ISA_old','FCMatrix_FAD_Delta_old',...
                'FCMatrix_FAD_0p02','FCMatrix_FAD_0p04',...
                'FCMatrix_FAD_0p08','FCMatrix_FAD_0p16',...
                'FCMatrix_FAD_0p32','FCMatrix_FAD_0p64',...
                'FCMatrix_FAD_1p28','-append')
        else
            save(fullfile(saveDir,processedName_fcMatrix),...
                'FCMatrix_FAD_ISA_old','FCMatrix_FAD_Delta_old',...
                'FCMatrix_FAD_0p02','FCMatrix_FAD_0p04',...
                'FCMatrix_FAD_0p08','FCMatrix_FAD_0p16',...
                'FCMatrix_FAD_0p32','FCMatrix_FAD_0p64',...
                'FCMatrix_FAD_1p28','-v7.3')
        end
        
        clear FCMatrix_FAD_ISA_old FCMatrix_FAD_Delta_old...
            FCMatrix_FAD_0p02 FCMatrix_FAD_0p04...
            FCMatrix_FAD_0p08 FCMatrix_FAD_0p16...
            FCMatrix_FAD_0p32 FCMatrix_FAD_0p64...
            FCMatrix_FAD_1p28
        
        
    end
end





excelRows = [181 183 185 228 232 236 195 202 204 230 234 240];
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    processedName_fcMatrix_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_fcMatrix_mouse','.mat');
    FCMatrix_FAD_ISA_old_mouse = [];
    FCMatrix_FAD_Delta_old_mouse = [];
    FCMatrix_FAD_0p02_mouse = [];
    FCMatrix_FAD_0p04_mouse = [];
    FCMatrix_FAD_0p08_mouse = [];
    FCMatrix_FAD_0p16_mouse = [];
    FCMatrix_FAD_0p32_mouse = [];
    FCMatrix_FAD_0p64_mouse = [];
    FCMatrix_FAD_1p28_mouse = [];
    for n = runs
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        load(fullfile(saveDir,processedName_fcMatrix),...
            'FCMatrix_FAD_ISA_old','FCMatrix_FAD_Delta_old',...
            'FCMatrix_FAD_0p02','FCMatrix_FAD_0p04',...
            'FCMatrix_FAD_0p08','FCMatrix_FAD_0p16',...
            'FCMatrix_FAD_0p32','FCMatrix_FAD_0p64',...
            'FCMatrix_FAD_1p28')
        FCMatrix_FAD_ISA_old_mouse = cat(3,FCMatrix_FAD_ISA_old_mouse,FCMatrix_FAD_ISA_old);
        FCMatrix_FAD_Delta_old_mouse = cat(3,FCMatrix_FAD_Delta_old_mouse,FCMatrix_FAD_Delta_old);
        FCMatrix_FAD_0p02_mouse = cat(3,FCMatrix_FAD_0p02_mouse,FCMatrix_FAD_0p02);
        FCMatrix_FAD_0p04_mouse = cat(3,FCMatrix_FAD_0p04_mouse,FCMatrix_FAD_0p04);
        FCMatrix_FAD_0p08_mouse = cat(3,FCMatrix_FAD_0p08_mouse,FCMatrix_FAD_0p08);
        FCMatrix_FAD_0p16_mouse = cat(3,FCMatrix_FAD_0p16_mouse,FCMatrix_FAD_0p16);
        FCMatrix_FAD_0p32_mouse = cat(3,FCMatrix_FAD_0p32_mouse,FCMatrix_FAD_0p32);
        FCMatrix_FAD_0p64_mouse = cat(3,FCMatrix_FAD_0p64_mouse,FCMatrix_FAD_0p64);
        FCMatrix_FAD_1p28_mouse = cat(3,FCMatrix_FAD_1p28_mouse,FCMatrix_FAD_1p28);
        
    end
    FCMatrix_FAD_ISA_old_mouse = mean(FCMatrix_FAD_ISA_old_mouse,3);
    FCMatrix_FAD_Delta_old_mouse = mean(FCMatrix_FAD_Delta_old_mouse,3);
    FCMatrix_FAD_0p02_mouse = mean(FCMatrix_FAD_0p02_mouse,3);
    FCMatrix_FAD_0p04_mouse = mean(FCMatrix_FAD_0p04_mouse,3);
    FCMatrix_FAD_0p08_mouse = mean(FCMatrix_FAD_0p08_mouse,3);
    FCMatrix_FAD_0p16_mouse = mean(FCMatrix_FAD_0p16_mouse,3);
    FCMatrix_FAD_0p32_mouse = mean(FCMatrix_FAD_0p32_mouse,3);
    FCMatrix_FAD_0p64_mouse = mean(FCMatrix_FAD_0p64_mouse,3);
    FCMatrix_FAD_1p28_mouse = mean(FCMatrix_FAD_1p28_mouse,3);
    save(fullfile(saveDir,processedName_fcMatrix_mouse),...
        'FCMatrix_FAD_ISA_old_mouse','FCMatrix_FAD_Delta_old_mouse',...
        'FCMatrix_FAD_0p02_mouse','FCMatrix_FAD_0p04_mouse',...
        'FCMatrix_FAD_0p08_mouse','FCMatrix_FAD_0p16_mouse',...
        'FCMatrix_FAD_0p32_mouse','FCMatrix_FAD_0p64_mouse',...
        'FCMatrix_FAD_1p28_mouse','-append')
end

miceName = [];
FCMatrix_FAD_ISA_old_mice = [];
FCMatrix_FAD_Delta_old_mice = [];
FCMatrix_FAD_0p02_mice = [];
FCMatrix_FAD_0p04_mice = [];
FCMatrix_FAD_0p08_mice = [];
FCMatrix_FAD_0p16_mice = [];
FCMatrix_FAD_0p32_mice = [];
FCMatrix_FAD_0p64_mice = [];
FCMatrix_FAD_1p28_mice = [];
excelRows = [195 202 204 230 234 240];
saveDir_cat = 'L:\RGECO\cat';
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = char(strcat(miceName, '-', mouseName));
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    processedName_fcMatrix_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_fcMatrix_mouse','.mat');
    load(fullfile(saveDir,processedName_fcMatrix_mouse),...
        'FCMatrix_FAD_ISA_old_mouse','FCMatrix_FAD_Delta_old_mouse',...
        'FCMatrix_FAD_0p02_mouse','FCMatrix_FAD_0p04_mouse',...
        'FCMatrix_FAD_0p08_mouse','FCMatrix_FAD_0p16_mouse',...
        'FCMatrix_FAD_0p32_mouse','FCMatrix_FAD_0p64_mouse',...
        'FCMatrix_FAD_1p28_mouse')
    FCMatrix_FAD_ISA_old_mice = cat(3,FCMatrix_FAD_ISA_old_mice,atanh(FCMatrix_FAD_ISA_old_mouse));
    FCMatrix_FAD_Delta_old_mice = cat(3,FCMatrix_FAD_Delta_old_mice,atanh(FCMatrix_FAD_Delta_old_mouse));
    FCMatrix_FAD_0p02_mice = cat(3,FCMatrix_FAD_0p02_mice,atanh(FCMatrix_FAD_0p02_mouse));
    FCMatrix_FAD_0p04_mice = cat(3,FCMatrix_FAD_0p04_mice,atanh(FCMatrix_FAD_0p04_mouse));
    FCMatrix_FAD_0p08_mice = cat(3,FCMatrix_FAD_0p08_mice,atanh(FCMatrix_FAD_0p08_mouse));
    FCMatrix_FAD_0p16_mice = cat(3,FCMatrix_FAD_0p16_mice,atanh(FCMatrix_FAD_0p16_mouse));
    FCMatrix_FAD_0p32_mice = cat(3,FCMatrix_FAD_0p32_mice,atanh(FCMatrix_FAD_0p32_mouse));
    FCMatrix_FAD_0p64_mice = cat(3,FCMatrix_FAD_0p64_mice,atanh(FCMatrix_FAD_0p64_mouse));
    FCMatrix_FAD_1p28_mice = cat(3,FCMatrix_FAD_1p28_mice,atanh(FCMatrix_FAD_1p28_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_FAD_ISA_old_mice = nanmean(FCMatrix_FAD_ISA_old_mice,3);
FCMatrix_FAD_Delta_old_mice = nanmean(FCMatrix_FAD_Delta_old_mice,3);
FCMatrix_FAD_0p02_mice = nanmean(FCMatrix_FAD_0p02_mice,3);
FCMatrix_FAD_0p04_mice = nanmean(FCMatrix_FAD_0p04_mice,3);
FCMatrix_FAD_0p08_mice = nanmean(FCMatrix_FAD_0p08_mice,3);
FCMatrix_FAD_0p16_mice = nanmean(FCMatrix_FAD_0p16_mice,3);
FCMatrix_FAD_0p32_mice = nanmean(FCMatrix_FAD_0p32_mice,3);
FCMatrix_FAD_0p64_mice = nanmean(FCMatrix_FAD_0p64_mice,3);
FCMatrix_FAD_1p28_mice = nanmean(FCMatrix_FAD_1p28_mice,3);

save(fullfile(saveDir_cat,processedName_fcMatrix_mice),...
        'FCMatrix_FAD_ISA_old_mice','FCMatrix_FAD_Delta_old_mice',...
        'FCMatrix_FAD_0p02_mice','FCMatrix_FAD_0p04_mice',...
        'FCMatrix_FAD_0p08_mice','FCMatrix_FAD_0p16_mice',...
        'FCMatrix_FAD_0p32_mice','FCMatrix_FAD_0p64_mice',...
        'FCMatrix_FAD_1p28_mice','-append')
    
% A = ones(size(FCMatrix_FAD_ISA_old_mice,1),size(FCMatrix_FAD_ISA_old_mice,2));
% triup = triu(A,1);
% triup = logical(triup);
% B = FCMatrix_FAD_ISA_old_mice(triup);
% histogram(B)
% xlim([-3 3])
% title('Averaged Across Mice, Anes, FAD, ISA')


    
    
    

miceName = [];
FCMatrix_FAD_ISA_old_mice = [];
FCMatrix_FAD_Delta_old_mice = [];
FCMatrix_FAD_0p02_mice = [];
FCMatrix_FAD_0p04_mice = [];
FCMatrix_FAD_0p08_mice = [];
FCMatrix_FAD_0p16_mice = [];
FCMatrix_FAD_0p32_mice = [];
FCMatrix_FAD_0p64_mice = [];
FCMatrix_FAD_1p28_mice = [];
excelRows = [181 183 185 228 232 236];
saveDir_cat = 'L:\RGECO\cat';
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = char(strcat(miceName, '-', mouseName));
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    processedName_fcMatrix_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_fcMatrix_mouse','.mat');
    load(fullfile(saveDir,processedName_fcMatrix_mouse),...
        'FCMatrix_FAD_ISA_old_mouse','FCMatrix_FAD_Delta_old_mouse',...
        'FCMatrix_FAD_0p02_mouse','FCMatrix_FAD_0p04_mouse',...
        'FCMatrix_FAD_0p08_mouse','FCMatrix_FAD_0p16_mouse',...
        'FCMatrix_FAD_0p32_mouse','FCMatrix_FAD_0p64_mouse',...
        'FCMatrix_FAD_1p28_mouse')
    
    FCMatrix_FAD_ISA_old_mice = cat(3,FCMatrix_FAD_ISA_old_mice,atanh(FCMatrix_FAD_ISA_old_mouse));
    FCMatrix_FAD_Delta_old_mice = cat(3,FCMatrix_FAD_Delta_old_mice,atanh(FCMatrix_FAD_Delta_old_mouse));
    FCMatrix_FAD_0p02_mice = cat(3,FCMatrix_FAD_0p02_mice,atanh(FCMatrix_FAD_0p02_mouse));
    FCMatrix_FAD_0p04_mice = cat(3,FCMatrix_FAD_0p04_mice,atanh(FCMatrix_FAD_0p04_mouse));
    FCMatrix_FAD_0p08_mice = cat(3,FCMatrix_FAD_0p08_mice,atanh(FCMatrix_FAD_0p08_mouse));
    FCMatrix_FAD_0p16_mice = cat(3,FCMatrix_FAD_0p16_mice,atanh(FCMatrix_FAD_0p16_mouse));
    FCMatrix_FAD_0p32_mice = cat(3,FCMatrix_FAD_0p32_mice,atanh(FCMatrix_FAD_0p32_mouse));
    FCMatrix_FAD_0p64_mice = cat(3,FCMatrix_FAD_0p64_mice,atanh(FCMatrix_FAD_0p64_mouse));
    FCMatrix_FAD_1p28_mice = cat(3,FCMatrix_FAD_1p28_mice,atanh(FCMatrix_FAD_1p28_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_FAD_ISA_old_mice = nanmean(FCMatrix_FAD_ISA_old_mice,3);
FCMatrix_FAD_Delta_old_mice = nanmean(FCMatrix_FAD_Delta_old_mice,3);
FCMatrix_FAD_0p02_mice = nanmean(FCMatrix_FAD_0p02_mice,3);
FCMatrix_FAD_0p04_mice = nanmean(FCMatrix_FAD_0p04_mice,3);
FCMatrix_FAD_0p08_mice = nanmean(FCMatrix_FAD_0p08_mice,3);
FCMatrix_FAD_0p16_mice = nanmean(FCMatrix_FAD_0p16_mice,3);
FCMatrix_FAD_0p32_mice = nanmean(FCMatrix_FAD_0p32_mice,3);
FCMatrix_FAD_0p64_mice = nanmean(FCMatrix_FAD_0p64_mice,3);
FCMatrix_FAD_1p28_mice = nanmean(FCMatrix_FAD_1p28_mice,3);

save(fullfile(saveDir_cat,processedName_fcMatrix_mice),...
        'FCMatrix_FAD_ISA_old_mice','FCMatrix_FAD_Delta_old_mice',...
        'FCMatrix_FAD_0p02_mice','FCMatrix_FAD_0p04_mice',...
        'FCMatrix_FAD_0p08_mice','FCMatrix_FAD_0p16_mice',...
        'FCMatrix_FAD_0p32_mice','FCMatrix_FAD_0p64_mice',...
        'FCMatrix_FAD_1p28_mice','-append')
% A = ones(size(FCMatrix_FAD_ISA_old_mice,1),size(FCMatrix_FAD_ISA_old_mice,2));
% triup = triu(A,1);
% triup = logical(triup);
% B = FCMatrix_FAD_ISA_old_mice(triup);
% histogram(B)
% xlim([-3 3])
% title('Averaged Across Mice, Awake, FAD, ISA')






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
        load(fullfile(saveDir,processedName),'xform_datahb');
        xform_datahb(isinf(xform_datahb)) = 0;
        xform_datahb(isnan(xform_datahb)) = 0;
        HbT = squeeze(xform_datahb(:,:,1,:)+xform_datahb(:,:,2,:));
       
        FCMatrix_HbT_0p01 = calcFCMatrix(squeeze(HbT),0.01,0.04,fs,xform_isbrain_mice);

        clear xform_jrgeco1aCorr
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');

            save(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_HbT_0p01','-append')
    
        
        clear FCMatrix_HbT_0p01
        
        
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

    FCMatrix_HbT_0p01_mouse = [];
    for n = runs
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        load(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_HbT_0p01')

        FCMatrix_HbT_0p01_mouse = cat(3,FCMatrix_HbT_0p01_mouse,FCMatrix_HbT_0p01);
        
    end

    FCMatrix_HbT_0p01_mouse = mean(FCMatrix_HbT_0p01_mouse,3);

    save(fullfile(saveDir,processedName_fcMatrix_mouse), 'FCMatrix_HbT_0p01_mouse','-append')
end

miceName = [];

FCMatrix_HbT_0p01_mice = [];

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
    load(fullfile(saveDir,processedName_fcMatrix_mouse), 'FCMatrix_HbT_0p02_mouse')
    FCMatrix_HbT_0p01_mice = cat(3,FCMatrix_HbT_0p01_mice,atanh(FCMatrix_HbT_0p01_mouse));

end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_HbT_0p01_mice = nanmean(FCMatrix_HbT_0p01_mice,3);


save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_HbT_0p01_mice','-append')
    
% A = ones(size(FCMatrix_HbT_ISA_old_mice,1),size(FCMatrix_HbT_ISA_old_mice,2));
% triup = triu(A,1);
% triup = logical(triup);
% B = FCMatrix_HbT_ISA_old_mice(triup);
% histogram(B)
% xlim([-3 3])
% title('Averaged Across Mice, Anes, HbT, ISA')


    
    
    

miceName = [];

FCMatrix_HbT_0p01_mice = [];

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
    load(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_HbT_0p02_mouse')
    FCMatrix_HbT_0p01_mice = cat(3,FCMatrix_HbT_0p01_mice,atanh(FCMatrix_HbT_0p01_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');

FCMatrix_HbT_0p01_mice = nanmean(FCMatrix_HbT_0p01_mice,3);
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_HbT_0p01_mice','-append')
% A = ones(size(FCMatrix_HbT_ISA_old_mice,1),size(FCMatrix_HbT_ISA_old_mice,2));
% triup = triu(A,1);
% triup = logical(triup);
% B = FCMatrix_HbT_ISA_old_mice(triup);
% histogram(B)
% xlim([-3 3])
% title('Averaged Across Mice, Awake, HbT, ISA')







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
        load(fullfile(saveDir,processedName),'xform_jrgeco1aCorr');
        xform_jrgeco1aCorr(isinf(xform_jrgeco1aCorr)) = 0;
        xform_jrgeco1aCorr(isnan(xform_jrgeco1aCorr)) = 0;
        FCMatrix_Calcium_ISA_old = calcFCMatrix(squeeze(xform_jrgeco1aCorr),0.009,0.08,fs,xform_isbrain_mice);
        FCMatrix_Calcium_Delta_old = calcFCMatrix(squeeze(xform_jrgeco1aCorr),0.4,4,fs,xform_isbrain_mice);
        clear xform_jrgeco1aCorr
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        if exist(fullfile(saveDir,processedName_fcMatrix))
            save(fullfile(saveDir,processedName_fcMatrix),...
                'FCMatrix_Calcium_ISA_old','FCMatrix_Calcium_Delta_old', '-append')
        else
            save(fullfile(saveDir,processedName_fcMatrix),...
                'FCMatrix_Calcium_ISA_old','FCMatrix_Calcium_Delta_old','-v7.3')
             clear FCMatrix_Calcium_ISA_old FCMatrix_Calcium_Delta_old
        end
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
    FCMatrix_Calcium_ISA_old_mouse = [];
    FCMatrix_Calcium_Delta_old_mouse = [];

    for n = runs
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        load(fullfile(saveDir,processedName_fcMatrix),...
            'FCMatrix_Calcium_ISA_old','FCMatrix_Calcium_Delta_old')
        FCMatrix_Calcium_ISA_old_mouse = cat(3,FCMatrix_Calcium_ISA_old_mouse,FCMatrix_Calcium_ISA_old);
        FCMatrix_Calcium_Delta_old_mouse = cat(3,FCMatrix_Calcium_Delta_old_mouse,FCMatrix_Calcium_Delta_old);
     
    end
    FCMatrix_Calcium_ISA_old_mouse = mean(FCMatrix_Calcium_ISA_old_mouse,3);
    FCMatrix_Calcium_Delta_old_mouse = mean(FCMatrix_Calcium_Delta_old_mouse,3);
 
    save(fullfile(saveDir,processedName_fcMatrix_mouse),...
        'FCMatrix_Calcium_ISA_old_mouse','FCMatrix_Calcium_Delta_old_mouse','-append')
end




miceName = [];
FCMatrix_Calcium_ISA_old_mice = [];
FCMatrix_Calcium_Delta_old_mice = [];
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
        'FCMatrix_Calcium_ISA_old_mouse','FCMatrix_Calcium_Delta_old_mouse')
    FCMatrix_Calcium_ISA_old_mice = cat(3,FCMatrix_Calcium_ISA_old_mice,atanh(FCMatrix_Calcium_ISA_old_mouse));
    FCMatrix_Calcium_Delta_old_mice = cat(3,FCMatrix_Calcium_Delta_old_mice,atanh(FCMatrix_Calcium_Delta_old_mouse));

end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_Calcium_ISA_old_mice = nanmean(FCMatrix_Calcium_ISA_old_mice,3);
FCMatrix_Calcium_Delta_old_mice = nanmean(FCMatrix_Calcium_Delta_old_mice,3);


save(fullfile(saveDir_cat,processedName_fcMatrix_mice),...
        'FCMatrix_Calcium_ISA_old_mice','FCMatrix_Calcium_Delta_old_mice','-append')

    
    
    
    
miceName = [];
FCMatrix_Calcium_ISA_old_mice = [];
FCMatrix_Calcium_Delta_old_mice = [];
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
        'FCMatrix_Calcium_ISA_old_mouse','FCMatrix_Calcium_Delta_old_mouse')
    FCMatrix_Calcium_ISA_old_mice = cat(3,FCMatrix_Calcium_ISA_old_mice,atanh(FCMatrix_Calcium_ISA_old_mouse));
    FCMatrix_Calcium_Delta_old_mice = cat(3,FCMatrix_Calcium_Delta_old_mice,atanh(FCMatrix_Calcium_Delta_old_mouse));

end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_Calcium_ISA_old_mice = nanmean(FCMatrix_Calcium_ISA_old_mice,3);
FCMatrix_Calcium_Delta_old_mice = nanmean(FCMatrix_Calcium_Delta_old_mice,3);
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),...
        'FCMatrix_Calcium_ISA_old_mice','FCMatrix_Calcium_Delta_old_mice','-append')


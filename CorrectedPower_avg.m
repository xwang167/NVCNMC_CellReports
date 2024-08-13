clear all;close all;clc;
excelFile = "X:\RGECO\DataBase_Xiaodan_1.xlsx";
catDir = 'E:\RGECO\cat\'; 

%% average uncorrected power map for anesthetized mice
excelRows_anes = [202 195 204 230 234 240];
miceName = [];
jrgeco1aCorr_ISA_powerMap_mice   = [];
jrgeco1aCorr_Delta_powerMap_mice = [];


for excelRow = excelRows_anes
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':R',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = char(strcat(miceName, '-', mouseName));
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.darkFrameNum = excelRaw{11};
    rawdataloc = excelRaw{3};
    systemType =excelRaw{5};
    jrgeco1aCorr_ISA_powerMap_mouse   = [];
    jrgeco1aCorr_Delta_powerMap_mouse = [];
    FAD_ISA_powerMap_mouse        = [];
    FAD_Delta_powerMap_mouse      = [];
    for n = 1:3
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed.mat');
        load(fullfile(saveDir,processedName),...
            'jrgeco1aCorr_ISA_powerMap','jrgeco1aCorr_Delta_powerMap')
       
        jrgeco1aCorr_ISA_powerMap_mouse   = cat(3,jrgeco1aCorr_ISA_powerMap_mouse  ,jrgeco1aCorr_ISA_powerMap);
        jrgeco1aCorr_Delta_powerMap_mouse = cat(3,jrgeco1aCorr_Delta_powerMap_mouse,jrgeco1aCorr_Delta_powerMap);

    end

    jrgeco1aCorr_ISA_powerMap_mouse   = mean(jrgeco1aCorr_ISA_powerMap_mouse  ,3);
    jrgeco1aCorr_Delta_powerMap_mouse = mean(jrgeco1aCorr_Delta_powerMap_mouse,3);

    processedName_mouse = fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,'_processed.mat'));
    if exist(processedName_mouse,'file')
        save(processedName_mouse, ...
        'jrgeco1aCorr_ISA_powerMap_mouse','jrgeco1aCorr_Delta_powerMap_mouse','-append')
    else
        save(processedName_mouse, ...
        'jrgeco1aCorr_ISA_powerMap_mouse','jrgeco1aCorr_Delta_powerMap_mouse')
    end
    jrgeco1aCorr_ISA_powerMap_mice   = cat(3,jrgeco1aCorr_ISA_powerMap_mice,  jrgeco1aCorr_ISA_powerMap_mouse);
    jrgeco1aCorr_Delta_powerMap_mice = cat(3,jrgeco1aCorr_Delta_powerMap_mice,jrgeco1aCorr_Delta_powerMap_mouse);
    
end

jrgeco1aCorr_ISA_powerMap_mice   = mean(jrgeco1aCorr_ISA_powerMap_mice  ,3);
jrgeco1aCorr_Delta_powerMap_mice = mean(jrgeco1aCorr_Delta_powerMap_mice,3);

processedName_mice = fullfile(catDir,strcat(recDate,'-',miceName,'-',sessionType,'.mat'));

if exist(processedName_mice,'file')
save(processedName_mice,...
    'jrgeco1aCorr_ISA_powerMap_mice','jrgeco1aCorr_Delta_powerMap_mice','-append')
else
    save(processedName_mice,...
    'jrgeco1aCorr_ISA_powerMap_mice','jrgeco1aCorr_Delta_powerMap_mice')
end

%%
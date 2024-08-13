clear;close all;clc
%overlap mask
excelFile = "X:\RGECO\DataBase_Xiaodan_1.xlsx";
excelRows = [181 183 185 228 232 236 202 195 204 230 234 240];
runs = 1:3;
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.darkFrameNum = excelRaw{15};
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    maskDir_new = saveDir;
    rawdataloc = excelRaw{3};
    sessionInfo.framerate = excelRaw{7};
    maskDir = strcat('E:\RGECO\Kenny\', recDate, '\');
    if exist(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'file')
        load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'xform_isbrain');
        load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-','LandmarksAndMask.mat')),'affineMarkers')
    else
        maskDir = saveDir;
        maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
        load(fullfile(maskDir,maskName),'affineMarkers','xform_isbrain','isbrain')
    end
    

    for n = runs
        tic
        visName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n));      
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        % load and filter data
        load(fullfile(saveDir,processedName),'xform_datahb')
        HbT = squeeze(xform_datahb(:,:,1,:)) + squeeze(xform_datahb(:,:,2,:));
        clear xform_datahb
        HbT_filter = filterData(HbT,0.02,2,sessionInfo.framerate);
        load(fullfile(saveDir, processedName),'xform_FADCorr')
        FAD_filter = filterData(xform_FADCorr,0.02,2,sessionInfo.framerate);
        clear xform_FADCorr
        % load(fullfile(saveDir, processedName),'xform_jrgeco1aCorr')
        % xform_jrgeco1aCorr = squeeze(xform_jrgeco1aCorr);
        % calcium_filter = filterData(xform_jrgeco1aCorr,0.02,2,sessionInfo.framerate);

        % GSR
        HbT_filter     = mouse.process.gsr(HbT_filter,xform_isbrain);
        FAD_filter     = mouse.process.gsr(FAD_filter,xform_isbrain);
        % calcium_filter = mouse.process.gsr(calcium_filter,xform_isbrain);

        % Balateral fc
        bilat_HbT     = bilateralFC_fun(HbT_filter);
        clear HbT_filter
        bilat_FAD     = bilateralFC_fun(FAD_filter);
        clear FAD_filter
        % bilat_calcium = bilateralFC_fun(calcium_filter);
        % clear calcium_filter

        save(fullfile(saveDir,processedName),'bilat_HbT','bilat_FAD','-append')
        toc
    end
end
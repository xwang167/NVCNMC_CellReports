
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
        FCMatrix_HbT_ISA = calcFCMatrix(squeeze(xform_datahb(:,:,1,:) + xform_datahb(:,:,2,:)),0.009,0.08,fs,xform_isbrain_mice);
        FCMatrix_HbT_Delta = calcFCMatrix(squeeze(xform_datahb(:,:,1,:) + xform_datahb(:,:,2,:)),0.4,4,fs,xform_isbrain_mice);
        clear xform_datahb
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        if exist(fullfile(saveDir,processedName_fcMatrix))

            save(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_HbT_ISA','FCMatrix_HbT_Delta','-append')
        else
            save(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_HbT_ISA','FCMatrix_HbT_Delta','-v7.3')
        end
        clear FCMatrix_HbT_ISA FCMatrix_HbT_Delta

    end
end


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

    saveDir_new = strcat('L:\RGECO\Kenny\', recDate, '\');
    maskName = strcat(recDate,'-',mouseName,'-',sessionType,'1-datafluor','.mat');

    if ~exist(fullfile(saveDir_new,maskName),'file')
        maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
        load(fullfile(saveDir,maskName),'xform_isbrain')
    else
        load(fullfile(saveDir_new,maskName),'xform_isbrain');
    end
    for n = runs
        visName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n));
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        disp('loading processed data')
        load(fullfile(saveDir,processedName),'xform_FADCorr');
        xform_FADCorr(isinf(xform_FADCorr)) = 0;
        xform_FADCorr(isnan(xform_FADCorr)) = 0;
        FCMatrix_FAD_ISA = calcFCMatrix(squeeze(xform_FADCorr),0.009,0.08,fs,xform_isbrain_mice);
        FCMatrix_FAD_Delta = calcFCMatrix(squeeze(xform_FADCorr),0.4,4,fs,xform_isbrain_mice);
        clear xform_FADCorr
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        if exist(fullfile(saveDir,processedName_fcMatrix))
            save(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_FAD_ISA','FCMatrix_FAD_Delta','-append')
        else
            save(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_FAD_ISA','FCMatrix_FAD_Delta','-v7.3')
        end

        clear FCMatrix_FAD_ISA FCMatrix_FAD_Delta
    end




end

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
        FCMatrix_Calcium_ISA = calcFCMatrix(squeeze(xform_jrgeco1aCorr),0.009,0.08,fs,xform_isbrain_mice);
        FCMatrix_Calcium_Delta = calcFCMatrix(squeeze(xform_jrgeco1aCorr),0.4,4,fs,xform_isbrain_mice);
        clear xform_jrgeco1aCorr
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        if exist(fullfile(saveDir,processedName_fcMatrix))
            save(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_Calcium_ISA','FCMatrix_Calcium_Delta','-append')
        else
            save(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_Calcium_ISA','FCMatrix_Calcium_Delta','-v7.3')
        end

        clear FCMatrix_Calcium_ISA FCMatrix_Calcium_Delta
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
    FCMatrix_HbT_ISA_mouse = [];
    FCMatrix_HbT_Delta_mouse = [];
    for n = runs
        processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
        load(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_HbT_ISA','FCMatrix_HbT_Delta')
        FCMatrix_HbT_ISA_mouse = cat(3,FCMatrix_HbT_ISA_mouse,FCMatrix_HbT_ISA);
        FCMatrix_HbT_Delta_mouse = cat(3,FCMatrix_HbT_Delta_mouse,FCMatrix_HbT_Delta);
    end
    FCMatrix_HbT_ISA_mouse = mean(FCMatrix_HbT_ISA_mouse,3);
    FCMatrix_HbT_Delta_mouse = mean(FCMatrix_HbT_Delta_mouse,3);
    save(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_HbT_ISA_mouse','FCMatrix_HbT_Delta_mouse','-append');
end

miceName = [];
FCMatrix_HbT_ISA_mice = [];
FCMatrix_HbT_Delta_mice = [];
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
    load(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_HbT_ISA_mouse','FCMatrix_HbT_Delta_mouse')
    FCMatrix_HbT_ISA_mice = cat(3,FCMatrix_HbT_ISA_mice,atanh(FCMatrix_HbT_ISA_mouse));
    FCMatrix_HbT_Delta_mice = cat(3,FCMatrix_HbT_Delta_mice,atanh(FCMatrix_HbT_Delta_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_HbT_ISA_mice = nanmean(FCMatrix_HbT_ISA_mice,3);
FCMatrix_HbT_Delta_mice = nanmean(FCMatrix_HbT_Delta_mice,3);
A = ones(size(FCMatrix_HbT_ISA_mice,1),size(FCMatrix_HbT_ISA_mice,2));
triup = triu(A,1);
triup = logical(triup);
B = FCMatrix_HbT_ISA_mice(triup);
histogram(B)
xlim([-3 3])
title('Averaged Across Mice, Anes, HbT, ISA')
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_HbT_ISA_mice','FCMatrix_HbT_Delta_mice','-append');


miceName = [];
FCMatrix_HbT_ISA_mice = [];
FCMatrix_HbT_Delta_mice = [];
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
    load(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_HbT_ISA_mouse','FCMatrix_HbT_Delta_mouse')
    FCMatrix_HbT_ISA_mice = cat(3,FCMatrix_HbT_ISA_mice,atanh(FCMatrix_HbT_ISA_mouse));
    FCMatrix_HbT_Delta_mice = cat(3,FCMatrix_HbT_Delta_mice,atanh(FCMatrix_HbT_Delta_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_HbT_ISA_mice = nanmean(FCMatrix_HbT_ISA_mice,3);
FCMatrix_HbT_Delta_mice = nanmean(FCMatrix_HbT_Delta_mice,3);
A = ones(size(FCMatrix_HbT_ISA_mice,1),size(FCMatrix_HbT_ISA_mice,2));
triup = triu(A,1);
triup = logical(triup);
B = FCMatrix_HbT_ISA_mice(triup);
histogram(B)
xlim([-3 3])
title('Averaged Across Mice, Awake, HbT, ISA')
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_HbT_ISA_mice','FCMatrix_HbT_Delta_mice','-append');



% excelRows = [181 183 185 228 232 236 195 202 204 230 234 240];
% for excelRow = excelRows
%     [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
%     recDate = excelRaw{1}; recDate = string(recDate);
%     mouseName = excelRaw{2}; mouseName = string(mouseName);
%     saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
%     sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
%     sessionInfo.mouseType = excelRaw{17};
%     systemType =excelRaw{5};
%     processedName_fcMatrix_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_fcMatrix_mouse','.mat');
%     FCMatrix_FAD_ISA_mouse = [];
%     FCMatrix_FAD_Delta_mouse = [];
%     for n = runs
%         processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
%         load(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_FAD_ISA','FCMatrix_FAD_Delta')
%         FCMatrix_FAD_ISA_mouse = cat(3,FCMatrix_FAD_ISA_mouse,atanh(FCMatrix_FAD_ISA));
%         FCMatrix_FAD_Delta_mouse = cat(3,FCMatrix_FAD_Delta_mouse,atanh(FCMatrix_FAD_Delta));
%     end
%     FCMatrix_FAD_ISA_mouse = mean(FCMatrix_FAD_ISA_mouse,3);
%     FCMatrix_FAD_Delta_mouse = mean(FCMatrix_FAD_Delta_mouse,3);
%     save(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_FAD_ISA_mouse','FCMatrix_FAD_Delta_mouse','-append');
% end



miceName = [];
FCMatrix_FAD_ISA_mice = [];
FCMatrix_FAD_Delta_mice = [];
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
    load(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_FAD_ISA_mouse','FCMatrix_FAD_Delta_mouse')
    FCMatrix_FAD_ISA_mice = cat(3,FCMatrix_FAD_ISA_mice,atanh(FCMatrix_FAD_ISA_mouse));
    FCMatrix_FAD_Delta_mice = cat(3,FCMatrix_FAD_Delta_mice,atanh(FCMatrix_FAD_Delta_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_FAD_ISA_mice = nanmean(FCMatrix_FAD_ISA_mice,3);
FCMatrix_FAD_Delta_mice = nanmean(FCMatrix_FAD_Delta_mice,3);
% A = ones(size(FCMatrix_FAD_ISA_mice,1),size(FCMatrix_FAD_ISA_mice,2));
% triup = triu(A,1);
% triup = logical(triup);
% B = FCMatrix_FAD_ISA_mice(triup);
% histogram(B)
% xlim([-3 3])
% title('Averaged Across Mice, Anes, FAD, ISA')
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_FAD_ISA_mice','FCMatrix_FAD_Delta_mice','-append');



miceName = [];
FCMatrix_FAD_ISA_mice = [];
FCMatrix_FAD_Delta_mice = [];
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
    load(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_FAD_ISA_mouse','FCMatrix_FAD_Delta_mouse')
    FCMatrix_FAD_ISA_mice = cat(3,FCMatrix_FAD_ISA_mice,atanh(FCMatrix_FAD_ISA_mouse));
    FCMatrix_FAD_Delta_mice = cat(3,FCMatrix_FAD_Delta_mice,atanh(FCMatrix_FAD_Delta_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_FAD_ISA_mice = nanmean(FCMatrix_FAD_ISA_mice,3);
FCMatrix_FAD_Delta_mice = nanmean(FCMatrix_FAD_Delta_mice,3);
A = ones(size(FCMatrix_FAD_ISA_mice,1),size(FCMatrix_FAD_ISA_mice,2));
triup = triu(A,1);
triup = logical(triup);
B = FCMatrix_FAD_ISA_mice(triup);
histogram(B)
xlim([-3 3])
title('Averaged Across Mice, Awake, FAD, ISA')
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_FAD_ISA_mice','FCMatrix_FAD_Delta_mice','-append');



% 
% excelRows = [181 183 185 228 232 236 195 202 204 230 234 240];
% for excelRow = excelRows
%     [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
%     recDate = excelRaw{1}; recDate = string(recDate);
%     mouseName = excelRaw{2}; mouseName = string(mouseName);
%     saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
%     sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
%     sessionInfo.mouseType = excelRaw{17};
%     systemType =excelRaw{5};
%     processedName_fcMatrix_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_fcMatrix_mouse','.mat');
%     FCMatrix_Calcium_ISA_mouse = [];
%     FCMatrix_Calcium_Delta_mouse = [];
%     for n = runs
%         processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
%         load(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_Calcium_ISA','FCMatrix_Calcium_Delta')
%         FCMatrix_Calcium_ISA_mouse = cat(3,FCMatrix_Calcium_ISA_mouse,atanh(FCMatrix_Calcium_ISA));
%         FCMatrix_Calcium_Delta_mouse = cat(3,FCMatrix_Calcium_Delta_mouse,atanh(FCMatrix_Calcium_Delta));
%     end
%     FCMatrix_Calcium_ISA_mouse = mean(FCMatrix_Calcium_ISA_mouse,3);
%     FCMatrix_Calcium_Delta_mouse = mean(FCMatrix_Calcium_Delta_mouse,3);
%     save(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_Calcium_ISA_mouse','FCMatrix_Calcium_Delta_mouse','-append');
% end

miceName = [];
FCMatrix_Calcium_ISA_mice = [];
FCMatrix_Calcium_Delta_mice = [];
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
    load(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_Calcium_ISA_mouse','FCMatrix_Calcium_Delta_mouse')
    FCMatrix_Calcium_ISA_mice = cat(3,FCMatrix_Calcium_ISA_mice,atanh(FCMatrix_Calcium_ISA_mouse));
    FCMatrix_Calcium_Delta_mice = cat(3,FCMatrix_Calcium_Delta_mice,atanh(FCMatrix_Calcium_Delta_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_Calcium_ISA_mice = nanmean(FCMatrix_Calcium_ISA_mice,3);
FCMatrix_Calcium_Delta_mice = nanmean(FCMatrix_Calcium_Delta_mice,3);
A = ones(size(FCMatrix_Calcium_ISA_mice,1),size(FCMatrix_Calcium_ISA_mice,2));
triup = triu(A,1);
triup = logical(triup);
B = FCMatrix_Calcium_ISA_mice(triup);
histogram(B)
xlim([-3 3])
title('Averaged Across Mice, Anes, Calcium, ISA')
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_Calcium_ISA_mice','FCMatrix_Calcium_Delta_mice','-append');


miceName = [];
FCMatrix_Calcium_ISA_mice = [];
FCMatrix_Calcium_Delta_mice = [];
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
    load(fullfile(saveDir,processedName_fcMatrix_mouse),'FCMatrix_Calcium_ISA_mouse','FCMatrix_Calcium_Delta_mouse')
    FCMatrix_Calcium_ISA_mice = cat(3,FCMatrix_Calcium_ISA_mice,atanh(FCMatrix_Calcium_ISA_mouse));
    FCMatrix_Calcium_Delta_mice = cat(3,FCMatrix_Calcium_Delta_mice,atanh(FCMatrix_Calcium_Delta_mouse));
end
processedName_fcMatrix_mice = strcat(recDate,'-',miceName,'-',sessionType,'_fcMatrix_mice','.mat');
FCMatrix_Calcium_ISA_mice = nanmean(FCMatrix_Calcium_ISA_mice,3);
FCMatrix_Calcium_Delta_mice = nanmean(FCMatrix_Calcium_Delta_mice,3);
A = ones(size(FCMatrix_Calcium_ISA_mice,1),size(FCMatrix_Calcium_ISA_mice,2));
triup = triu(A,1);
triup = logical(triup);
B = FCMatrix_Calcium_ISA_mice(triup);
histogram(B)
xlim([-3 3])
title('Averaged Across Mice, Awake, Calcium, ISA')
save(fullfile(saveDir_cat,processedName_fcMatrix_mice),'FCMatrix_Calcium_ISA_mice','FCMatrix_Calcium_Delta_mice','-append');





% excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
% runs = 1:3;
% excelRows = [195 202 204 230 234 240];
% 
% for excelRow = excelRows
%     [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
%     recDate = excelRaw{1}; recDate = string(recDate);
%     mouseName = excelRaw{2}; mouseName = string(mouseName);
%     saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
%     sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
%     sessionInfo.darkFrameNum = excelRaw{15};
%     sessionInfo.mouseType = excelRaw{17};
%     systemType =excelRaw{5};
%     sessionInfo.framerate = excelRaw{7};
%     systemInfo.numLEDs = 4;
%     fs = excelRaw{7};
%     
%     for n = runs
%         processedName_fcMatrix = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_fcMatrix','.mat');
%         
%         load(fullfile(saveDir,processedName_fcMatrix),'FCMatrix_HbT_ISA','FCMatrix_HbT_Delta')
%         figure
%         subplot(1,2,1)
%         imagesc(FCMatrix_HbT_ISA,[-1 1])
%         colormap jet
%         title([mouseName ', ISA'])
%         axis image
%         subplot(1,2,2)
%         imagesc(FCMatrix_HbT_Delta,[-1 1])
%         colormap jet
%         title([mouseName ', Delta'])
%         axis image
%         clear FCMatrix_HbT_ISA FCMatrix_HbT_Delta
%         saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HbT_FCMatrix.png')));
%         saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HbT_FCMatrix.fig')));
%         
%     end
% end



load('191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat', 'FCMatrix_HbT_Delta_mice')
load('191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat', 'FCMatrix_HbT_ISA_mice')
load('191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat', 'FCMatrix_FAD_Delta_mice')
load('191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat', 'FCMatrix_FAD_ISA_mice')
load('191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat', 'FCMatrix_Calcium_Delta_mice')
load('191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat', 'FCMatrix_Calcium_ISA_mice')
FCMatrix_HbT_Delta_mice_awake = FCMatrix_HbT_Delta_mice;
FCMatrix_HbT_ISA_mice_awake = FCMatrix_HbT_ISA_mice;
FCMatrix_FAD_Delta_mice_awake = FCMatrix_FAD_Delta_mice;
FCMatrix_FAD_ISA_mice_awake = FCMatrix_FAD_ISA_mice;
FCMatrix_Calcium_Delta_mice_awake = FCMatrix_Calcium_Delta_mice;
FCMatrix_Calcium_ISA_mice_awake = FCMatrix_Calcium_ISA_mice;


load('191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat', 'FCMatrix_FAD_Delta_mice')
load('191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat', 'FCMatrix_FAD_ISA_mice')
load('191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat', 'FCMatrix_HbT_Delta_mice')
load('191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat', 'FCMatrix_HbT_ISA_mice')
load('191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat', 'FCMatrix_Calcium_Delta_mice')
load('191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat', 'FCMatrix_Calcium_ISA_mice')

FCMatrix_HbT_Delta_mice_anes = FCMatrix_HbT_Delta_mice;
FCMatrix_HbT_ISA_mice_anes = FCMatrix_HbT_ISA_mice;
FCMatrix_FAD_Delta_mice_anes = FCMatrix_FAD_Delta_mice;
FCMatrix_FAD_ISA_mice_anes = FCMatrix_FAD_ISA_mice;
FCMatrix_Calcium_Delta_mice_anes = FCMatrix_Calcium_Delta_mice;
FCMatrix_Calcium_ISA_mice_anes = FCMatrix_Calcium_ISA_mice;

%Histogram for mice
figure
histogram(FCMatrix_FAD_Delta_mice_anes(triup),'FaceColor','b','EdgeColor','b')
hold on
histogram(FCMatrix_FAD_Delta_mice_awake(triup),'FaceColor','r','EdgeColor','r','FaceAlpha',0.5,'EdgeAlpha',0.5)
legend('Anesthetized','Awake')
title('FAD Delta')
xlim([-3 3])
figure
histogram(FCMatrix_FAD_ISA_mice_anes(triup),'FaceColor','b','EdgeColor','b')
hold on
histogram(FCMatrix_FAD_ISA_mice_awake(triup),'FaceColor','r','EdgeColor','r','FaceAlpha',0.5,'EdgeAlpha',0.5)
legend('Anesthetized','Awake')
title('FAD ISA')
xlim([-3 3])

figure
histogram(FCMatrix_HbT_Delta_mice_anes(triup),'FaceColor','b','EdgeColor','b')
hold on
histogram(FCMatrix_HbT_Delta_mice_awake(triup),'FaceColor','r','EdgeColor','r','FaceAlpha',0.5,'EdgeAlpha',0.5)
legend('Anesthetized','Awake')
title('HbT Delta')
xlim([-3 3])

figure
histogram(FCMatrix_HbT_ISA_mice_anes(triup),'FaceColor','b','EdgeColor','b')
hold on
histogram(FCMatrix_HbT_ISA_mice_awake(triup),'FaceColor','r','EdgeColor','r','FaceAlpha',0.5,'EdgeAlpha',0.5)
legend('Anesthetized','Awake')
title('HbT ISA')
xlim([-3 3])

figure
histogram(FCMatrix_Calcium_Delta_mice_anes(triup),'FaceColor','b','EdgeColor','b')
hold on
histogram(FCMatrix_Calcium_Delta_mice_awake(triup),'FaceColor','r','EdgeColor','r','FaceAlpha',0.5,'EdgeAlpha',0.5)
legend('Anesthetized','Awake')
title('Calcium Delta')
xlim([-3 3])
figure
histogram(FCMatrix_Calcium_ISA_mice_anes(triup),'FaceColor','b','EdgeColor','b')
hold on
histogram(FCMatrix_Calcium_ISA_mice_awake(triup),'FaceColor','r','EdgeColor','r','FaceAlpha',0.5,'EdgeAlpha',0.5)
legend('Anesthetized','Awake')
title('Calcium ISA')
xlim([-3 3])

%FC matrix for mice
figure
imagesc(real(FCMatrix_Calcium_ISA_mice_anes),[-1.5 1.5])
title('Anes Calcium ISA')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_Calcium_ISA_mice_awake),[-1.5 1.5])
title('Awake Calcium ISA')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_Calcium_Delta_mice_anes),[-1.5 1.5])
title('Anes Calcium Delta')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_Calcium_Delta_mice_awake),[-1.5 1.5])
title('Awake Calcium Delta')
colormap jet
colorbar
axis image


figure
imagesc(real(FCMatrix_FAD_ISA_mice_anes),[-1.5 1.5])
title('Anes FAD ISA')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_FAD_ISA_mice_awake),[-1.5 1.5])
title('Awake FAD ISA')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_FAD_Delta_mice_anes),[-1.5 1.5])
title('Anes FAD Delta')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_FAD_Delta_mice_awake),[-1.5 1.5])
title('Awake FAD Delta')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_HbT_ISA_mice_anes),[-1.5 1.5])
title('Anes HbT ISA')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_HbT_ISA_mice_awake),[-1.5 1.5])
title('Awake HbT ISA')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_HbT_Delta_mice_anes),[-1.5 1.5])
title('Anes HbT Delta')
colormap jet
colorbar
axis image

figure
imagesc(real(FCMatrix_HbT_Delta_mice_awake),[-1.5 1.5])
title('Awake HbT Delta')
colormap jet
colorbar
axis image

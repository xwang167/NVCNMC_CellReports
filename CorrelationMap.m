excelFile = "X:\RGECO\DataBase_Xiaodan_1.xlsx";
runs =1:3;
excelRows = [181 183 185 228 232 236 202 195 204 230 234 240];
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.darkFrameNum = excelRaw{15};
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    for n = runs
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        load(fullfile(saveDir,processedName),'xform_datahb','xform_FADCorr','xform_FAD')
        xform_HbT = squeeze(xform_datahb(:,:,1,:)+xform_datahb(:,:,2,:));
        correlation_FADHbT = nan(128,128);
        correlation_CorrFADHbT = nan(128,128);
        % load mask
        maskDir = strcat('E:\RGECO\Kenny\', recDate, '\');
        if exist(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'file')
            load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'xform_isbrain');
        else
            maskDir = saveDir;
            maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
            load(fullfile(maskDir,maskName),'xform_isbrain')
        end

        for ii = 1:128
            for jj = 1:128
                if logical(xform_isbrain(ii,jj))
                    correlation_FADHbT(ii,jj) = corr(squeeze(xform_HbT(ii,jj,:)),squeeze(xform_FAD(ii,jj,:)));
                    correlation_CorrFADHbT(ii,jj) = corr(squeeze(xform_HbT(ii,jj,:)),squeeze(xform_FADCorr(ii,jj,:)));
                end
            end
        end
        figure
        subplot(121)
        imagesc(correlation_FADHbT,[-1 1])
        axis image off
        colorbar
        title('Raw FAF and HbT')
        subplot(122)
        imagesc(correlation_CorrFADHbT,[-1 1])
        axis image off
        colorbar
        title('Corr FAF and HBT')
        colormap(brewermap(256, '-Spectral'))
        sgtitle(strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),', Correlaiton Map'))
        saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-CorrelationMap','.fig')))
        saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-CorrelationMap','.png')))
        saveName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_CorrelationMap','.mat');
        save(fullfile(saveDir,saveName),'correlation_FADHbT','correlation_CorrFADHbT')
        close all
    end
end

%% Mouse average
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.darkFrameNum = excelRaw{15};
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    correlation_FADHbT_mouse = nan(128,128,3);
    correlation_CorrFADHbT_mouse = nan(128,128,3);
    saveName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_CorrelationMap','.mat');
    for n = runs
        saveName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_CorrelationMap','.mat');
        load(fullfile(saveDir,saveName))
        correlation_FADHbT_mouse(:,:,n) = correlation_FADHbT;
        correlation_CorrFADHbT_mouse(:,:,n) = correlation_CorrFADHbT;
    end
    correlation_FADHbT_mouse = mean(correlation_FADHbT_mouse,3);
    correlation_CorrFADHbT_mouse = mean(correlation_CorrFADHbT_mouse,3);

    figure
    subplot(121)
    imagesc(correlation_FADHbT_mouse,[-1 1])
    axis image off
    colorbar
    title('Raw FAF and HbT')
    subplot(122)
    imagesc(correlation_CorrFADHbT_mouse,[-1 1])
    axis image off
    colorbar
    title('Corr FAF and HBT')
    colormap(brewermap(256, '-Spectral'))
    sgtitle(strcat(recDate,'-',mouseName,'-',sessionType,', Correlaiton Map'))
    saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,'-CorrelationMap','.fig')))
    saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,'-CorrelationMap','.png')))
    save(fullfile(saveDir,saveName_mouse),'correlation_FADHbT_mouse','correlation_CorrFADHbT_mouse')
    close all
end

%% mice average

xform_isbrain_mice = 1;
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    maskDir = strcat('E:\RGECO\Kenny\', recDate, '\');
    if exist(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'file')
        load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'xform_isbrain');
    else
        maskDir = saveDir;
        maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
        load(fullfile(maskDir,maskName),'xform_isbrain')
    end   
    xform_isbrain_mice = xform_isbrain_mice.*xform_isbrain;
end



excelRows_awake = [181 183 185 228 232 236];
excelRows_anes  = [202 195 204 230 234 240];
saveDir_cat = "E:\RGECO\cat\";
numMice = 6;

%awake
correlation_FADHbT_mice = nan(128,128,numMice);
correlation_CorrFADHbT_mice = nan(128,128,numMice);
ll = 1;
miceName = [];
for excelRow = excelRows_awake
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':R',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = char(strcat(miceName, '-', mouseName));
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.darkFrameNum = excelRaw{11};
    rawdataloc = excelRaw{3};
    systemType =excelRaw{5};
    saveName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_CorrelationMap','.mat');
    load(fullfile(saveDir,saveName_mouse))
    correlation_FADHbT_mice(:,:,ll)     = correlation_FADHbT_mouse;
    correlation_CorrFADHbT_mice(:,:,ll) = correlation_CorrFADHbT_mouse;
    ll = ll+1;
end
correlation_FADHbT_mice = median(correlation_FADHbT_mice,3);
correlation_CorrFADHbT_mice = median(correlation_CorrFADHbT_mice,3);
saveName_mice = strcat(recDate,'-',miceName,'-',sessionType,'_Correlation.mat');
save(fullfile(saveDir_cat,saveName_mice),'correlation_FADHbT_mice','correlation_CorrFADHbT_mice')

%anesthetized
correlation_FADHbT_mice = nan(128,128,numMice);
correlation_CorrFADHbT_mice = nan(128,128,numMice);
ll = 1;
miceName = [];
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
    saveName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_CorrelationMap','.mat');
    load(fullfile(saveDir,saveName_mouse))
    correlation_FADHbT_mice(:,:,ll)     = correlation_FADHbT_mouse;
    correlation_CorrFADHbT_mice(:,:,ll) = correlation_CorrFADHbT_mouse;
    ll = ll+1;
end
correlation_FADHbT_mice = median(correlation_FADHbT_mice,3);
correlation_CorrFADHbT_mice = median(correlation_CorrFADHbT_mice,3);
saveName_mice = strcat(recDate,'-',miceName,'-',sessionType,'_Correlation.mat');
save(fullfile(saveDir_cat,saveName_mice),'correlation_FADHbT_mice','correlation_CorrFADHbT_mice')

%% Visualize
load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')
load("GoodWL.mat")
mask = AtlasSeeds.*xform_isbrain_mice;
mask(isnan(mask)) = 0;
% Exclude FRP an PL
mask(mask==1)  = 0;
mask(mask==2)  = 0;
mask(mask==5)  = 0;
mask(mask==26) = 0;
mask(mask==27) = 0;
mask(mask==30) = 0;
mask(mask>1) = 1;

load("E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_Correlation.mat")
correlation_FADHbT_mice_awake = correlation_FADHbT_mice;
correlation_CorrFADHbT_mice_awake = correlation_CorrFADHbT_mice;

load("E:\RGECO\cat\191030--R5M2285-anes-R5M2286-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_Correlation.mat")
correlation_FADHbT_mice_anes = correlation_FADHbT_mice;
correlation_CorrFADHbT_mice_anes= correlation_CorrFADHbT_mice;

figure
subplot(221)
imagesc(correlation_FADHbT_mice_awake,[-1 1])
axis image off
cb = colorbar;
ylabel(cb,'r')
hold on
imagesc(xform_WL,'AlphaData',1-mask);
title('Awake b/w FAF and HbT')

subplot(222)
imagesc(correlation_CorrFADHbT_mice_awake,[-1 1])
axis image off
cb = colorbar;
ylabel(cb,'r')
hold on
imagesc(xform_WL,'AlphaData',1-mask);
title('Awake b/w Corrected FAF and HbT')

subplot(223)
imagesc(correlation_FADHbT_mice_anes,[-1 1])
axis image off
cb = colorbar;
ylabel(cb,'r')
hold on
imagesc(xform_WL,'AlphaData',1-mask);
title('Anesthesized b/w FAF and HbT')

subplot(224)
imagesc(correlation_CorrFADHbT_mice_anes,[-1 1])
axis image off
cb = colorbar;
ylabel(cb,'r')
hold on
imagesc(xform_WL,'AlphaData',1-mask);
title('Anesthetized b/w Corrected FAF and HbT')

%sgtitle('Correlation between contrasts')
colormap(brewermap(256, '-Spectral'))
excelFile = "X:\RGECO\DataBase_Xiaodan_1.xlsx";
excelRows = [182 184 186 233 237];
xform_datahb_mice_GSR = [];
for excelRow = excelRows
    
    
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':U',num2str(excelRow)]);
    
    rawdataloc = excelRaw{3};
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
   % saveDir_corrected = fullfile('X:\XW\FilteredSpectra\FilteredEmissionFilteredExcitation\WT',recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    %     xform_isbrain = ones(128,128);
    processedName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_processed_mouse','.mat');
      load(fullfile(saveDir,processedName_mouse),...
        'xform_datahb_mouse_GSR')
      figure
      imagesc(mean(xform_datahb_mouse_GSR(:,:,2,125:250),4))
    xform_datahb_mice_GSR = cat(5,xform_datahb_mice_GSR,xform_datahb_mouse_GSR);
    clear xform_datahb_mouse_GSR
end

    
xform_datahb_mice_GSR = mean(xform_datahb_mice_GSR,5);  
save('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-stim_processed_mice.mat',...
    'xform_datahb_mice_GSR','-append')
load('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc.mat',...
    'xform_isbrain_mice')
xform_isbrain_mice_awake = xform_isbrain_mice;
load('E:\RGECO\cat\191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc.mat',...
    'xform_isbrain_mice')
xform_isbrain_mice_anes = xform_isbrain_mice;
xform_isbrain_mice = xform_isbrain_mice_awake.*xform_isbrain_mice_anes;

load('noVasculatureMask.mat')
mask = (leftMask + rightMask).*xform_isbrain_mice;

load('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-stim_processed_mice.mat')
figure
ax1 = subplot(151);
imagesc(mean(xform_jrgeco1aCorr_mice_GSR(:,:,125:250),3),"AlphaData",mask)
clim([-0.015 0.015])
colormap(ax1,'inferno')
axis image off
title('jRGECO1a')

ax2 = subplot(152);
imagesc(mean(xform_FADCorr_mice_GSR(:,:,125:250),3),"AlphaData",mask)
clim([-0.006 0.006])
colormap(ax2,'viridis')
axis image off
title('FAF')

ax3 = subplot(153);
imagesc(mean(xform_datahb_mice_GSR(:,:,1,125:250),4),"AlphaData",mask)
clim([-1*10^(-6) 1*10^(-6)])
colormap(ax3,'jet')
axis image off
title('HbO')

ax4 = subplot(154);
imagesc(mean(xform_datahb_mice_GSR(:,:,2,125:250),4),"AlphaData",mask)
clim([-0.3*10^(-6) 0.3*10^(-6)])
colormap(ax4,'jet')
axis image off
title('HbR')

ax5 = subplot(155);
imagesc(mean(xform_datahb_mice_GSR(:,:,1,125:250),4)+mean(xform_datahb_mice_GSR(:,:,2,125:250),4),"AlphaData",mask)
clim([-0.7*10^(-6) 0.7*10^(-6)])
colormap(ax5,'jet')
axis image off
title('HbR')

load('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc.mat','R_total_ISA_mice')
A = R_total_ISA_mice(:,:,2);
B = isnan(A);
mask = mask.*(1-B);
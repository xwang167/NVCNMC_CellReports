clear ;close all;clc
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
freq_new     = 250;
load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')

% Overlapped brain mask
xform_isbrain_mice = 1;
for excelRow = [181 183 185 228 232 236 202 195 204 230 234 240]
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    disp(strcat(mouseName,', run #1'))
    processedName = strcat(recDate,'-',mouseName,'-',sessionType,'1_processed','.mat');
    load(fullfile(saveDir,processedName),'xform_isbrain')
    xform_isbrain_mice = xform_isbrain_mice.*xform_isbrain;
end
% Region inside of mouse brain
mask = AtlasSeeds.*xform_isbrain_mice;
mask(isnan(mask)) = 0;
% total number of pixels in all interested regions
pixelNum = zeros(1,50);
for region = 1:50
    mask_region = zeros(128,128);
    mask_region(mask == region) = 1;
    pixelNum(region) = sum(mask_region,'all');
end
pixelNumTotal = sum(pixelNum);
%% Average across all regions 
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName)
R2_MRF_mice_awake = zeros(1,6);
R2_MRF_mice_anes = zeros(1,6);
for condition = {'awake','anes'}
    h = {'MRF'};
    for mouseInd = 1:6
        for region = 1:50
            eval(strcat('temp = r_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,region)^2*pixelNum(region)/pixelNumTotal;'))
            eval(strcat( 'R2_',h{1},'_mice_',condition{1},'(mouseInd)=r_',h{1},'_mice_',condition{1},'(mouseInd)+temp;'))
            clear temp
        end
    end
end
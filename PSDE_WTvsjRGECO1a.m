close all;clear all;clc


%% Panel A Resting PDSE in anesthetized C57 and jRGECO1a mice detected by CMOS2
% % psd of raw jRGECO1a in anesthetized Thy1-jRGECO1a mice
% excelRows_anes = [ 202 195 204 230 234 240];
% runs = 1:3;
% powerdata_jrgeco1a_mice = [];
% miceName = [];
% for excelRow = excelRows_anes
%     [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
%     recDate = excelRaw{1}; recDate = string(recDate);
%     mouseName = excelRaw{2}; mouseName = string(mouseName);
%     miceName = char(strcat(miceName, '-', mouseName));
%     saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
%     sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
%     sessionInfo.darkFrameNum = excelRaw{15};
%     sessionInfo.mouseType = excelRaw{17};
%     systemType =excelRaw{5};
%     powerdata_jrgeco1a_mouse = [];
%     for n = runs
%         processedName = fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed.mat'));
%         load(processedName,'powerdata_jrgeco1a')
%         powerdata_jrgeco1a_mouse = cat(1,powerdata_jrgeco1a_mouse,powerdata_jrgeco1a);
%     end
%     powerdata_jrgeco1a_mouse = mean(powerdata_jrgeco1a_mouse);
%     processedeName_mouse = fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,'_processed.mat'));
%     if exist(processedeName_mouse,'file')
%         save(processedeName_mouse,'powerdata_jrgeco1a_mouse','-append')
%     else
%         save(processedeName_mouse,'powerdata_jrgeco1a_mouse')
%     end
%     powerdata_jrgeco1a_mice = cat(1,powerdata_jrgeco1a_mice,powerdata_jrgeco1a_mouse);
% end
% powerdata_jrgeco1a_mice = mean(powerdata_jrgeco1a_mice);
% catDir = 'E:\RGECO\cat\';
% saveName_mice = fullfile(catDir,strcat(recDate,'-',miceName,'-',sessionType,'.mat'));
% if exist(saveName_mice,'file')
%     save(saveName_mice,'powerdata_jrgeco1a_mice','-append')
% else
%     save(saveName_mice,'powerdata_jrgeco1a_mice')
% end

% excelFile = "X:\Paper1\WT\WT.xlsx";
% excelRows_anes = [ 3,5,8,12,15];
% 
% % excelFile = "X:\RGECO\DataBase_Xiaodan_1.xlsx";
% % excelRows_anes = [ 202 195 204 230 234 240];
% runs = 1:3;
% 
% miceName = [];
% powerdata_green_mice = [];
% powerdata_red_mice   = [];
% for excelRow = excelRows_anes
%     [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
%     recDate = excelRaw{1}; recDate = string(recDate);
%     mouseName = excelRaw{2}; mouseName = string(mouseName);
%     miceName = char(strcat(miceName, '-', mouseName));
%     saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
%     sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
%     sessionInfo.darkFrameNum = excelRaw{15};
%     sessionInfo.mouseType = excelRaw{17};
%     systemType =excelRaw{5};
%     maskDir = strcat('E:\RGECO\Kenny\', recDate, '\');
%     if exist(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'file')
%         load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'xform_isbrain');
%     else
%         maskDir = saveDir;
%         maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
%         load(fullfile(maskDir,maskName),'affineMarkers','xform_isbrain')
%     end
%     powerdata_green_mouse = [];
%     powerdata_red_mouse = [];
%     for n = runs
%         processedName = fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed.mat'));
%         disp('loading data')
%         load(processedName,'xform_green','xform_red')
%         [~,powerdata_green] = QCcheck_CalcPDS(xform_green/0.01,25,xform_isbrain);
%         [~,powerdata_red]   = QCcheck_CalcPDS(xform_red/0.01  ,25,xform_isbrain);
%         save(processedName,'powerdata_green','powerdata_red','-append')
%         powerdata_green_mouse = cat(1,powerdata_green_mouse,powerdata_green);
%         powerdata_red_mouse   = cat(1,powerdata_red_mouse  ,powerdata_red);
%     end
%     powerdata_green_mouse = mean(powerdata_green_mouse);
%     powerdata_red_mouse   = mean(powerdata_red_mouse);
%     processedeName_mouse = fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,'_processed.mat'));
%     if exist(processedeName_mouse,'file')
%         save(processedeName_mouse,'powerdata_green_mouse','powerdata_red_mouse','-append')
%     else
%         save(processedeName_mouse,'powerdata_green_mouse','powerdata_red_mouse')
%     end
%     powerdata_green_mice = cat(1,powerdata_green_mice,powerdata_green_mouse);
%     powerdata_red_mice   = cat(1,powerdata_red_mice  ,powerdata_red_mouse);
% end
% powerdata_green_mice = mean(powerdata_green_mice);
% powerdata_red_mice   = mean(powerdata_red_mice);
% catDir = 'E:\RGECO\cat\';
% saveName_mice = fullfile(catDir,strcat(recDate,'-',miceName,'-',sessionType,'.mat'));
% if exist(saveName_mice,'file')
%     save(saveName_mice,'powerdata_green_mice','powerdata_red_mice','-append')
% else
%     save(saveName_mice,'powerdata_green_mice','powerdata_red_mice')
% end

load('X:\Paper1\WT\cat\210830--W30M1-anes-W30M2-anes-W30M3-anes-W31M1-anes-W31M2-anes-fc.mat',...
    'powerdata_jrgeco1a_mice','powerdata_FADCorr_mice','powerdata_green_mice','powerdata_red_mice','hz')
powerdata_jrgeco1a_mice_WT = powerdata_jrgeco1a_mice;
powerdata_FADCorr_mice_WT  = powerdata_FADCorr_mice;
powerdata_green_mice_WT    = powerdata_green_mice;
powerdata_red_mice_WT      = powerdata_red_mice;

load("E:\RGECO\cat\191030--R5M2285-anes-R5M2286-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc.mat",...
    'powerdata_jrgeco1a_mice','powerdata_green_mice','powerdata_red_mice')
 load('E:\RGECO\cat\191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc.mat', 'powerdata_FADCorr_mice')

powerdata_jrgeco1a_mice_jRGECO1a = powerdata_jrgeco1a_mice;
powerdata_FADCorr_mice_jRGECO1a  = powerdata_FADCorr_mice;
powerdata_green_mice_RGECO1a     = powerdata_green_mice;
powerdata_red_mice_RGECO1a       = powerdata_red_mice;

load('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc.mat', 'powerdata_FADCorr_mice')
powerdata_FADCorr_mice_jRGECO1a_awake = powerdata_FADCorr_mice;

load('X:\Paper1\WT\cat\210830--W30M1-W30M2-W30M3-W31M1-W31M2-fc.mat', 'powerdata_FADCorr_mice')
powerdata_FADCorr_mice_WT_awake = powerdata_FADCorr_mice;

figure
subplot(221)
loglog(hz,powerdata_jrgeco1a_mice_jRGECO1a)
hold on
loglog(hz,powerdata_jrgeco1a_mice_WT)
hold on
loglog(hz,powerdata_red_mice_RGECO1a)
hold on
loglog(hz,powerdata_red_mice_WT)
xlim([0.01,10])
legend('Raw jRGECO1a fluorescence','Raw >593nm signal in C57BL/6J mice',...
    '625 reflectance for jRGECO1a mice','625 reflectance for C57BL/6J mice')
xlabel('Frequency(Hz)')
ylabel('Power((\DeltaF/F%)^2/Hz or (\DeltaR/R%)^2/Hz)')
subplot(222)
loglog(hz,powerdata_FADCorr_mice_jRGECO1a)
hold on
loglog(hz,powerdata_FADCorr_mice_WT)
hold on
loglog(hz,powerdata_green_mice_RGECO1a)
hold on
loglog(hz,powerdata_green_mice_WT)
xlim([0.01,10])
legend('Corrected FAF fluorescence, Thy1-jRGECO1a mice','Corrected FAF fluorescence, C57BL/6J mice',...
    '530 reflectance for jRGECO1a mice','530 reflectance for C57BL/6J mice')
xlabel('Frequency(Hz)')
ylabel('Power((\DeltaF/F%)^2/Hz or (\DeltaR/R%)^2/Hz)')

subplot(223)
loglog(hz,powerdata_FADCorr_mice_jRGECO1a_awake)
hold on
loglog(hz,powerdata_FADCorr_mice_WT_awake)
xlim([0.01,10])
legend('Corrected FAF fluorescence, jRGECO1a mice','Corrected FAF fluorescence, C57 mice')
xlabel('Frequency(Hz)')
ylabel('Power((\DeltaF/F%)^2/Hz')



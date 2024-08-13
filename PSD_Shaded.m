close all;clear;clc
excelRows = [181 183 185 228 232 236];
excelFile = "X:\RGECO\DataBase_Xiaodan_1.xlsx";
set(0,'defaultaxesfontsize',12);

powerdata_total_mice = [];
powerdata_jrgeco1aCorr_mice = [];
powerdata_FADCorr_mice = [];
%
miceName = [];
miceName_powerdata = [];
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':R',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = char(strcat(miceName, '-', mouseName));
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    systemType =excelRaw{5};
    processedName = strcat(recDate,'-',mouseName,'-',sessionType,'_processed.mat');
    load(fullfile(saveDir, processedName),  'powerdata_jrgeco1aCorr_mouse','powerdata_total_mouse','powerdata_FADCorr_mouse','hz')
    temp = interp1(hz,squeeze(powerdata_total_mouse),0.01);
    powerdata_total_mice = cat(1,powerdata_total_mice,squeeze(powerdata_total_mouse)/temp);
    temp = interp1(hz,squeeze(powerdata_jrgeco1aCorr_mouse),0.01);
    powerdata_jrgeco1aCorr_mice = cat(1,powerdata_jrgeco1aCorr_mice,squeeze(powerdata_jrgeco1aCorr_mouse)/temp);
    temp = interp1(hz,squeeze(powerdata_FADCorr_mouse),0.01);
    powerdata_FADCorr_mice = cat(1,powerdata_FADCorr_mice,squeeze(powerdata_FADCorr_mouse)/temp);
end

%Visualization
figure;
yyaxis left
plot_distribution_prctile(hz,10*log10(powerdata_total_mice),'Color',[0 0 0])
hold on 
plot_distribution_prctile(hz,10*log10(powerdata_FADCorr_mice),'Color',[0 1 0])
hold on
ylim([-40 5])
yyaxis right
plot_distribution_prctile(hz,10*log10(powerdata_jrgeco1aCorr_mice),'Color',[1 0 1])
set(gca, 'XScale', 'log')
xlim([0.01,10])
ylim([-40 5])

excelRows = [202 195 204 230 234 240];
powerdata_total_mice = [];
powerdata_jrgeco1aCorr_mice = [];
powerdata_FADCorr_mice = [];
%
miceName = [];
miceName_powerdata = [];
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':R',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = char(strcat(miceName, '-', mouseName));
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    systemType =excelRaw{5};
    processedName = strcat(recDate,'-',mouseName,'-',sessionType,'_processed.mat');
    load(fullfile(saveDir, processedName),  'powerdata_jrgeco1aCorr_mouse','powerdata_total_mouse','powerdata_FADCorr_mouse','hz')
    temp = interp1(hz,squeeze(powerdata_total_mouse),0.01,'linear');
    powerdata_total_mice = cat(1,powerdata_total_mice,squeeze(powerdata_total_mouse)/temp);
    temp = interp1(hz,squeeze(powerdata_jrgeco1aCorr_mouse),0.01,'linear');
    powerdata_jrgeco1aCorr_mice = cat(1,powerdata_jrgeco1aCorr_mice,squeeze(powerdata_jrgeco1aCorr_mouse)/temp);
    temp = interp1(hz,squeeze(powerdata_FADCorr_mouse),0.01,'linear');
    powerdata_FADCorr_mice = cat(1,powerdata_FADCorr_mice,squeeze(powerdata_FADCorr_mouse)/temp);
end

figure;
yyaxis left
plot_distribution_prctile(hz,10*log10(powerdata_total_mice),'Color',[0 0 0])
hold on 
plot_distribution_prctile(hz,10*log10(powerdata_FADCorr_mice),'Color',[0 1 0])
hold on
ylim([-30 15])
yyaxis right
plot_distribution_prctile(hz,10*log10(powerdata_jrgeco1aCorr_mice),'Color',[1 0 1])
set(gca, 'XScale', 'log')
xlim([0.01,10])
ylim([-30 15])

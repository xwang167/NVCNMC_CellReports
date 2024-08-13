clear all;close all;clc
excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
excelRows = [202 195 204 230 234 240];%[181 183 185 228 232 236 ];
runs = 1:3;%
load('D:\OIS_Process\noVasculatureMask.mat')

% mask without vasculature
mask = leftMask+rightMask;
h_brain_mice = nan(length(excelRows),300);
mouseInd = 1;
miceName = [];
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = strcat(miceName,'-',mouseName);
    rawdataloc = excelRaw{3};
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    saveDir_new = strcat('L:\RGECO\Kenny\', recDate, '\');
    maskName = strcat(recDate,'-',mouseName,'-',sessionType,'1-datafluor.mat');
    if ~exist(fullfile(saveDir_new,maskName),'file')
        maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask.mat');
        load(fullfile(saveDir,maskName),'xform_isbrain')
    else
        load(fullfile(saveDir_new,maskName),'xform_isbrain')
    end
    mask = logical(mask.*xform_isbrain);
    h_brain_mouse = nan(3,300);
    for n = runs
    saveName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_NVC.mat');
    load(fullfile(saveDir,saveName),'t','h')
    h = reshape(h,128*128,size(h,3),size(h,4));
    % Average over brain region without vasculature
    h_brain = squeeze(nanmean(h(mask(:),:,:)));
    % Average over blocks
    h_brain_avg = mean(h_brain,2);
    save(fullfile(saveDir,saveName),'h_brain','h_brain_avg','-append')
    h_brain_mouse(n,:) = h_brain_avg;   
    end
    h_brain_mouse = mean(h_brain_mouse);
    saveName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_NVC.mat');
    save(fullfile(saveDir,saveName_mouse),'h_brain_mouse')
    h_brain_mice(mouseInd,:) = h_brain_mouse;
    mouseInd = mouseInd + 1;
end
h_brain_mice = mean(h_brain_mice);
miceName = char(miceName);
save(strcat('L:\RGECO\cat\',recDate,'-',miceName(2:end),'_NVC.mat'),'h_brain_mice')


excelRows = [181 183 185 228 232 236 ];
h_brain_mice_awake = nan(length(excelRows),300);
mouseInd = 1;
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = strcat(miceName,'-',mouseName);
    rawdataloc = excelRaw{3};
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    saveName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_NVC.mat');
    load(fullfile(saveDir,saveName_mouse),'h_brain_mouse')
    h_brain_mice_awake(mouseInd,:) = h_brain_mouse;
    mouseInd = mouseInd + 1;
end

excelRows = [202 195 204 230 234 240];
h_brain_mice_anes = nan(length(excelRows),300);
mouseInd = 1;
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = strcat(miceName,'-',mouseName);
    rawdataloc = excelRaw{3};
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    saveName_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_NVC.mat');
    load(fullfile(saveDir,saveName_mouse),'h_brain_mouse')
    h_brain_mice_anes(mouseInd,:) = h_brain_mouse;
    mouseInd = mouseInd + 1;
end

freq = 10;
t = (-3*freq:(30-3)*freq-1)/freq;

figure
subplot(1,2,1)
plot_distribution_prctile(t,h_brain_mice_awake,'Color',[0.5 0 0.5])
ylim([-11E-3 22E-3])
xlim([-3 10])
xlabel('Time(s)')
ylabel('\Delta\muM/\DeltaF/F%')
title('Awake')
subplot(1,2,2)
plot_distribution_prctile(t,h_brain_mice_anes,'Color',[0 0 0])
ylim([-2E-3 4E-3])
xlim([-3 10])
xlabel('Time(s)')
ylabel('\Delta\muM/\DeltaF/F%')
title('Anesthetized')
sgtitle('Hemodynamic Response Function(Shaded 25% to 75%)')


h_awake = mean(h_brain_mice_awake);
h_anes = mean(h_brain_mice_anes);
figure
plot(t,h_awake,'m')
ylabel('\Delta\muM/\DeltaF/F%')
ylim([-0.01 0.02])
hold on
yyaxis right
plot(t,h_anes,'k')
ylim([-1.875E-3 3.75E-3])
xlim([-3 10])
xlabel('Time(s)')
ylabel('\Delta\muM/\DeltaF/F%')
title('Hemodynamic Response Function')
legend('Awake','Anesthetized')


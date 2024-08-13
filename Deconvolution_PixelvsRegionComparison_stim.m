clear ;close all;clc
excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
n = 1;
nVx = 128;
nVy = 128;
samplingRate =25;
freq = 10;
t = (-3*freq:(30-3)*freq-1)/freq;
load('D:\OIS_Process\noVasculatureMask.mat')
% mask without vasculature
mask = leftMask+rightMask;

%% Awake
excelRow = 182;
[~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
recDate = excelRaw{1}; recDate = string(recDate);
mouseName = excelRaw{2}; mouseName = string(mouseName);
rawdataloc = excelRaw{3};
saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
saveDir_new = strcat('L:\RGECO\Kenny\', recDate, '\');
maskName = strcat(recDate,'-',mouseName,'-',sessionType,'1-datafluor','.mat');
if ~exist(fullfile(saveDir_new,maskName),'file')
    maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
    load(fullfile(saveDir,maskName),'xform_isbrain')
else
    load(fullfile(saveDir_new,maskName),'xform_isbrain')
end
mask_overlap = xform_isbrain.*mask;
processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
load(fullfile(saveDir,processedName),'xform_datahb','xform_jrgeco1aCorr','ROI_GSR')
HbT = squeeze(xform_datahb(:,:,1,:)+xform_datahb(:,:,2,:))*10^6;% convert to muM
clear xform_datahb
Calcium = squeeze(xform_jrgeco1aCorr)*100; % convert to DeltaF/F%
clear xform_jrgeco1aCorr
% HbT(:,:,end+1) = HbT(:,:,end);
% Calcium(:,:,end+1) = Calcium(:,:,end);
%1.) Filter 0.02-2Hz, downsample to 10 Hz
HbT =  filterData(HbT,0.02,2,samplingRate);
Calcium = filterData(Calcium,0.02,2,samplingRate);

HbT = resample(HbT,freq,samplingRate,'Dimension',3); %resample to 10 Hz
Calcium = resample(Calcium,freq,samplingRate,'Dimension',3); %resample to 10 Hz

%2.) Reshape into 30 seconds
HbT=reshape(HbT,128,128,30*freq,[]);
Calcium=reshape(Calcium,128,128,30*freq,[]);


%% Awake ROI regional time course
HbT_ROI = reshape(HbT(:,:,:,2),128*128,[]);
Calcium_ROI = reshape(Calcium(:,:,:,2),128*128,[]);

HbT_ROI = mean(HbT_ROI(ROI_GSR(:),:));
Calcium_ROI = mean(Calcium_ROI(ROI_GSR(:),:));

HbT_ROI = squeeze(HbT_ROI');
Calcium_ROI = squeeze(Calcium_ROI');

X = convmtx(Calcium_ROI,length(Calcium_ROI));% why calculating convolution matrix for input? 599*300?
X = X(1:length(Calcium_ROI),1:length(Calcium_ROI));% make it square?
[~,S,~]=svd(X);
h_region_ROI = (X'*S*X+(S(1,1).^2)*.5*eye(length(Calcium_ROI))) \ (X'*S*[zeros(3*freq,1); HbT_ROI(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?

HbT_ROI_pred = conv(Calcium_ROI,h_region_ROI);
HbT_ROI_pred = HbT_ROI_pred(1:(length(HbT_ROI)+3*freq));
r_region_ROI = corr(HbT_ROI,HbT_ROI_pred(3*freq+1:end));

figure
subplot(2,2,1)
plot((1:300)/freq,HbT_ROI,'k')
ylabel('\Delta\muM')
ylim([-4 4])
hold on
yyaxis right
plot((1:300)/freq,Calcium_ROI,'m')
legend('HbT','jRGECO1a')
ylim([-5 5])
ylabel('\DeltaF/F%')
xlabel('Time(s)')
title('Time Course for ROI Cortex')

subplot(2,2,2)
plot(t,h_region_ROI)
xlim([-3 10])
ylim([-0.01 0.03])
ylabel('\Delta\muM/\DeltaF/F%')
xlabel('Time(s)')
title('HRF for ROI Cortex')

subplot(2,2,3)
plot((1:300)/freq,HbT_ROI,'k')
hold on
plot((1:300)/freq,HbT_ROI_pred(3*freq+1:3*freq+length(HbT_ROI)),'Color',[0 0.5 0])
xlabel('Time(s)')
ylabel('\Delta\muM')
legend('Actual HbT','Predicted HbT')
title(strcat('r = ',r_region_ROI))

sgtitle('HRF for ROI Region, 0.02-2Hz, Awake R5M2285 for Second Block for Run 1')


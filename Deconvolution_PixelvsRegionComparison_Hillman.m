clear ;close all;clc
excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
n = 1;
nVx = 128;
nVy = 128;
samplingRate =25;
freq = 10;
load('D:\OIS_Process\noVasculatureMask.mat')
% mask without vasculature
mask = leftMask+rightMask;
load('AtlasandIsbrain.mat','AtlasSeeds')
mask_barrel = AtlasSeeds==9;
%% Awake
excelRow = 181;
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
load(fullfile(saveDir,processedName),'xform_datahb','xform_jrgeco1aCorr')
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

%% Awake HRF for each pixel
%2.) Time course for [x,y] = [23,72]
r_pixel = nan(nVy,nVx);
h_pixel = nan(nVy,nVx,30*freq,size(HbT,4));
for ii = 1:nVy
    for jj = 1:nVx
        if mask_barrel(ii,jj)
            HbT_ori = squeeze(HbT(ii,jj,:,2));
            Calcium_ori =squeeze(Calcium(ii,jj,:,2));
            
            X = convmtx(Calcium_ori,length(Calcium_ori));% why calculating convolution matrix for input? 599*300?
            X = X(1:length(Calcium_ori),1:length(Calcium_ori));% make it square?
            h_pixel(ii,jj,:,2)= (X'*X+.01*eye(length(Calcium_ori))) \ (X'*HbT_ori);% why add 3s of zeros? Do we need to shift it?
            
            HbT_pred = conv(Calcium_ori,squeeze(h_pixel(ii,jj,:,2)));
            r_pixel(ii,jj) = corr(HbT_ori,HbT_pred(1:length(HbT_ori)));
        end
    end
end

HbT_ori = squeeze(HbT(72,23,:,2));
Calcium_ori = squeeze(Calcium(72,23,:,2));

X = convmtx(Calcium_ori,length(Calcium_ori));% why calculating convolution matrix for input? 599*300?
X = X(1:length(Calcium_ori),1:length(Calcium_ori));% make it square?
h_pixel_barrel_onePixel= (X'*X+0.01*eye(length(Calcium_ori))) \(X'*HbT_ori);% why add 3s of zeros? Do we need to shift it?
HbT_pred = conv(Calcium_ori,h_pixel_barrel_onePixel);
%HbT_pred = conv(Calcium_ori,squeeze(h_pixel(72,23,:,2)));

r_pixel_barrel = nanmean(r_pixel(:));


figure
subplot(2,2,1)
plot((1:length(HbT_ori))/freq,HbT_ori,'k')
ylim([-4 4])
ylabel('\Delta\muM')
hold on
yyaxis right
plot((1:length(Calcium_ori))/freq,Calcium_ori,'m')
ylim([-5 5])
legend('HbT','jRGECO1a')
ylabel('\DeltaF/F%')
xlabel('Time(s)')
title('Time Course for One Pixel')

subplot(2,2,2)
plot((1:length(h_pixel_barrel_onePixel))/freq,squeeze(h_pixel_barrel_onePixel))
xlim([0 30])

ylabel('\Delta\muM/\DeltaF/F%')
xlabel('Time(s)')
title('HRF for One Pixel')

subplot(2,2,3)
plot((1:length(HbT_ori))/freq,HbT_ori,'k')
hold on
plot((1:length(Calcium_ori))/10,HbT_pred(1:length(HbT_ori)),'Color',[0 0.5 0])
xlabel('Time(s)')
ylabel('\Delta\muM')
legend('Actual HbT','Predicted HbT')
title(strcat('r = ',num2str(r_pixel(72,23))))

subplot(2,2,4)
imagesc(r_pixel,[0.95 1])
axis image off
hold on
scatter(23,72,'k')
colormap jet
colorbar
title(strcat('r_{mean} = ',num2str(r_pixel_barrel)))

sgtitle('HRF for Each Pixel, 0.02-2Hz, Awake R5M2285 for Second Block for Run 1')


%% Awake Barrel regional time course
HbT_barrel = reshape(HbT(:,:,:,2),128*128,[]);
Calcium_barrel = reshape(Calcium(:,:,:,2),128*128,[]);

HbT_barrel = mean(HbT_barrel(mask_barrel(:),:));
Calcium_barrel = mean(Calcium_barrel(mask_barrel(:),:));

HbT_barrel = squeeze(HbT_barrel');
Calcium_barrel = squeeze(Calcium_barrel');

X = convmtx(Calcium_barrel,length(Calcium_barrel));% why calculating convolution matrix for input? 599*300?
X = X(1:length(Calcium_barrel),1:length(Calcium_barrel));% make it square?
h_region_barrel = (X'*X+0.01*eye(length(Calcium_barrel))) \ (X'*HbT_barrel);% why add 3s of zeros? Do we need to shift it?

HbT_barrel_pred = conv(Calcium_barrel,h_region_barrel);
r_region_barrel = corr(HbT_barrel,HbT_barrel_pred(1: length(HbT_barrel)));

figure
subplot(2,2,1)
plot((1:length(HbT_barrel))/freq,HbT_barrel,'k')
ylabel('\Delta\muM')
ylim([-4 4])
hold on
yyaxis right
plot((1:length(Calcium_barrel))/freq,Calcium_barrel,'m')
legend('HbT','jRGECO1a')
ylim([-5 5])
ylabel('\DeltaF/F%')
xlabel('Time(s)')
title('Time Course for Barrel Cortex')

subplot(2,2,2)
plot((1:length(h_region_barrel))/freq,h_region_barrel)
ylabel('\Delta\muM/\DeltaF/F%')
xlabel('Time(s)')
title('HRF for Barrel Cortex')

subplot(2,2,3)
plot((1:length(HbT_barrel))/freq,HbT_barrel,'k')
hold on
plot((1:length(HbT_barrel))/freq,HbT_barrel_pred(1:length(HbT_barrel)),'Color',[0 0.5 0])
xlabel('Time(s)')
ylabel('\Delta\muM')
legend('Actual HbT','Predicted HbT')
title(strcat('r = ',r_region_barrel))


sgtitle('HRF for Barrel Region, 0.02-2Hz, Awake R5M2285 for Second Block for Run 1')


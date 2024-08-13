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
            HbT_ori = tukeywin(length(squeeze(HbT(ii,jj,:,2))),.3).*squeeze(HbT(ii,jj,:,2));
            Calcium_ori = tukeywin(length(squeeze(Calcium(ii,jj,:,2))),.3).*squeeze(Calcium(ii,jj,:,2));
            
            X = convmtx(Calcium_ori,length(Calcium_ori));% why calculating convolution matrix for input? 599*300?
            X = X(1:length(Calcium_ori),1:length(Calcium_ori));% make it square?
            [~,S,~]=svd(X);
            h_pixel(ii,jj,:,2)= (X'*S*X+(S(1,1).^3)*.01*eye(length(Calcium_ori))) \ (X'*S*[zeros(3*freq,1); HbT_ori(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
            
            HbT_pred = conv(Calcium_ori,squeeze(h_pixel(ii,jj,:,2)));
            HbT_pred = HbT_pred(1:(length(HbT_ori)+3*freq));
            r_pixel(ii,jj) = corr(HbT_ori,HbT_pred(3*freq+1:end));
        end
    end
end

HbT_ori = tukeywin(length(squeeze(HbT(72,23,:,2))),.3).*squeeze(HbT(72,23,:,2));
Calcium_ori = tukeywin(length(squeeze(Calcium(72,23,:,2))),.3).*squeeze(Calcium(72,23,:,2));

X = convmtx(Calcium_ori,length(Calcium_ori));% why calculating convolution matrix for input? 599*300?
X = X(1:length(Calcium_ori),1:length(Calcium_ori));% make it square?
[~,S,~]=svd(X);
h_pixel_barrel_onePixel= (X'*S*X+(S(1,1).^2)*.5*eye(length(Calcium_ori))) \ (X'*S*[zeros(3*freq,1); HbT_ori(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
HbT_pred = conv(Calcium_ori,h_pixel_barrel_onePixel);
%HbT_pred = conv(Calcium_ori,squeeze(h_pixel(72,23,:,2)));

r_pixel_barrel = nanmean(r_pixel(:));


figure
subplot(2,2,1)
plot((1:300)/10,HbT_ori,'k')
ylim([-4 4])
ylabel('\Delta\muM')
hold on
yyaxis right
plot((1:300)/10,Calcium_ori,'m')
ylim([-5 5])
legend('HbT','jRGECO1a')
ylabel('\DeltaF/F%')
xlabel('Time(s)')
title('Time Course for One Pixel')

subplot(2,2,2)
plot(t,squeeze(h_pixel(72,23,:,2)))
xlim([-3 10])
ylim([-0.01 0.03])
ylabel('\Delta\muM/\DeltaF/F%')
xlabel('Time(s)')
title('HRF for One Pixel')

subplot(2,2,3)
plot((1:300)/10,HbT_ori,'k')
hold on
plot((1:300)/10,HbT_pred(3*freq+1:3*freq+length(HbT_ori)),'Color',[0 0.5 0])
xlabel('Time(s)')
ylabel('\Delta\muM')
legend('Actual HbT','Predicted HbT')
title(strcat('r = ',num2str(r_pixel(72,23))))

subplot(2,2,4)
imagesc(r_pixel,[0.6 0.85])
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

HbT_barrel = tukeywin(length(HbT_barrel),.3).*squeeze(HbT_barrel');
Calcium_barrel = tukeywin(length(Calcium_barrel),.3).*squeeze(Calcium_barrel');

X = convmtx(Calcium_barrel,length(Calcium_barrel));% why calculating convolution matrix for input? 599*300?
X = X(1:length(Calcium_barrel),1:length(Calcium_barrel));% make it square?
[~,S,~]=svd(X);
h_region_barrel = (X'*S*X+(S(1,1).^2)*.5*eye(length(Calcium_barrel))) \ (X'*S*[zeros(3*freq,1); HbT_barrel(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?

HbT_barrel_pred = conv(Calcium_barrel,h_region_barrel);
HbT_barrel_pred = HbT_barrel_pred(1:(length(HbT_barrel)+3*freq));
r_region_barrel = corr(HbT_barrel,HbT_barrel_pred(3*freq+1:end));

figure
subplot(2,2,1)
plot((1:300)/10,HbT_barrel,'k')
ylabel('\Delta\muM')
ylim([-4 4])
hold on
yyaxis right
plot((1:300)/10,Calcium_barrel,'m')
legend('HbT','jRGECO1a')
ylim([-5 5])
ylabel('\DeltaF/F%')
xlabel('Time(s)')
title('Time Course for Barrel Cortex')

subplot(2,2,2)
plot(t,h_region_barrel)
xlim([-3 10])
ylim([-0.01 0.03])
ylabel('\Delta\muM/\DeltaF/F%')
xlabel('Time(s)')
title('HRF for Barrel Cortex')

subplot(2,2,3)
plot((1:300)/10,HbT_barrel,'k')
hold on
plot((1:300)/10,HbT_barrel_pred(3*freq+1:3*freq+length(HbT_ori)),'Color',[0 0.5 0])
xlabel('Time(s)')
ylabel('\Delta\muM')
legend('Actual HbT','Predicted HbT')
title(strcat('r = ',num2str(r_region_barrel)))

sgtitle('HRF for Barrel Region, 0.02-2Hz, Awake R5M2285 for Second Block for Run 1')

%% Anes
excelRow = 202;
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
%1.) Filter 0.04-2Hz, downsample to 10 Hz
HbT =  filterData(HbT,0.04,2,samplingRate);
Calcium = filterData(Calcium,0.04,2,samplingRate);

HbT = resample(HbT,freq,samplingRate,'Dimension',3); %resample to 10 Hz
Calcium = resample(Calcium,freq,samplingRate,'Dimension',3); %resample to 10 Hz

%2.) Reshape into 30 seconds
HbT=reshape(HbT,128,128,30*freq,[]);
Calcium=reshape(Calcium,128,128,30*freq,[]);
% 
% %2.) Time course for [x,y] = [23,72]
% h = nan(nVy,nVx,30*freq,size(HbT,4));
% for ii = 1:nVy
%     for jj = 1:nVx
%         if mask_overlap(ii,jj)
%             HbT_ori = tukeywin(length(squeeze(HbT(ii,jj,:,2))),.3).*squeeze(HbT(ii,jj,:,2));
%             HbT_ori_shift = [zeros(3*freq,1); HbT_ori(1:end-3*freq)];
%             Calcium_ori = tukeywin(length(squeeze(Calcium(ii,jj,:,2))),.3).*squeeze(Calcium(ii,jj,:,2));
%             
%             X = convmtx(Calcium_ori,length(Calcium_ori));% why calculating convolution matrix for input? 599*300?
%             X = X(1:length(Calcium_ori),1:length(Calcium_ori));% make it square?
%             [~,S,~]=svd(X);
%             h(ii,jj,:,2)= (X'*S*X+(S(1,1).^2)*.5*eye(length(Calcium_ori))) \ (X'*S*[zeros(3*freq,1); HbT_ori(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
%             
%             HbT_pred = conv(Calcium_ori,squeeze(h(ii,jj,:,2)));
%             HbT_pred = HbT_pred(1:length(HbT_ori));
%             r(ii,jj) = corr(HbT_ori_shift,HbT_pred);
%         end
%     end
% end


out=squeeze(HbT(72,23,:,2));
in=squeeze(Calcium(72,23,:,2));

   X = convmtx(in,length(in));% why calculating convolution matrix for input? 599*300?
   X=X(1:length(in),1:300);
   [~,S,~]=svd(X);
   
   h_hill= (X'*X+S(1,1)*.01*eye(300) ) \X'*out;
   
   h_hill= (X'*X+(S(1,1).^2)*.5*eye(300) ) \X'*out;
   
HbT_ori = tukeywin(length(squeeze(HbT(72,23,:,2))),.3).*squeeze(HbT(72,23,:,2));
Calcium_ori = tukeywin(length(squeeze(Calcium(72,23,:,2))),.3).*squeeze(Calcium(72,23,:,2));

   X = convmtx(Calcium_ori,length(Calcium_ori));% why calculating convolution matrix for input? 599*300?
            X = X(1:length(Calcium_ori),1:length(Calcium_ori));% make it square?
            [~,S,~]=svd(X);
            h= (X'*S*X+(S(1,1).^3)*.001*eye(length(Calcium_ori))) \ (X'*S*[zeros(3*freq,1); HbT_ori(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
            
            X = X(1:length(Calcium_ori),1:50);% make it square?
            h2= (X'*S*X+(S(1,1).^3)*.01*eye(50)) \ (X'*[zeros(3*freq,1); HbT_ori(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?

HbT_pred = conv(Calcium_ori,h);





r = corr(HbT_pred(31:330),HbT_ori);
figure
subplot(2,2,1)
plot((1:300)/10,HbT_ori,'k')
ylabel('\Delta\muM')
hold on
yyaxis right
plot((1:300)/10,Calcium_ori,'m')
legend('HbT','jRGECO1a')
ylabel('\DeltaF/F%')
xlabel('Time(s)')
title('Time Course for One Pixel')

subplot(2,2,2)
plot(t,h)
xlim([-3 10])
ylabel('\Delta\muM/\DeltaF/F%')
xlabel('Time(s)')
title('HRF for One Pixel')

subplot(2,2,3)
plot((1:300)/10,HbT_ori,'k')
hold on
plot((1:300)/10,HbT_pred(31:330),'Color',[0 0.5 0])
xlabel('Time(s)')
ylabel('\Delta\muM')
legend('Actual HbT','Predicted HbT')
title(strcat('r = ',num2str(r)))

subplot(2,2,4)
imagesc(r,[-0.7 0.7])
axis image off
hold on
scatter(23,72,'k')
colormap jet
colorbar
title('r')

sgtitle('Anesthetized R5M2285 for Second Block for Run 1')
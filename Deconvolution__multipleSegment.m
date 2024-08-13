clear ;close all;clc
excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";
n = 3;
nVx = 128;
nVy = 128;
samplingRate =25;
freq = 10;
t = (-3*freq:(30-3)*freq-1)/freq;

load('AtlasandIsbrain.mat','AtlasSeeds')
mask_barrel = AtlasSeeds==9;


excelRow = 181;
[~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
recDate = excelRaw{1}; recDate = string(recDate);
mouseName = excelRaw{2}; mouseName = string(mouseName);
saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);


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


for ii = 10
    HbT_barrel = reshape(HbT(:,:,:,ii),128*128,[]);
    Calcium_barrel = reshape(Calcium(:,:,:,ii),128*128,[]);
    
    HbT_barrel = mean(HbT_barrel(mask_barrel(:),:));
    Calcium_barrel = mean(Calcium_barrel(mask_barrel(:),:));
    
    HbT_barrel = tukeywin(length(HbT_barrel),.3).*squeeze(HbT_barrel');
    Calcium_barrel = tukeywin(length(Calcium_barrel),.3).*squeeze(Calcium_barrel');
    
    X = convmtx(Calcium_barrel,length(Calcium_barrel));% why calculating convolution matrix for input? 599*300?
    X = X(1:length(Calcium_barrel),1:length(Calcium_barrel));% make it square?
    [~,S,~]=svd(X);
    h_region_barrel = (X'*S*X+(S(1,1).^3)*0.0005*eye(length(Calcium_barrel))) \ (X'*S*[zeros(3*freq,1); HbT_barrel(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
    
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
    ylim([-0.05 0.1])
    ylabel('\Delta\muM/\DeltaF/F%')
    xlabel('Time(s)')
    title('HRF for Barrel Cortex')
    
    subplot(2,2,3)
    plot((1:300)/10,HbT_barrel,'k')
    hold on
    plot((1:300)/10,HbT_barrel_pred(3*freq+1:3*freq+length(HbT_barrel)),'Color',[0 0.5 0])
    xlabel('Time(s)')
    ylabel('\Delta\muM')
    legend('Actual HbT','Predicted HbT')
    title(strcat('r = ',num2str(r_region_barrel)))
    ylim([-2 2])
    
    
    HbT_barrel_filter = lowpass(HbT_barrel,1,samplingRate);
    r_region_barrel_filter = corr(HbT_barrel_filter,HbT_barrel_pred(3*freq+1:end));
    subplot(2,2,4)
    plot((1:300)/10,HbT_barrel_filter,'r')
    hold on
    plot((1:300)/10,HbT_barrel_pred(3*freq+1:3*freq+length(HbT_barrel_filter)),'Color',[0 0.5 0])
    xlabel('Time(s)')
    ylabel('\Delta\muM')
    legend('1Hz Low Passed Actual HbT','Predicted HbT')
    title(strcat('r = ',num2str(r_region_barrel_filter)))
    
    sgtitle(strcat('HRF for Barrel Region, 0.02-2Hz, lambda = 0.0005, Awake R5M2285 Run 3, Segment #',num2str(ii)))
end


for ii = 9
    HbT_barrel = reshape(HbT(:,:,:,ii),128*128,[]);
    Calcium_barrel = reshape(Calcium(:,:,:,ii),128*128,[]);
    
    HbT_barrel = mean(HbT_barrel(mask_barrel(:),:));
    Calcium_barrel = mean(Calcium_barrel(mask_barrel(:),:));
    
    HbT_barrel = tukeywin(length(HbT_barrel),.3).*squeeze(HbT_barrel');
    Calcium_barrel = tukeywin(length(Calcium_barrel),.3).*squeeze(Calcium_barrel');
    
    X = convmtx(Calcium_barrel,length(Calcium_barrel));% why calculating convolution matrix for input? 599*300?
    X = X(1:length(Calcium_barrel),1:length(Calcium_barrel));% make it square?
    [~,S,~]=svd(X);
    h_region_barrel = (X'*S*X+(S(1,1).^3)*0.0005*eye(length(Calcium_barrel))) \ (X'*S*[zeros(3*freq,1); HbT_barrel(1:end-3*freq)]);% why add 3s of zeros? Do we need to shift it?
    
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
    ylabel('\Delta\muM/\DeltaF/F%')
    xlabel('Time(s)')
    title('HRF for Barrel Cortex')
    
    subplot(2,2,3)
    plot((1:300)/10,HbT_barrel,'k')
    hold on
    plot((1:300)/10,HbT_barrel_pred(3*freq+1:3*freq+length(HbT_barrel)),'Color',[0 0.5 0])
    xlabel('Time(s)')
    ylabel('\Delta\muM')
    legend('Actual HbT','Predicted HbT')
    title(strcat('r = ',num2str(r_region_barrel)))
    ylim([-2 2])
    
    
    HbT_barrel_filter = lowpass(HbT_barrel,1,samplingRate);
    r_region_barrel_filter = corr(HbT_barrel_filter,HbT_barrel_pred(3*freq+1:end));
    subplot(2,2,4)
    plot((1:300)/10,HbT_barrel_filter,'r')
    hold on
    plot((1:300)/10,HbT_barrel_pred(3*freq+1:3*freq+length(HbT_barrel_filter)),'Color',[0 0.5 0])
    xlabel('Time(s)')
    ylabel('\Delta\muM')
    legend('1Hz Low Passed Actual HbT','Predicted HbT')
    title(strcat('r = ',num2str(r_region_barrel_filter)))
    
    sgtitle(strcat('HRF for Barrel Region, 0.02-2Hz, lambda = 0.0005, Awake R5M2285 Run 3, Segment #',num2str(ii)))
end

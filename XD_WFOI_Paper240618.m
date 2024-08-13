load('X:\Paper1\XiaodanPaperData\cat\deconvolution_allRegions.mat','MRF_mice_awake_allRegions','MRF_mice_anes_allRegions','HRF_mice_awake_allRegions','HRF_mice_anes_allRegions')
% This is the Atlas I used for different regions
load('X:\Paper1\XiaodanPaperData\AtlasandIsbrain_Allen.mat','AtlasSeeds')
load("X:\Paper1\XiaodanPaperData\FullFCMatrices\Pwelch_regions.mat")
tmpFile=matfile('X:\Paper1\XiaodanPaperData\FullFCMatrices\fullfc.mat')
% fc_group_anes=tmpFile.fc_group_anes;
% fc_group_awake=tmpFile.fc_group_awake;
% fc_anes_avg=squeeze(tanh(mean(atanh(fc_group_anes),'3','omitnan')));
% fc_awake_avg=squeeze(tanh(mean(atanh(fc_group_awake),'3','omitnan')));
% save('G:\XiaodanPaperData\FullFCMatrices\fullfc_avgs.mat','fc_anes_avg','fc_awake_avg','-v7.3')
% 
tmpFile=matfile('X:\Paper1\XiaodanPaperData\FullFCMatrices\fullfc_avgs.mat')

fc_anes_avg=tmpFile.fc_anes_avg;
fc_awake_avg=tmpFile.fc_awake_avg;


pdse_anes=cat(4,pwelch_regions_Calcium_mice_anes  ,pwelch_regions_FAD_mice_anes, pwelch_regions_HbT_mice_anes);
pdse_awake=cat(4,pwelch_regions_Calcium_mice_awake,pwelch_regions_FAD_mice_awake,pwelch_regions_HbT_mice_awake);

irf_anes=  cat(4,MRF_mice_anes_allRegions   ,HRF_mice_anes_allRegions); %MRF then IRF
irf_awake= cat(4,MRF_mice_awake_allRegions  ,HRF_mice_awake_allRegions); %MRF then IRF

fs=25;

%% Create fake matrices
time=0; %Lag gradient over the cortex
lag_shift=repmat(linspace(0,time,25),1,2); %same for left and right cortex
%Get data and make the left and right side the same
    tmp_calc_awake=squeeze(mean(pdse_awake(:,:,:,1),1,'omitnan')); %Group average Calcium
    tmp_calc_awake=reshape(tmp_calc_awake,[],25,2);
    tmp_calc_awake=mean(tmp_calc_awake,3,'omitnan');
    tmp_calc_awake=cat(2,tmp_calc_awake,tmp_calc_awake);    
    hz=linspace(0,12.5,(2^nextpow2(10*25*60/8))+1);
%Build random data
    Z=normrnd(0,1,[1,30000]); %build normal data
    AxxNormal_awake=fft(Z); AxxNormal_awake=AxxNormal_awake(:); %First term is the DC, center term+1 is the nyquiest
%Initialize
SurrogateData=nan(30000,size(tmp_calc_awake,2));
SurrogateDataConv=nan(30000,size(tmp_calc_awake,2));

for regions=1:size(tmp_calc_awake,2)
%Select regional PSDE
    Pxx=tmp_calc_awake(:,regions)';
%Phase shift
    f_vec=linspace(0,fs/2,10*fs*60)';
    f_vec=[f_vec; 0];
    f_vec=[f_vec;-1*flipud(f_vec(2:end-1))];
%Upsample the data to get better fidelity
    Pxx_int = interp1(hz(:), Pxx(:), linspace(0,fs/2,10*fs*60+1)', 'pchip');
    TwoSidedPxx =  [Pxx_int;flipud(Pxx_int(2:end-1))];
    PxxSurrogate=AxxNormal_awake.*sqrt(TwoSidedPxx*8); %the 12 is here because of how the pwelch splits power into 12 segments!
% Introduce phase shift    
    phase = exp(1i *-2*pi*lag_shift(regions).*f_vec);
    PxxSurrogate = PxxSurrogate .* phase;  
    SurrogateData(:,regions)=ifft(PxxSurrogate);
%Convolve group average IRF or regional IRF
    SurrogateDataConv(:,regions)=conv(SurrogateData(:,regions),resample(squeeze(mean(HRF_mice_awake_allRegions(:,:,regions),1)),50,250),'same');
%     SurrogateDataConv(:,regions)=conv(SurrogateData(:,regions),resample(squeeze(mean(HRF_mice_anes_allRegions,[1,3],'omitnan')),50,250),'same');
end
data2plot=SurrogateData;

SurrogateData_gsr=nan(size(data2plot));
%GSR
for i=1:50
    p = polyfit(squeeze(mean(data2plot,2)),data2plot(:,i), 1);
    y_fit = polyval(p, data2plot(:,i));
    SurrogateData_gsr(:,i)= data2plot(:,i) - y_fit;
end

figure
subplot(221)
    test=corr(data2plot,data2plot);
    imagesc(test); caxis([-1 1])
    xlabel('Region')
    ylabel('Region')
    colormap(brewermap(256,'-Spectral')); c=colorbar;
    axis image
    title('Correlation Matrix, Same Phase')
    xticks([]);yticks([])
% subplot(232)
%     plot(test(2:end,1))
%     xlabel('Region')
%     ylabel('Correlation')
%     title('Single Row')
%     axis square
%     ylim([-1 1]);xlim([0 50])
subplot(222)
    hist(test(:),numel(test(:)))
    xlabel('Correlation')
    ylabel('Counts')
    title('Correlation Histogram')
    axis square  
    xlim([-1 1])

subplot(223)
    test2=corr(SurrogateData_gsr,SurrogateData_gsr);
    imagesc(test2); caxis([-1 1])
    xlabel('Region')
    ylabel('Region')
    colormap(brewermap(256,'-Spectral')); c=colorbar;
    axis image
    title('Correlation Matrix, Same Phase')
    xticks([]);yticks([])
% subplot(235)
%     plot(test2(2:end,1))
%     xlabel('Region')
%     ylabel('Correlation')
%     title('Single Row')
%     axis square
%     ylim([-1 1]);xlim([0 50])
subplot(224)
    hist(test2(:),numel(test2(:)))
    xlabel('Correlation')
    ylabel('Counts')
    title('Correlation Histogram')
    axis square  
    xlim([-1 1])

%% Example
t=linspace(0,600,size(SurrogateData,1));
close all
fh=figure('Position',[1 49 1900 900]);
subplot(321)
    plot(t,squeeze(mean(data2plot,2)),'k'); hold on
    plot(t,SurrogateData(:,5),'r'); hold on
    legend({'Global Signal','Region 1'})
    ylim([-6 6]); box off;   
    title(['Correlation of: ',num2str(round(corr(squeeze(mean(data2plot,2)),squeeze(SurrogateData(:,5))),2))])
xlim([0 30])    
subplot(323)
hold off
    p = polyfit(squeeze(mean(data2plot,2)),SurrogateData(:,5), 1);
    p
%     p = polyfit(SurrogateData(:,5),squeeze(mean(data2plot,2)), 1);
    toPlot1= SurrogateData(:,5) - polyval(p, SurrogateData(:,5));
    plot(t,squeeze(SurrogateData(:,5)),'r'); hold on  
    plot(t, polyval(p, SurrogateData(:,5)),'b'); 
    corr(SurrogateData(:,5),polyval(p, SurrogateData(:,5)))
    title({['Correlation of: ',num2str(round(corr(SurrogateData(:,5),polyval(p, SurrogateData(:,5))),2))],...
        'gsr-signal (i.e., the residual) is just a scaled of the non-gsr, and is SMALLER than og signal'})
    legend({'Region 1','Polyval Signal'})
    corr(SurrogateData(:,5),toPlot1)
xlim([0 30])    
subplot(322)
    plot(t,squeeze(mean(data2plot,2)),'k'); hold on
    plot(t,SurrogateData(:,7),'r'); hold on
    legend({'Global Signal','Region 2'})
    ylim([-6 6]); box off;   
    title(['Correlation of: ',num2str(round(corr(squeeze(mean(data2plot,2)),squeeze(SurrogateData(:,7))),2))])
xlim([0 30])    
subplot(324)
hold off
    p = polyfit(squeeze(mean(data2plot,2)),SurrogateData(:,7), 1);
    p
%     p = polyfit(SurrogateData(:,7),squeeze(mean(data2plot,2)), 1);
    toPlot1= SurrogateData(:,7) - polyval(p, SurrogateData(:,7));
    plot(t, polyval(p, SurrogateData(:,7)),'b'); hold on    
    plot(t,squeeze(SurrogateData(:,7)),'r'); hold on  
    corr(SurrogateData(:,7),polyval(p, SurrogateData(:,7)))
    title({['Correlation of: ',num2str(round(corr(SurrogateData(:,7),polyval(p, SurrogateData(:,7))),2))],...
        'gsr-signal (i.e., the residual) is just a scaled of the non-gsr, and is LARGER than og signal'})%     plot(toPlot1); 
    corr(SurrogateData(:,7),toPlot1)
    ylim([-6 6]); box off;   
    legend({'Region 2','Polyval Signal'})
xlim([0 30])    
set(gcf,'Color','w')
subplot(3,2,[5:6])
    hold off
    plot(t,  SurrogateData_gsr(:,5),'b'); hold on    
    plot(t,  SurrogateData_gsr(:,7),'r');    
    legend({'Region 1','Region 2'})
    title({'Post-GSR signals',['Correlation of: ',num2str(round(corr(SurrogateData_gsr(:,7),SurrogateData_gsr(:,5)),2))]})%     plot(toPlot1);     
xlim([0 30])
%% create fc matrix and preserve correlation structure
fc_little_awake=nan(50,50);
fc_little_anes=nan(50,50);

for i=1:50
    for j=1:50
        ind1=reshape(AtlasSeeds==i,[],1);
        ind2=reshape(AtlasSeeds ==j,[],1);
        fc_little_awake(i,j)=tanh(squeeze(mean(atanh(fc_awake_avg(ind1,ind2)),[1,2],'omitnan')));
        fc_little_anes(i,j)= tanh(squeeze(mean(atanh(fc_anes_avg(ind1,ind2)),[1,2],'omitnan')));
    end
end
fc_little_awake=tril(fc_little_awake)+tril(fc_little_awake)'; %make syymetric
fc_little_anes=tril(fc_little_anes)+tril(fc_little_anes)'; %make syymetric
    fc_little_awake(1:size(fc_little_awake,1)+1:end) = 1;fc_little_anes(1:size(fc_little_anes,1)+1:end) = 1;

[eig_vec_awake,eig_val_awake]=eig(fc_little_awake);
[eig_vec_anes,eig_val_anes]=eig(fc_little_anes);


    tmp_calc_awake=squeeze(mean(pdse_awake(:,:,:,1),1,'omitnan')); %Group average Calcium
    tmp_calc_awake=reshape(tmp_calc_awake,[],25,2);
    tmp_calc_awake=mean(tmp_calc_awake,3,'omitnan');
    tmp_calc_awake=cat(2,tmp_calc_awake,tmp_calc_awake);    
    hz=linspace(0,12.5,(2^nextpow2(10*25*60/8))+1);

    %Xiaodan!!!
    tmp_calc_anes=squeeze(mean(pdse_anes(:,:,:,1),1,'omitnan')); %Group average Calcium
    tmp_calc_anes=reshape(tmp_calc_anes,[],25,2);
    tmp_calc_anes=mean(tmp_calc_anes,3,'omitnan');
    tmp_calc_anes=cat(2,tmp_calc_anes,tmp_calc_anes);    
    hz=linspace(0,12.5,(2^nextpow2(10*25*60/8))+1);    
%Build random data
    rng(20)    
Z=normrnd(0,1,[50,30000]); %build normal data
    AxxNormal_awake=fft(Z,[],2);
rng(25)    
    Z=normrnd(0,1,[50,30000]); %build normal data
AxxNormal_anes=fft(Z,[],2);
SurrogateDatatmp_awake=nan(30000,50);
SurrogateDatatmp_anes=nan(30000,50);

for regions=1:size(tmp_calc_awake,2)
%Select regional PSDE
    Pxx_awake=tmp_calc_awake(:,regions)';
    Pxx_anes= tmp_calc_anes (:,regions)';
    
%Upsample the data to get better fidelity
    Pxx_awake_int = interp1(hz(:), Pxx_awake(:), linspace(0,fs/2,10*fs*60+1)', 'pchip');
    Pxx_anes_int =  interp1(hz(:), Pxx_anes(:),  linspace(0,fs/2,10*fs*60+1)', 'pchip');
    
    TwoSidedPxx_awake =  [Pxx_awake_int;flipud(Pxx_awake_int(2:end-1))];
    TwoSidedPxx_anes =   [Pxx_anes_int; flipud(Pxx_anes_int(2:end-1))];
    
    PxxSurrogate_awake=AxxNormal_awake(regions,:)'.*sqrt(TwoSidedPxx_awake*8); %the 12 is here because of how the pwelch splits power into 12 segments!
    PxxSurrogate_anes= AxxNormal_anes (regions,:)'.*sqrt(TwoSidedPxx_anes*8); %the 12 is here because of how the pwelch splits power into 12 segments!
    
    SurrogateDatatmp_awake(:,regions)=ifft(PxxSurrogate_awake);
    SurrogateDatatmp_anes(:,regions)= ifft(PxxSurrogate_anes);
    
end
eig_val_anes(eig_val_anes<=0)=0;eig_val_anes(eig_val_anes<=0)=0;
SurrogateData_awake=eig_vec_awake*eig_val_awake.^(0.5)*SurrogateDatatmp_awake';
SurrogateData_anes =eig_vec_anes *eig_val_anes.^(0.5) *SurrogateDatatmp_anes';



SurrogateDataConv_region_awake=nan(5,30000,2);
SurrogateDataConv_global_awake=nan(5,30000,2);


for i=1:2
    if i==1
        HRFtmp=HRF_mice_awake_allRegions;
    else
        HRFtmp=HRF_mice_anes_allRegions;
    end

    for regions=1:size(tmp_calc_awake,2)

        SurrogateDataConv_region_awake(regions,:,i)=conv(SurrogateData_awake(regions,:)',resample(squeeze(mean(HRFtmp(:,:,regions),1)),50,250),'same')';
        SurrogateDataConv_global_awake(regions,:,i)=conv(SurrogateData_awake(regions,:)',resample(squeeze(mean(HRFtmp,[1,3],'omitnan')),50,250),'same')';

        SurrogateDataConv_region_anes(regions,:,i)=conv(SurrogateData_anes(regions,:)',resample(squeeze(mean(HRFtmp(:,:,regions),1)),50,250),'same')';
        SurrogateDataConv_global_anes(regions,:,i)=conv(SurrogateData_anes(regions,:)',resample(squeeze(mean(HRFtmp,[1,3],'omitnan')),50,250),'same')';        
    end
end

close all
figure
sgtitle('Anes Calcium Matrix')
    subplot(231)
        imagesc(fc_little_anes); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Calcium Correlation Matrix: Real ')
        xticks([]);yticks([])
    subplot(233)
        test=corr(SurrogateData_anes',SurrogateData_anes');
        imagesc(test); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Calcium Correlation Matrix: Simulated')
        xticks([]);yticks([])
    subplot(234)
        test=corr(SurrogateDataConv_region_anes(:,:,2)',SurrogateDataConv_region_anes(:,:,2)'); %anes
        imagesc(test); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('HbT FC: Anes IRF')
        xticks([]);yticks([])
 subplot(235)
        test=corr(SurrogateDataConv_region_anes(:,:,1)',SurrogateDataConv_region_anes(:,:,1)'); %awake
        imagesc(test); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('HbT FC: Awake IRF')
        xticks([]);yticks([])
 subplot(2,3,6)
        test_awake=corr(SurrogateDataConv_region_anes(:,:,1)',SurrogateDataConv_region_anes(:,:,1)'); %awake
        test_anes=corr(SurrogateDataConv_region_anes(:,:,2)',SurrogateDataConv_region_anes(:,:,2)'); %anes
      imagesc(test_awake-test_anes); caxis([-.5 .5])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Difference: awake-anes')
        xticks([]);yticks([])
        set(gcf,'Color','w')


figure
sgtitle('Awake Calcium Matrix')
    subplot(231)
        imagesc(fc_little_awake); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Calcium Correlation Matrix: Real ')
        xticks([]);yticks([])
    subplot(233)
        test=corr(SurrogateData_awake',SurrogateData_awake');
        imagesc(test); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Calcium Correlation Matrix: Simulated')
        xticks([]);yticks([])
    subplot(234)
        test=corr(SurrogateDataConv_region_awake(:,:,2)',SurrogateDataConv_region_awake(:,:,2)'); %anes
        imagesc(test); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('HbT FC: Anes IRF')
        xticks([]);yticks([])
 subplot(235)
        test=corr(SurrogateDataConv_region_awake(:,:,1)',SurrogateDataConv_region_awake(:,:,1)'); %awake
        imagesc(test); caxis([-1 1])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('HbT FC: Awake IRF')
        xticks([]);yticks([])
 subplot(2,3,6)
        test_awake=corr(SurrogateDataConv_region_awake(:,:,1)',SurrogateDataConv_region_awake(:,:,1)'); %awake
        test_anes=corr(SurrogateDataConv_region_awake(:,:,2)',SurrogateDataConv_region_awake(:,:,2)'); %anes
      imagesc(test_awake-test_anes); caxis([-.5 .5])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Difference: awake-anes')
        xticks([]);yticks([])
        set(gcf,'Color','w')
        

        
        %%

figure
subplot(121)
        test=corr(SurrogateDataConv_global_awake(:,:,1)',SurrogateDataConv_global_awake(:,:,1)')-corr(SurrogateDataConv_global_awake(:,:,2)',SurrogateDataConv_global_awake(:,:,2)');
        test2=corr(SurrogateDataConv_region_awake(:,:,1)',SurrogateDataConv_region_awake(:,:,1)')-corr(SurrogateDataConv_region_awake(:,:,2)',SurrogateDataConv_region_awake(:,:,2)');
        imagesc(tril(test)+triu(test2)); caxis([-.5 .5])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Awake-Anes: Global')
        xticks([]);yticks([])   
subplot(122)
        test=corr(SurrogateDataConv_region_awake(:,:,1)',SurrogateDataConv_region_awake(:,:,1)')-corr(SurrogateDataConv_region_awake(:,:,2)',SurrogateDataConv_region_awake(:,:,2)');
        imagesc(test); caxis([-.5 .5])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Awake-Anes: Regional')
        xticks([]);yticks([])   
%% 
fc_little_awake([1,2,5,23,26,27,30,48],:) = [];
fc_little_awake(:,[1,2,5,23,26,27,30,48]) = [];

fc_little_anes([1,2,5,23,26,27,30,48],:) = [];
fc_little_anes(:,[1,2,5,23,26,27,30,48]) = [];

figure
subplot(131)
        imagesc(fc_little_anes-fc_little_awake); caxis([-0.5 0.5])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Calcium Differences: Anes-Awake ')
        xticks([]);yticks([])    
subplot(132)
    HbT_null_awake=corr(SurrogateDataConv_region_awake(:,:,1)',SurrogateDataConv_region_awake(:,:,1)'); %awake
    HbT_null_anes= corr(SurrogateDataConv_region_anes (:,:,2)',SurrogateDataConv_region_anes (:,:,2)'); %anes
   
    HbT_null_awake([1,2,5,23,26,27,30,48],:) = [];
HbT_null_awake(:,[1,2,5,23,26,27,30,48]) = [];

HbT_null_anes([1,2,5,23,26,27,30,48],:) = [];
HbT_null_anes(:,[1,2,5,23,26,27,30,48]) = [];

    imagesc(HbT_null_anes-HbT_null_awake); caxis([-0.5 0.5])
    xlabel('Region')
    ylabel('Region')
    colormap(brewermap(256,'-Spectral')); c=colorbar;
    axis image
    title('HbT Differences: Anes-Awake ')
    xticks([]);yticks([])
subplot(133)
SurrogateDataConv_region_awake([1,2,5,23,26,27,30,48],:,:) = [];


      test=corr(SurrogateDataConv_region_awake(:,:,2)',SurrogateDataConv_region_awake(:,:,2)')-corr(SurrogateDataConv_region_awake(:,:,1)',SurrogateDataConv_region_awake(:,:,1)');
        imagesc(test); caxis([-.5 .5])
        xlabel('Region')
        ylabel('Region')
        colormap(brewermap(256,'-Spectral')); c=colorbar;
        axis image
        title('Anes-Awake: Awake Calcium Input')
        xticks([]);yticks([])   



%% Transfer Function
for region=1:50
    [h_anes(:,region),~] =freqz(squeeze(mean(HRF_mice_anes_allRegions(:,:,region), [1],'omitnan')));
    [h_awake(:,region),~]=freqz(squeeze(mean(HRF_mice_awake_allRegions(:,:,region),[1],'omitnan')));
end
close all
figure
subplot(211)
    plot_distribution_prctile(linspace(0,12.5,512),abs(h_anes'),'Alpha',.25,'Color',[0 0 1]);
    plot_distribution_prctile(linspace(0,12.5,512),abs(h_awake'),'Alpha',.25,'Color',[1 0 0]);
    xlim([0 12.5])    
    set(gca,'XScale','Log')
    set(gca,'YScale','Log')
    box off; 
    xlabel('Frequency (Hz)')
    ylabel('Ampltitude')

subplot(212)
    plot_distribution_prctile(linspace(0,12.5,512),unwrap(angle(h_anes), [],1)','Alpha',.25,'Color',[0 0 1]);
    plot_distribution_prctile(linspace(0,12.5,512),unwrap(angle(h_awake),[],1)','Alpha',.25,'Color',[1 0 0]);
    set(gca,'XScale','Log')
    box off; 
    xlabel('Frequency (Hz)')
    ylabel('Phase')
    set(gca,'XScale','Log')
    xlim([0 12.5])    
% convolution
figure
subplot(321)
plot(SurrogateData_awake(3,:))
xlim([0 2000])
ylim([-12 12])
subplot(323)
plot(squeeze(mean(HRF_mice_awake_allRegions(:,:,3),1)))
xlim([0 3000])
ylim([-0.0005 0.004])
subplot(325)
plot(SurrogateDataConv_region_awake(3,:))
xlim([0 2000])
ylim([-0.4 0.4])

subplot(322)
plot(SurrogateData_anes(3,:))
xlim([0 2000])
ylim([-12 12])
subplot(324)
plot(squeeze(mean(HRF_mice_anes_allRegions(:,:,3),1)))
xlim([0 3000])
ylim([-0.0005 0.004])
subplot(326)
plot(SurrogateDataConv_region_anes(3,:))
xlim([0 2000])
ylim([-0.4 0.4])

%% add noise to the data to see if the correlation decreases
no_noise_data=squeeze(SurrogateDataConv_region_anes(:,:,2)');
Per10_noise_data=no_noise_data+normrnd(0,var(squeeze(mean(no_noise_data,2,'omitnan')))+abs(quantile(squeeze(mean(abs(no_noise_data),2,'omitnan')),.1)),[size(no_noise_data)]);
Per50_noise_data=no_noise_data+normrnd(0,var(squeeze(mean(no_noise_data,2,'omitnan')))+abs(quantile(squeeze(mean(abs(no_noise_data),2,'omitnan')),.50)),[size(no_noise_data)]);
Per95_noise_data=no_noise_data+normrnd(0,var(squeeze(mean(no_noise_data,2,'omitnan')))+abs(quantile(squeeze(mean(abs(no_noise_data),2,'omitnan')),.95)),[size(no_noise_data)]);

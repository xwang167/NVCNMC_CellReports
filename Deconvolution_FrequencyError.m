load("AtlasandIsbrain_Allen.mat",'AtlasSeeds')
R2_HRF_map = nan(19,128*128);
load('190627-R5M2286-fc2_HRF_Upsample.mat', 'R2_HRF', 'HRF')
for ii = 1:19
    for jj = 1:50
        R2_HRF_map(ii,AtlasSeeds ==jj) = R2_HRF(ii,jj);
    end
end

R2_HRF_map = reshape(R2_HRF_map,19,128,128);
for ii = 1:19
    figure
    imagesc(squeeze(R2_HRF_map(ii,:,:)))
end

%%
SS = 7;
V = 16;
samplingRate = 25;
freq_new = 250;
t_kernel = 30;
tmp = matfile("D:\XiaodanPaperData\190627\190627-R5M2286-fc2_processed.mat");   %JPC partial load  -- has size size(test,'raw_unregistered') ARB 8.16 replaced readtiff
Calcium = tmp.xform_jrgeco1aCorr(:,:,25*30+1:25*60)*100;
Hb = tmp.xform_datahb(:,:,:,25*30+1:25*60);
HbT = squeeze(Hb(:,:,1,:)+Hb(:,:,2,:))*10^6;

Calcium = filterData(Calcium,0.02,2,samplingRate);
HbT     = filterData(HbT,    0.02,2,samplingRate);

Calcium = reshape(Calcium,128*128,[]);
HbT = reshape(HbT,128*128,[]);

HbT    = resample(HbT    ,freq_new,samplingRate,'Dimension',2);
Calcium = resample(Calcium,freq_new,samplingRate,'Dimension',2);

Calcium_SS = mean(Calcium(AtlasSeeds==SS,:));
HbT_SS = mean(HbT(AtlasSeeds==SS,:));

Calcium_SS = tukeywin(length(Calcium_SS),.3).*squeeze(Calcium_SS');
HbT_SS = tukeywin(length(HbT_SS),.3).*squeeze(HbT_SS');

HbT_pred_SS = conv(Calcium_SS,HRF(1,:,SS));
HbT_pred_SS = HbT_pred_SS(1:(t_kernel*freq_new+3*freq_new))';

HbT_SS_ISA   = lowpass (HbT_SS,0.08,samplingRate);
HbT_SS_Delta = highpass(HbT_SS,0.4 ,samplingRate);
HbT_SS_Delta = lowpass(HbT_SS_Delta,2 ,samplingRate);

HbT_pred_SS_ISA   = lowpass (HbT_pred_SS,0.08,samplingRate);
HbT_pred_SS_Delta = highpass(HbT_pred_SS,0.4 ,samplingRate);

figure
subplot(2,2,1)
plot((1:t_kernel*freq_new)/freq_new,HRF(1,:,SS))
title('HRF')
subplot(2,2,2)
plot((1:t_kernel*freq_new)/freq_new,HbT_SS,'k')
hold on
plot((1:t_kernel*freq_new)/freq_new,HbT_pred_SS(3*freq_new+1:end),'Color',[0 0.5 0])
title('HbT')
legend('Original','Predicted')
subplot(2,2,3)
plot((1:t_kernel*freq_new)/freq_new,HbT_SS_ISA,'k')
hold on
plot((1:t_kernel*freq_new)/freq_new,HbT_pred_SS_ISA(3*freq_new+1:end),'Color',[0 0.5 0])
title(strcat('0.02-0.08Hz Energy of Error:',num2str(sum(HbT_pred_SS_ISA(3*freq_new+1:end)-HbT_SS_ISA).^2)))
subplot(2,2,4)
plot((1:t_kernel*freq_new)/freq_new,HbT_SS_Delta,'k')
hold on
plot((1:t_kernel*freq_new)/freq_new,HbT_pred_SS_Delta(3*freq_new+1:end),'Color',[0 0.5 0])  
title(strcat('0.4-2Hz Energy of Error:',num2str(sum(HbT_pred_SS_Delta(3*freq_new+1:end)-HbT_SS_Delta).^2)))
sgtitle('Left Primary Somatosensory Area Barrel')

Calcium_V = mean(Calcium(AtlasSeeds==V,:));
HbT_V = mean(HbT(AtlasSeeds==V,:));

Calcium_V = tukeywin(length(Calcium_V),.3).*squeeze(Calcium_V');
HbT_V = tukeywin(length(HbT_V),.3).*squeeze(HbT_V');

HbT_pred_V = conv(Calcium_V,HRF(1,:,V));
HbT_pred_V = HbT_pred_V(1:(t_kernel*freq_new+3*freq_new))';

HbT_V_ISA   = lowpass (HbT_V,0.08,samplingRate);
HbT_V_Delta = highpass(HbT_V,0.4,samplingRate);
HbT_V_Delta = lowpass(HbT_V_Delta,2,samplingRate);

HbT_pred_V_ISA   = lowpass (HbT_pred_V,0.08,samplingRate);
HbT_pred_V_Delta = highpass(HbT_pred_V,0.4,samplingRate);

figure
subplot(2,2,1)
plot((1:t_kernel*freq_new)/freq_new,HRF(1,:,V))
title('HRF')
subplot(2,2,2)
plot((1:t_kernel*freq_new)/freq_new,HbT_V,'k')
hold on
plot((1:t_kernel*freq_new)/freq_new,HbT_pred_V(3*freq_new+1:end),'Color',[0 0.5 0])
title('HbT')
legend('Original','Predicted')
subplot(2,2,3)
plot((1:t_kernel*freq_new)/freq_new,HbT_V_ISA,'k')
hold on
plot((1:t_kernel*freq_new)/freq_new,HbT_pred_V_ISA(3*freq_new+1:end),'Color',[0 0.5 0])
title(strcat('0.02-0.08Hz Energy of Error:',num2str(sum(HbT_pred_V_ISA(3*freq_new+1:end)-HbT_V_ISA).^2)))
subplot(2,2,4)
plot((1:t_kernel*freq_new)/freq_new,HbT_V_Delta,'k')
hold on
plot((1:t_kernel*freq_new)/freq_new,HbT_pred_V_Delta(3*freq_new+1:end),'Color',[0 0.5 0])  
title(strcat('0.4-2Hz Energy of Error:',num2str(sum(HbT_pred_V_Delta(3*freq_new+1:end)-HbT_V_Delta).^2)))
sgtitle('Left Primary Visual')
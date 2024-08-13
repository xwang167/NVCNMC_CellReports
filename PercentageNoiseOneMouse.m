readout_noise = 20.8;

% Awake
load("E:\RGECO\190627\190627-R5M2286-fc_raw.mat")
load("E:\RGECO\Kenny\190627\190627-R5M2286-fc1-dataFluor.mat",'xform_isbrain')
load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')
load("GoodWL.mat")
mask_awake = AtlasSeeds.*xform_isbrain;
mask_awake(isnan(mask_awake)) = 0;
% Exclude FRP an PL
mask_awake(mask_awake==1)  = 0;
mask_awake(mask_awake==2)  = 0;
mask_awake(mask_awake==5)  = 0;
mask_awake(mask_awake==26) = 0;
mask_awake(mask_awake==27) = 0;
mask_awake(mask_awake==30) = 0;
mask_awake(mask_awake>1) = 1;

noise_percent_FAD_awake = sqrt(xform_raw_FAD_mouse+readout_noise^2)./xform_raw_FAD_mouse*100;
noise_percent_Calcium_awake = sqrt(xform_raw_Calcium_mouse+readout_noise^2)./xform_raw_Calcium_mouse*100;

% Anesthetized
load("E:\RGECO\190707\190707-R5M2286-anes-fc_raw.mat")
load("E:\RGECO\Kenny\190707\190707-R5M2286-anes-fc1-dataFluor.mat",'xform_isbrain')

mask_anes = AtlasSeeds.*xform_isbrain;
mask_anes(isnan(mask_anes)) = 0;
% Exclude FRP an PL
mask_anes(mask_anes==1)  = 0;
mask_anes(mask_anes==2)  = 0;
mask_anes(mask_anes==5)  = 0;
mask_anes(mask_anes==26) = 0;
mask_anes(mask_anes==27) = 0;
mask_anes(mask_anes==30) = 0;
mask_anes(mask_anes>1) = 1;

noise_percent_FAD_anes = sqrt(xform_raw_FAD_mouse+readout_noise^2)./xform_raw_FAD_mouse*100;
noise_percent_Calcium_anes = sqrt(xform_raw_Calcium_mouse+readout_noise^2)./xform_raw_Calcium_mouse*100;

% Visualization
figure
subplot(221)
imagesc(noise_percent_Calcium_awake,"AlphaData",mask_awake)
axis image off
clim([0.2 0.8])
b=colorbar;
ylabel(b,'%','Rotation', 0)
title('Calcium Awake')

subplot(222)
imagesc(noise_percent_FAD_awake,"AlphaData",mask_awake)
axis image off
clim([0.2 0.8])
b = colorbar;
ylabel(b,'%','Rotation', 0)
title('FAF Awake')

subplot(223)
imagesc(noise_percent_Calcium_anes,"AlphaData",mask_anes)
axis image off
clim([0.2 0.8])
b=colorbar;
ylabel(b,'%','Rotation', 0)
title('Calcium Anesthetized')

subplot(224)
imagesc(noise_percent_FAD_anes,"AlphaData",mask_anes)
axis image off
clim([0.2 0.8])
b = colorbar;
ylabel(b,'%','Rotation', 0)
title('FAF Anesthetized')

colormap(brewermap(256, '-Spectral'))
sgtitle('% Noise for One Mouse')

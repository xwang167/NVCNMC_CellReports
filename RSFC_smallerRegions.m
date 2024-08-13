
load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')
load('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc.mat',...
    'xform_isbrain_mice')
xform_isbrain_mice_awake = xform_isbrain_mice;
load('E:\RGECO\cat\191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc.mat',...
    'xform_isbrain_mice')
xform_isbrain_mice_anes = xform_isbrain_mice;
xform_isbrain_mice = xform_isbrain_mice_awake.*xform_isbrain_mice_anes;

mask = AtlasSeeds.*xform_isbrain_mice;
mask(isnan(mask)) = 0;
% Exclude FRP an PL
mask(mask==1)  = 0;
mask(mask==2)  = 0;
mask(mask==5)  = 0;
mask(mask==26) = 0;
mask(mask==27) = 0;
mask(mask==30) = 0;

% M SS P V RS A
%left
mask_region_ind{1} = 4;
mask_region_ind{2} = 7;
mask_region_ind{3} = 20;
mask_region_ind{4} = 16;
mask_region_ind{5} = 22;
mask_region_ind{6} = 25;

% right
mask_region_ind{7} = 29;
mask_region_ind{8} = 32;
mask_region_ind{9} = 45;
mask_region_ind{10} = 41;
mask_region_ind{11} = 47;
mask_region_ind{12} = 50;

mask_combined = zeros(128*128,12);
for ii = 1:12
    mask_combined(ismember(mask,mask_region_ind{ii}),ii) = 1; % motor
end
mask_combined = reshape(mask_combined,128,128,12);




% Form the 64*64 image
load('noVasculatureMask.mat')
mask = (leftMask+rightMask).*xform_isbrain_mice;
mask = imresize(mask,0.5);
mask(mask<0.5) = 0;
mask = logical(mask); 
ind_mask = find(reshape(mask',[],1));


%% ISA
FC_Calcium_ISA_awake = nan(64^2,64^2);
FC_FAD_ISA_awake     = nan(64^2,64^2);
FC_HbT_ISA_awake     = nan(64^2,64^2);

FC_Calcium_ISA_anes = nan(64^2,64^2);
FC_FAD_ISA_anes     = nan(64^2,64^2);
FC_HbT_ISA_anes     = nan(64^2,64^2);

ori_FC_Calcium_ISA_awake = nan(64^2,64^2);
ori_FC_FAD_ISA_awake     = nan(64^2,64^2);
ori_FC_HbT_ISA_awake     = nan(64^2,64^2);

ori_FC_Calcium_ISA_anes = nan(64^2,64^2);
ori_FC_FAD_ISA_anes     = nan(64^2,64^2);
ori_FC_HbT_ISA_anes     = nan(64^2,64^2);



load('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat',...
    'FCMatrix_Calcium_ISA_old_mice','FCMatrix_FAD_ISA_old_mice','FCMatrix_HbT_ISA_old_mice')
FC_Calcium_ISA_awake(ind_mask,ind_mask) = FCMatrix_Calcium_ISA_old_mice;
FC_FAD_ISA_awake(ind_mask,ind_mask)     = FCMatrix_FAD_ISA_old_mice;
FC_HbT_ISA_awake(ind_mask,ind_mask)     = FCMatrix_HbT_ISA_old_mice;

load('E:\RGECO\cat\191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat',...
    'FCMatrix_Calcium_ISA_old_mice','FCMatrix_FAD_ISA_old_mice','FCMatrix_HbT_ISA_old_mice')
FC_Calcium_ISA_anes(ind_mask,ind_mask) = FCMatrix_Calcium_ISA_old_mice;
FC_FAD_ISA_anes(ind_mask,ind_mask)     = FCMatrix_FAD_ISA_old_mice;
FC_HbT_ISA_anes(ind_mask,ind_mask)     = FCMatrix_HbT_ISA_old_mice;

for ii = 1:4096
    ori_FC_Calcium_ISA_awake(ii,:) = reshape(transpose(reshape(FC_Calcium_ISA_awake(ii,:),64,64)),1,[]);
    ori_FC_FAD_ISA_awake(ii,:)     = reshape(transpose(reshape(FC_FAD_ISA_awake(ii,:),    64,64)),1,[]);
    ori_FC_HbT_ISA_awake(ii,:)     = reshape(transpose(reshape(FC_HbT_ISA_awake(ii,:),    64,64)),1,[]);

    ori_FC_Calcium_ISA_anes(ii,:) = reshape(transpose(reshape(FC_Calcium_ISA_anes(ii,:),64,64)),1,[]);
    ori_FC_FAD_ISA_anes(ii,:)     = reshape(transpose(reshape(FC_FAD_ISA_anes(ii,:),    64,64)),1,[]);
    ori_FC_HbT_ISA_anes(ii,:)     = reshape(transpose(reshape(FC_HbT_ISA_anes(ii,:),    64,64)),1,[]);
end

awake_Calcium_ISA = zeros(64*64,12);
anes_Calcium_ISA = zeros(64*64,12);

awake_FAD_ISA = zeros(64*64,12);
anes_FAD_ISA = zeros(64*64,12);

awake_HbT_ISA = zeros(64*64,12);
anes_HbT_ISA = zeros(64*64,12);

ori_FC_Calcium_ISA_awake(isinf(ori_FC_Calcium_ISA_awake)) = nan;
ori_FC_Calcium_ISA_anes(isinf(ori_FC_Calcium_ISA_anes)) = nan;

ori_FC_FAD_ISA_awake(isinf(ori_FC_FAD_ISA_awake)) = nan;
ori_FC_FAD_ISA_anes(isinf(ori_FC_FAD_ISA_anes)) = nan;

ori_FC_HbT_ISA_awake(isinf(ori_FC_HbT_ISA_awake)) = nan;
ori_FC_HbT_ISA_anes(isinf(ori_FC_HbT_ISA_anes)) = nan;

mask_regions = zeros(64,64,12);
for ii = 1:12
    temp = mask_combined(:,:,ii);
    temp = imresize(temp,0.5);
    temp(temp<0.5) = 0;
    %imagesc(temp)
    temp = temp.*mask;
    mask_regions(:,:,ii) = temp;
    ind = find(temp);
    if ~isempty(ind)
    [row,col] = ind2sub([64,64],ind);
    indNew = sub2ind([64,64],col,row);
    awake_Calcium_ISA(:,ii) = nanmean(real(ori_FC_Calcium_ISA_awake(indNew,:)));
    anes_Calcium_ISA(:,ii) = nanmean(real(ori_FC_Calcium_ISA_anes(indNew,:)));

    awake_FAD_ISA(:,ii) = nanmean(real(ori_FC_FAD_ISA_awake(indNew,:)));
    anes_FAD_ISA(:,ii) = nanmean(real(ori_FC_FAD_ISA_anes(indNew,:)));

    awake_HbT_ISA(:,ii) = nanmean(real(ori_FC_HbT_ISA_awake(indNew,:)));
    anes_HbT_ISA(:,ii) = nanmean(real(ori_FC_HbT_ISA_anes(indNew,:)));
    end
end

% Visualization



%% Delta
FC_Calcium_Delta_awake = nan(64^2,64^2);
FC_FAD_Delta_awake     = nan(64^2,64^2);
FC_HbT_Delta_awake     = nan(64^2,64^2);

FC_Calcium_Delta_anes = nan(64^2,64^2);
FC_FAD_Delta_anes     = nan(64^2,64^2);
FC_HbT_Delta_anes     = nan(64^2,64^2);

ori_FC_Calcium_Delta_awake = nan(64^2,64^2);
ori_FC_FAD_Delta_awake     = nan(64^2,64^2);
ori_FC_HbT_Delta_awake     = nan(64^2,64^2);

ori_FC_Calcium_Delta_anes = nan(64^2,64^2);
ori_FC_FAD_Delta_anes     = nan(64^2,64^2);
ori_FC_HbT_Delta_anes     = nan(64^2,64^2);



load('E:\RGECO\cat\191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-fc_fcMatrix_mice.mat',...
    'FCMatrix_Calcium_Delta_old_mice','FCMatrix_FAD_Delta_old_mice','FCMatrix_HbT_Delta_old_mice')
FC_Calcium_Delta_awake(ind_mask,ind_mask) = FCMatrix_Calcium_Delta_old_mice;
FC_FAD_Delta_awake(ind_mask,ind_mask)     = FCMatrix_FAD_Delta_old_mice;
FC_HbT_Delta_awake(ind_mask,ind_mask)     = FCMatrix_HbT_Delta_old_mice;

load('E:\RGECO\cat\191030--R5M2286-anes-R5M2285-anes-R5M2288-anes-R6M2460-anes-R6M1-anes-R6M2497-anes-fc_fcMatrix_mice.mat',...
    'FCMatrix_Calcium_Delta_old_mice','FCMatrix_FAD_Delta_old_mice','FCMatrix_HbT_Delta_old_mice')
FC_Calcium_Delta_anes(ind_mask,ind_mask) = FCMatrix_Calcium_Delta_old_mice;
FC_FAD_Delta_anes(ind_mask,ind_mask)     = FCMatrix_FAD_Delta_old_mice;
FC_HbT_Delta_anes(ind_mask,ind_mask)     = FCMatrix_HbT_Delta_old_mice;

for ii = 1:4096
    ori_FC_Calcium_Delta_awake(ii,:) = reshape(transpose(reshape(FC_Calcium_Delta_awake(ii,:),64,64)),1,[]);
    ori_FC_FAD_Delta_awake(ii,:)     = reshape(transpose(reshape(FC_FAD_Delta_awake(ii,:),    64,64)),1,[]);
    ori_FC_HbT_Delta_awake(ii,:)     = reshape(transpose(reshape(FC_HbT_Delta_awake(ii,:),    64,64)),1,[]);

    ori_FC_Calcium_Delta_anes(ii,:) = reshape(transpose(reshape(FC_Calcium_Delta_anes(ii,:),64,64)),1,[]);
    ori_FC_FAD_Delta_anes(ii,:)     = reshape(transpose(reshape(FC_FAD_Delta_anes(ii,:),    64,64)),1,[]);
    ori_FC_HbT_Delta_anes(ii,:)     = reshape(transpose(reshape(FC_HbT_Delta_anes(ii,:),    64,64)),1,[]);
end

awake_Calcium_Delta = zeros(64*64,12);
anes_Calcium_Delta = zeros(64*64,12);

awake_FAD_Delta = zeros(64*64,12);
anes_FAD_Delta = zeros(64*64,12);

awake_HbT_Delta = zeros(64*64,12);
anes_HbT_Delta = zeros(64*64,12);

ori_FC_Calcium_Delta_awake(isinf(ori_FC_Calcium_Delta_awake)) = nan;
ori_FC_Calcium_Delta_anes(isinf(ori_FC_Calcium_Delta_anes)) = nan;

ori_FC_FAD_Delta_awake(isinf(ori_FC_FAD_Delta_awake)) = nan;
ori_FC_FAD_Delta_anes(isinf(ori_FC_FAD_Delta_anes)) = nan;

ori_FC_HbT_Delta_awake(isinf(ori_FC_HbT_Delta_awake)) = nan;
ori_FC_HbT_Delta_anes(isinf(ori_FC_HbT_Delta_anes)) = nan;

mask_regions = zeros(64,64,12);
for ii = 1:12
    temp = mask_combined(:,:,ii);
    temp = imresize(temp,0.5);
    temp(temp<0.5) = 0;
    %imagesc(temp)
    temp = temp.*mask;
    mask_regions(:,:,ii) = temp;
    ind = find(temp);
    if ~isempty(ind)
    [row,col] = ind2sub([64,64],ind);
    indNew = sub2ind([64,64],col,row);
    awake_Calcium_Delta(:,ii) = nanmean(real(ori_FC_Calcium_Delta_awake(indNew,:)));
    anes_Calcium_Delta(:,ii) = nanmean(real(ori_FC_Calcium_Delta_anes(indNew,:)));

    awake_FAD_Delta(:,ii) = nanmean(real(ori_FC_FAD_Delta_awake(indNew,:)));
    anes_FAD_Delta(:,ii) = nanmean(real(ori_FC_FAD_Delta_anes(indNew,:)));

    awake_HbT_Delta(:,ii) = nanmean(real(ori_FC_HbT_Delta_awake(indNew,:)));
    anes_HbT_Delta(:,ii) = nanmean(real(ori_FC_HbT_Delta_anes(indNew,:)));
    end
end

%% Visualization
% Awake ISA
figure('units','normalized','outerposition',[0 0 1 1])
A = reshape(awake_Calcium_ISA(:,1),64,64);
mask_A = isnan(A);
for ii = 1:6
    subplot(3,6,ii)
    imagesc(reshape(awake_Calcium_ISA(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
    switch ii
        case 1
            title('M1')
        case 2
            title('SSb')
        case 3
            title('Pm')
        case 4
            title('V1')
        case 5
            title('RS')
        case 6
            title('A')
    end
end

for ii = 1:6
    subplot(3,6,6+ii)
    imagesc(reshape(awake_FAD_ISA(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end

for ii = 1:6
    subplot(3,6,12+ii)
    imagesc(reshape(awake_HbT_ISA(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end
colormap(brewermap(256, '-Spectral'))
annotation('textbox', [0.05, 0.725, 1, 0.1], 'String', 'jRGECO1a', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.425, 1, 0.1], 'String', 'FAF', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.125, 1, 0.1], 'String', 'HbT', 'EdgeColor', 'none');
sgtitle('Awake ISA')

% Anes ISA
figure('units','normalized','outerposition',[0 0 1 1])
A = reshape(anes_Calcium_ISA(:,1),64,64);
mask_A = isnan(A);
for ii = 1:6
    subplot(3,6,ii)
    imagesc(reshape(anes_Calcium_ISA(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
    switch ii
        case 1
            title('M1')
        case 2
            title('SSb')
        case 3
            title('Pm')
        case 4
            title('V1')
        case 5
            title('RS')
        case 6
            title('A')
    end
end

for ii = 1:6
    subplot(3,6,6+ii)
    imagesc(reshape(anes_FAD_ISA(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end

for ii = 1:6
    subplot(3,6,12+ii)
    imagesc(reshape(anes_HbT_ISA(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end
colormap(brewermap(256, '-Spectral'))
annotation('textbox', [0.05, 0.725, 1, 0.1], 'String', 'jRGECO1a', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.425, 1, 0.1], 'String', 'FAF', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.125, 1, 0.1], 'String', 'HbT', 'EdgeColor', 'none');
sgtitle('Anesthetized ISA')


% Awake Delta
figure('units','normalized','outerposition',[0 0 1 1])
A = reshape(awake_Calcium_Delta(:,1),64,64);
mask_A = isnan(A);
for ii = 1:6
    subplot(3,6,ii)
    imagesc(reshape(awake_Calcium_Delta(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
    switch ii
        case 1
            title('M1')
        case 2
            title('SSb')
        case 3
            title('Pm')
        case 4
            title('V1')
        case 5
            title('RS')
        case 6
            title('A')
    end
end

for ii = 1:6
    subplot(3,6,6+ii)
    imagesc(reshape(awake_FAD_Delta(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end

for ii = 1:6
    subplot(3,6,12+ii)
    imagesc(reshape(awake_HbT_Delta(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end
colormap(brewermap(256, '-Spectral'))
annotation('textbox', [0.05, 0.725, 1, 0.1], 'String', 'jRGECO1a', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.425, 1, 0.1], 'String', 'FAF', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.125, 1, 0.1], 'String', 'HbT', 'EdgeColor', 'none');
sgtitle('Awake Delta')

% Anes Delta
figure('units','normalized','outerposition',[0 0 1 1])
A = reshape(anes_Calcium_Delta(:,1),64,64);
mask_A = isnan(A);
for ii = 1:6
    subplot(3,6,ii)
    imagesc(reshape(anes_Calcium_Delta(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
    switch ii
        case 1
            title('M1')
        case 2
            title('SSb')
        case 3
            title('Pm')
        case 4
            title('V1')
        case 5
            title('RS')
        case 6
            title('A')
    end
end

for ii = 1:6
    subplot(3,6,6+ii)
    imagesc(reshape(anes_FAD_Delta(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end

for ii = 1:6
    subplot(3,6,12+ii)
    imagesc(reshape(anes_HbT_Delta(:,ii),64,64),'AlphaData',~mask_A)
    hold on
    contour(logical(mask_regions(:,:,ii)),'k')
    axis image off
    clim([-1.5 1.5])
end
colormap(brewermap(256, '-Spectral'))
annotation('textbox', [0.05, 0.725, 1, 0.1], 'String', 'jRGECO1a', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.425, 1, 0.1], 'String', 'FAF', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.125, 1, 0.1], 'String', 'HbT', 'EdgeColor', 'none');
sgtitle('Anesthetized Delta')



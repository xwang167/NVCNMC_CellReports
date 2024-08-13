saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName, 'HRF_mice_awake_allRegions', 'r_HRF_mice_awake_allRegions', 'MRF_mice_awake_allRegions', 'r_MRF_mice_awake_allRegions', 'HRF_mice_anes_allRegions', 'r_HRF_mice_anes_allRegions', 'MRF_mice_anes_allRegions', 'r_MRF_mice_anes_allRegions')
load(saveName, 'A_HRF_mice_awake_allRegions', 'T_HRF_mice_awake_allRegions', 'W_HRF_mice_awake_allRegions', 'A_MRF_mice_awake_allRegions', 'T_MRF_mice_awake_allRegions', 'W_MRF_mice_awake_allRegions', 'A_HRF_mice_anes_allRegions', 'T_HRF_mice_anes_allRegions', 'W_HRF_mice_anes_allRegions', 'A_MRF_mice_anes_allRegions', 'T_MRF_mice_anes_allRegions', 'W_MRF_mice_anes_allRegions')
% Exclude T W A that has T bigger than 0.2 for NMC under awake condition
numMice = 6;
for region = 1:50
    for mouseInd =1:numMice
        if T_MRF_mice_awake_allRegions(mouseInd,region)>0.2
            T_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            W_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            A_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            r_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
        end
    end
end


for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        for var = {'T','W','A','r'}
              eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'_exclude = ',var{1},'_',h{1},'_mice_',condition{1},'_allRegions(:,[3,4,6:25,28,29,31:50]);'));
              eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),var{1},'_',h{1},'_mice_',condition{1},'_exclude',char(39),',',...
                   char(39),'-append',char(39),')'))
        end
    end
end

load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')
ii = 1; 
for jj = [3,4,6:25,28,29,31:50]
    label_region{ii} = parcelnames{jj};
    ii = ii+1;
end
save(saveName,'label_region','-append')

saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName, 'HRF_mice_awake_allRegions', 'r_HRF_mice_awake_allRegions', 'MRF_mice_awake_allRegions', 'r_MRF_mice_awake_allRegions', 'HRF_mice_anes_allRegions', 'r_HRF_mice_anes_allRegions', 'MRF_mice_anes_allRegions', 'r_MRF_mice_anes_allRegions')
load(saveName, 'A_HRF_mice_awake_allRegions', 'T_HRF_mice_awake_allRegions', 'W_HRF_mice_awake_allRegions', 'A_MRF_mice_awake_allRegions', 'T_MRF_mice_awake_allRegions', 'W_MRF_mice_awake_allRegions', 'A_HRF_mice_anes_allRegions', 'T_HRF_mice_anes_allRegions', 'W_HRF_mice_anes_allRegions', 'A_MRF_mice_anes_allRegions', 'T_MRF_mice_anes_allRegions', 'W_MRF_mice_anes_allRegions')
% Exclude T W A that has T bigger than 0.2 for NMC under awake condition
numMice = 6;
for region = 1:50
    for mouseInd =1:numMice
        if T_MRF_mice_awake_allRegions(mouseInd,region)>0.2
            T_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            W_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            A_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            r_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
        end
    end
end


for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        for var = {'T','W','A','r'}
              eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'_exclude = ',var{1},'_',h{1},'_mice_',condition{1},'_allRegions(:,[3,4,6:25,28,29,31:50]);'));
              eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),var{1},'_',h{1},'_mice_',condition{1},'_exclude',char(39),',',...
                   char(39),'-append',char(39),')'))
        end
    end
end

load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')
ii = 1; 
mask_exlude = zeros(128,128);
for jj = [3,4,6:25,28,29,31:50]
    label_region{ii} = parcelnames{jj};
    ii = ii+1;
end
save(saveName,'label_region','-append')

%% Time to peak
T_HRF_mice_awake_exclude = T_HRF_mice_awake_exclude';
T_MRF_mice_awake_exclude = T_MRF_mice_awake_exclude';
T_HRF_mice_anes_exclude = T_HRF_mice_anes_exclude';
T_MRF_mice_anes_exclude = T_MRF_mice_anes_exclude';

% mean
T_HRF_mice_awake_exclude_mean = nanmean(T_HRF_mice_awake_exclude,2);
T_MRF_mice_awake_exclude_mean = nanmean(T_MRF_mice_awake_exclude,2);

T_HRF_mice_anes_exclude_mean  = nanmean(T_HRF_mice_anes_exclude,2);
T_MRF_mice_anes_exclude_mean  = nanmean(T_MRF_mice_anes_exclude,2);

%% Width
W_HRF_mice_awake_exclude = W_HRF_mice_awake_exclude';
W_MRF_mice_awake_exclude = W_MRF_mice_awake_exclude';
W_HRF_mice_anes_exclude = W_HRF_mice_anes_exclude';
W_MRF_mice_anes_exclude = W_MRF_mice_anes_exclude';

% mean
W_HRF_mice_awake_exclude_mean = nanmean(W_HRF_mice_awake_exclude,2);
W_MRF_mice_awake_exclude_mean = nanmean(W_MRF_mice_awake_exclude,2);

W_HRF_mice_anes_exclude_mean  = nanmean(W_HRF_mice_anes_exclude,2);
W_MRF_mice_anes_exclude_mean  = nanmean(W_MRF_mice_anes_exclude,2);

%% Amplitude
A_HRF_mice_awake_exclude = A_HRF_mice_awake_exclude';
A_MRF_mice_awake_exclude = A_MRF_mice_awake_exclude';
A_HRF_mice_anes_exclude = A_HRF_mice_anes_exclude';
A_MRF_mice_anes_exclude = A_MRF_mice_anes_exclude';

% mean
A_HRF_mice_awake_exclude_mean = nanmean(A_HRF_mice_awake_exclude,2);
A_MRF_mice_awake_exclude_mean = nanmean(A_MRF_mice_awake_exclude,2);

A_HRF_mice_anes_exclude_mean  = nanmean(A_HRF_mice_anes_exclude,2);
A_MRF_mice_anes_exclude_mean  = nanmean(A_MRF_mice_anes_exclude,2);

%% Visualization
figure('units','normalized','outerposition',[0 0 1 1])

% T
subplot(321)
scatter(T_MRF_mice_awake_exclude_mean,T_HRF_mice_awake_exclude_mean,[],linspace(1,10,44),'filled')
mdl_T_awake = fitlm(T_MRF_mice_awake_exclude_mean,T_HRF_mice_awake_exclude_mean);
hold on
h = plot(mdl_T_awake) ;
delete(h(1))
xlabel('NMC T(s)')
ylabel('NVC T(s)')
colormap('inferno');
title('T, Awake')
legend off
xlim([0.02 0.07])
ylim([0.5 1.6])

subplot(322)
xlabel('NVC T(s)')
scatter(T_MRF_mice_anes_exclude_mean,T_HRF_mice_anes_exclude_mean,[],linspace(1,10,44),'filled')
mdl_T_anes = fitlm(T_MRF_mice_anes_exclude_mean,T_HRF_mice_anes_exclude_mean);
hold on
h = plot(mdl_T_anes) ;
delete(h(1))
xlabel('NMC T(s)')
ylabel('NVC T(s)')
colormap('inferno');
title('T, Anes')
legend off
xlim([0.02 0.07])
ylim([0.5 1.6])
% W
subplot(323)
scatter(W_MRF_mice_awake_exclude_mean,W_HRF_mice_awake_exclude_mean,[],linspace(1,10,44),'filled')
mdl_W_awake = fitlm(W_MRF_mice_awake_exclude_mean,W_HRF_mice_awake_exclude_mean);
hold on
h = plot(mdl_W_awake) ;
delete(h(1))
xlabel('NMC W(s)')
ylabel('NVC W(s)')
colormap('inferno');
title('W, Awake')
legend off
xlim([0.3 0.65])
ylim([0.8 2.7])

subplot(324)
scatter(W_MRF_mice_anes_exclude_mean,W_HRF_mice_anes_exclude_mean,[],linspace(1,10,44),'filled')
mdl_W_anes = fitlm(W_MRF_mice_anes_exclude_mean,W_HRF_mice_anes_exclude_mean);
hold on
h = plot(mdl_W_anes) ;
delete(h(1))
xlabel('NMC W(s)')
ylabel('NVC W(s)')
colormap('inferno');
title('W, Anes')
legend off
xlim([0.3 0.65])
ylim([0.8 2.7])
% A
subplot(325)
scatter(A_MRF_mice_awake_exclude_mean,A_HRF_mice_awake_exclude_mean,[],linspace(1,10,44),'filled')
mdl_A_awake = fitlm(A_MRF_mice_awake_exclude_mean,A_HRF_mice_awake_exclude_mean);
hold on
h = plot(mdl_A_awake) ;
delete(h(1))
xlabel('NMC A')
ylabel('NVC A')
colormap('inferno');
title('A, Awake')
legend off
xlim([0.0005 0.0017])
ylim([0.0004 0.005])

subplot(326)
scatter(A_MRF_mice_anes_exclude_mean,A_HRF_mice_anes_exclude_mean,[],linspace(1,10,44),'filled')
mdl_A_anes = fitlm(A_MRF_mice_anes_exclude_mean,A_HRF_mice_anes_exclude_mean);
hold on
h = plot(mdl_A_anes) ;
delete(h(1))
xlabel('NMC A')
ylabel('NVC A')
colormap('inferno');
title('A, Anes')
legend off
xlim([0.0005 0.0017])
ylim([0.0004 0.005])
%% Mask with color coded region
load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
excelRows_awake = [181 183 185 228 232 236];
excelRows_anes  = [202 195 204 230 234 240];

xform_isbrain_mice = 1;
for excelRow = [181 183 185 228 232 236 202 195 204 230 234 240]
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    disp(strcat(mouseName,', run #1'))
    processedName = strcat(recDate,'-',mouseName,'-',sessionType,'1_processed','.mat');
    load(fullfile(saveDir,processedName),'xform_isbrain')
    xform_isbrain_mice = xform_isbrain_mice.*xform_isbrain;
end
mask = AtlasSeeds.*xform_isbrain_mice;
mask(isnan(mask)) = 0;

mask_exclude = nan(128,128);
ii = 1; 
for jj = [3,4,6:25,28,29,31:50]
   mask_exclude(mask == jj)= ii;
    ii = ii+1;
end

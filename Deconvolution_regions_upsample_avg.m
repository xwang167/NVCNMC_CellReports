clear ;close all;clc
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
freq_new     = 250;
t_kernel = 30;
t = (-3*freq_new:(t_kernel-3)*freq_new-1)/freq_new ;
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\noVasculatureMask.mat",'mask_new')
load('AtlasandIsbrain.mat','AtlasSeedsFilled')
AtlasSeedsFilled(AtlasSeedsFilled==0) = nan;
AtlasSeedsFilled(:,65:128) = AtlasSeedsFilled(:,65:128)+20;

% Mask for different regions
mask_M2_L = AtlasSeedsFilled==4;
mask_M1_L = AtlasSeedsFilled==5;
mask_SS_L = AtlasSeedsFilled==6 | AtlasSeedsFilled==7 | AtlasSeedsFilled==8 | AtlasSeedsFilled==9 | AtlasSeedsFilled==10 | AtlasSeedsFilled==11;
mask_P_L  = AtlasSeedsFilled==13 | AtlasSeedsFilled==14 | AtlasSeedsFilled==15;
mask_V1_L = AtlasSeedsFilled==17;
mask_V2_L = AtlasSeedsFilled==16|AtlasSeedsFilled==18;

mask_M2_R = AtlasSeedsFilled==24;
mask_M1_R = AtlasSeedsFilled==25;
mask_SS_R = AtlasSeedsFilled==26 | AtlasSeedsFilled==27 | AtlasSeedsFilled==28 | AtlasSeedsFilled==29 | AtlasSeedsFilled==30 | AtlasSeedsFilled==31;
mask_P_R  = AtlasSeedsFilled==33 | AtlasSeedsFilled==34 | AtlasSeedsFilled==35;
mask_V1_R = AtlasSeedsFilled==37;
mask_V2_R = AtlasSeedsFilled==36|AtlasSeedsFilled==38;

% Get shared xform_isbrain
xform_isbrain_mice_awake = 1;
for excelRow = [181 183 185 228 232 236 202 195 204 230 234 240]
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    disp(strcat(mouseName,', run #1'))
    processedName = strcat(recDate,'-',mouseName,'-',sessionType,'1_processed','.mat');
    load(fullfile(saveDir,processedName),'xform_isbrain')
    xform_isbrain_mice_awake = xform_isbrain_mice_awake.*xform_isbrain;
end

% Regional mask needs to be inside of xform_isbrain_mice_awake
mask_M2_L = logical(mask_M2_L.*mask_new.*xform_isbrain_mice_awake);
mask_M1_L = logical(mask_M1_L.*mask_new.*xform_isbrain_mice_awake);
mask_SS_L = logical(mask_SS_L.*mask_new.*xform_isbrain_mice_awake);
mask_P_L  = logical(mask_P_L .*mask_new.*xform_isbrain_mice_awake);
mask_V1_L = logical(mask_V1_L.*mask_new.*xform_isbrain_mice_awake);
mask_V2_L = logical(mask_V2_L.*mask_new.*xform_isbrain_mice_awake);

mask_M2_R = logical(mask_M2_R.*mask_new.*xform_isbrain_mice_awake);
mask_M1_R = logical(mask_M1_R.*mask_new.*xform_isbrain_mice_awake);
mask_SS_R = logical(mask_SS_R.*mask_new.*xform_isbrain_mice_awake);
mask_P_R  = logical(mask_P_R .*mask_new.*xform_isbrain_mice_awake);
mask_V1_R = logical(mask_V1_R.*mask_new.*xform_isbrain_mice_awake);
mask_V2_R = logical(mask_V2_R.*mask_new.*xform_isbrain_mice_awake);

% Average the r_HRF,HRF,r_MRF,MRF for each region
%% Awake
% Initialize HRF
r_HRF_M2_L_mice_awake = [];
r_HRF_M1_L_mice_awake = [];
r_HRF_SS_L_mice_awake = [];
r_HRF_P_L_mice_awake  = [];
r_HRF_V1_L_mice_awake = [];
r_HRF_V2_L_mice_awake = [];

r_HRF_M2_R_mice_awake = [];
r_HRF_M1_R_mice_awake = [];
r_HRF_SS_R_mice_awake = [];
r_HRF_P_R_mice_awake  = [];
r_HRF_V1_R_mice_awake = [];
r_HRF_V2_R_mice_awake = [];

HRF_M2_L_mice_awake = [];
HRF_M1_L_mice_awake = [];
HRF_SS_L_mice_awake = [];
HRF_P_L_mice_awake  = [];
HRF_V1_L_mice_awake = [];
HRF_V2_L_mice_awake = [];

HRF_M2_R_mice_awake = [];
HRF_M1_R_mice_awake = [];
HRF_SS_R_mice_awake = [];
HRF_P_R_mice_awake  = [];
HRF_V1_R_mice_awake = [];
HRF_V2_R_mice_awake = [];

% Initialize MRF
r_MRF_M2_L_mice_awake = [];
r_MRF_M1_L_mice_awake = [];
r_MRF_SS_L_mice_awake = [];
r_MRF_P_L_mice_awake  = [];
r_MRF_V1_L_mice_awake = [];
r_MRF_V2_L_mice_awake = [];

r_MRF_M2_R_mice_awake = [];
r_MRF_M1_R_mice_awake = [];
r_MRF_SS_R_mice_awake = [];
r_MRF_P_R_mice_awake  = [];
r_MRF_V1_R_mice_awake = [];
r_MRF_V2_R_mice_awake = [];

MRF_M2_L_mice_awake = [];
MRF_M1_L_mice_awake = [];
MRF_SS_L_mice_awake = [];
MRF_P_L_mice_awake  = [];
MRF_V1_L_mice_awake = [];
MRF_V2_L_mice_awake = [];

MRF_M2_R_mice_awake = [];
MRF_M1_R_mice_awake = [];
MRF_SS_R_mice_awake = [];
MRF_P_R_mice_awake  = [];
MRF_V1_R_mice_awake = [];
MRF_V2_R_mice_awake = [];

% Concatinate the matrix
for excelRow = [181 183 185 228 232 236]

    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    for n = 1:3
        disp(strcat(mouseName,', run#',num2str(n)))
        load(fullfile(saveDir,'HRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Regions_Upsample','.mat')))
        load(fullfile(saveDir,'MRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Regions_Upsample','.mat')))
        % cat r_HRF
        r_HRF_M2_L_mice_awake = cat(2,r_HRF_M2_L_mice_awake,r_HRF_M2_L);
        r_HRF_M1_L_mice_awake = cat(2,r_HRF_M1_L_mice_awake,r_HRF_M1_L);
        r_HRF_SS_L_mice_awake = cat(2,r_HRF_SS_L_mice_awake,r_HRF_SS_L);
        r_HRF_P_L_mice_awake  = cat(2,r_HRF_P_L_mice_awake ,r_HRF_P_L );
        r_HRF_V1_L_mice_awake = cat(2,r_HRF_V1_L_mice_awake,r_HRF_V1_L);
        r_HRF_V2_L_mice_awake = cat(2,r_HRF_V2_L_mice_awake,r_HRF_V2_L);

        
        r_HRF_M2_R_mice_awake = cat(2,r_HRF_M2_R_mice_awake,r_HRF_M2_R);
        r_HRF_M1_R_mice_awake = cat(2,r_HRF_M1_R_mice_awake,r_HRF_M1_R);
        r_HRF_SS_R_mice_awake = cat(2,r_HRF_SS_R_mice_awake,r_HRF_SS_R);
        r_HRF_P_R_mice_awake  = cat(2,r_HRF_P_R_mice_awake ,r_HRF_P_R );
        r_HRF_V1_R_mice_awake = cat(2,r_HRF_V1_R_mice_awake,r_HRF_V1_R);
        r_HRF_V2_R_mice_awake = cat(2,r_HRF_V2_R_mice_awake,r_HRF_V2_R);

        %cat HRF
        HRF_M2_L_mice_awake = cat(1,HRF_M2_L_mice_awake,HRF_M2_L);
        HRF_M1_L_mice_awake = cat(1,HRF_M1_L_mice_awake,HRF_M1_L);
        HRF_SS_L_mice_awake = cat(1,HRF_SS_L_mice_awake,HRF_SS_L);
        HRF_P_L_mice_awake  = cat(1,HRF_P_L_mice_awake ,HRF_P_L );
        HRF_V1_L_mice_awake = cat(1,HRF_V1_L_mice_awake,HRF_V1_L);
        HRF_V2_L_mice_awake = cat(1,HRF_V2_L_mice_awake,HRF_V2_L);

        
        HRF_M2_R_mice_awake = cat(1,HRF_M2_R_mice_awake,HRF_M2_R);
        HRF_M1_R_mice_awake = cat(1,HRF_M1_R_mice_awake,HRF_M1_R);
        HRF_SS_R_mice_awake = cat(1,HRF_SS_R_mice_awake,HRF_SS_R);
        HRF_P_R_mice_awake  = cat(1,HRF_P_R_mice_awake ,HRF_P_R );
        HRF_V1_R_mice_awake = cat(1,HRF_V1_R_mice_awake,HRF_V1_R);
        HRF_V2_R_mice_awake = cat(1,HRF_V2_R_mice_awake,HRF_V2_R);

        % cat r_MRF
        r_MRF_M2_L_mice_awake = cat(2,r_MRF_M2_L_mice_awake,r_MRF_M2_L);
        r_MRF_M1_L_mice_awake = cat(2,r_MRF_M1_L_mice_awake,r_MRF_M1_L);
        r_MRF_SS_L_mice_awake = cat(2,r_MRF_SS_L_mice_awake,r_MRF_SS_L);
        r_MRF_P_L_mice_awake  = cat(2,r_MRF_P_L_mice_awake ,r_MRF_P_L );
        r_MRF_V1_L_mice_awake = cat(2,r_MRF_V1_L_mice_awake,r_MRF_V1_L);
        r_MRF_V2_L_mice_awake = cat(2,r_MRF_V2_L_mice_awake,r_MRF_V2_L);

        
        r_MRF_M2_R_mice_awake = cat(2,r_MRF_M2_R_mice_awake,r_MRF_M2_R);
        r_MRF_M1_R_mice_awake = cat(2,r_MRF_M1_R_mice_awake,r_MRF_M1_R);
        r_MRF_SS_R_mice_awake = cat(2,r_MRF_SS_R_mice_awake,r_MRF_SS_R);
        r_MRF_P_R_mice_awake  = cat(2,r_MRF_P_R_mice_awake ,r_MRF_P_R );
        r_MRF_V1_R_mice_awake = cat(2,r_MRF_V1_R_mice_awake,r_MRF_V1_R);
        r_MRF_V2_R_mice_awake = cat(2,r_MRF_V2_R_mice_awake,r_MRF_V2_R);

        %cat MRF
        MRF_M2_L_mice_awake = cat(1,MRF_M2_L_mice_awake,MRF_M2_L);
        MRF_M1_L_mice_awake = cat(1,MRF_M1_L_mice_awake,MRF_M1_L);
        MRF_SS_L_mice_awake = cat(1,MRF_SS_L_mice_awake,MRF_SS_L);
        MRF_P_L_mice_awake  = cat(1,MRF_P_L_mice_awake ,MRF_P_L );
        MRF_V1_L_mice_awake = cat(1,MRF_V1_L_mice_awake,MRF_V1_L);
        MRF_V2_L_mice_awake = cat(1,MRF_V2_L_mice_awake,MRF_V2_L);

        
        MRF_M2_R_mice_awake = cat(1,MRF_M2_R_mice_awake,MRF_M2_R);
        MRF_M1_R_mice_awake = cat(1,MRF_M1_R_mice_awake,MRF_M1_R);
        MRF_SS_R_mice_awake = cat(1,MRF_SS_R_mice_awake,MRF_SS_R);
        MRF_P_R_mice_awake  = cat(1,MRF_P_R_mice_awake ,MRF_P_R );
        MRF_V1_R_mice_awake = cat(1,MRF_V1_R_mice_awake,MRF_V1_R);
        MRF_V2_R_mice_awake = cat(1,MRF_V2_R_mice_awake,MRF_V2_R);
    end
end

%% Anesthetized
% Initialize HRF
r_HRF_M2_L_mice_anes = [];
r_HRF_M1_L_mice_anes = [];
r_HRF_SS_L_mice_anes = [];
r_HRF_P_L_mice_anes  = [];
r_HRF_V1_L_mice_anes = [];
r_HRF_V2_L_mice_anes = [];

r_HRF_M2_R_mice_anes = [];
r_HRF_M1_R_mice_anes = [];
r_HRF_SS_R_mice_anes = [];
r_HRF_P_R_mice_anes  = [];
r_HRF_V1_R_mice_anes = [];
r_HRF_V2_R_mice_anes = [];

HRF_M2_L_mice_anes = [];
HRF_M1_L_mice_anes = [];
HRF_SS_L_mice_anes = [];
HRF_P_L_mice_anes  = [];
HRF_V1_L_mice_anes = [];
HRF_V2_L_mice_anes = [];

HRF_M2_R_mice_anes = [];
HRF_M1_R_mice_anes = [];
HRF_SS_R_mice_anes = [];
HRF_P_R_mice_anes  = [];
HRF_V1_R_mice_anes = [];
HRF_V2_R_mice_anes = [];

% Initialize MRF
r_MRF_M2_L_mice_anes = [];
r_MRF_M1_L_mice_anes = [];
r_MRF_SS_L_mice_anes = [];
r_MRF_P_L_mice_anes  = [];
r_MRF_V1_L_mice_anes = [];
r_MRF_V2_L_mice_anes = [];

r_MRF_M2_R_mice_anes = [];
r_MRF_M1_R_mice_anes = [];
r_MRF_SS_R_mice_anes = [];
r_MRF_P_R_mice_anes  = [];
r_MRF_V1_R_mice_anes = [];
r_MRF_V2_R_mice_anes = [];

MRF_M2_L_mice_anes = [];
MRF_M1_L_mice_anes = [];
MRF_SS_L_mice_anes = [];
MRF_P_L_mice_anes  = [];
MRF_V1_L_mice_anes = [];
MRF_V2_L_mice_anes = [];

MRF_M2_R_mice_anes = [];
MRF_M1_R_mice_anes = [];
MRF_SS_R_mice_anes = [];
MRF_P_R_mice_anes  = [];
MRF_V1_R_mice_anes = [];
MRF_V2_R_mice_anes = [];

% Concatinate the matrix
for excelRow = [202 195 204 230 234 240]

    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    for n = 1:3
        disp(strcat(mouseName,', run#',num2str(n)))
        load(fullfile(saveDir,'HRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Regions_Upsample','.mat')))
        load(fullfile(saveDir,'MRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Regions_Upsample','.mat')))
        % cat r_HRF
        r_HRF_M2_L_mice_anes = cat(2,r_HRF_M2_L_mice_anes,r_HRF_M2_L);
        r_HRF_M1_L_mice_anes = cat(2,r_HRF_M1_L_mice_anes,r_HRF_M1_L);
        r_HRF_SS_L_mice_anes = cat(2,r_HRF_SS_L_mice_anes,r_HRF_SS_L);
        r_HRF_P_L_mice_anes  = cat(2,r_HRF_P_L_mice_anes ,r_HRF_P_L );
        r_HRF_V1_L_mice_anes = cat(2,r_HRF_V1_L_mice_anes,r_HRF_V1_L);
        r_HRF_V2_L_mice_anes = cat(2,r_HRF_V2_L_mice_anes,r_HRF_V2_L);

        
        r_HRF_M2_R_mice_anes = cat(2,r_HRF_M2_R_mice_anes,r_HRF_M2_R);
        r_HRF_M1_R_mice_anes = cat(2,r_HRF_M1_R_mice_anes,r_HRF_M1_R);
        r_HRF_SS_R_mice_anes = cat(2,r_HRF_SS_R_mice_anes,r_HRF_SS_R);
        r_HRF_P_R_mice_anes  = cat(2,r_HRF_P_R_mice_anes ,r_HRF_P_R );
        r_HRF_V1_R_mice_anes = cat(2,r_HRF_V1_R_mice_anes,r_HRF_V1_R);
        r_HRF_V2_R_mice_anes = cat(2,r_HRF_V2_R_mice_anes,r_HRF_V2_R);

        %cat HRF
        HRF_M2_L_mice_anes = cat(1,HRF_M2_L_mice_anes,HRF_M2_L);
        HRF_M1_L_mice_anes = cat(1,HRF_M2_L_mice_anes,HRF_M2_L);
        HRF_SS_L_mice_anes = cat(1,HRF_SS_L_mice_anes,HRF_SS_L);
        HRF_P_L_mice_anes  = cat(1,HRF_P_L_mice_anes ,HRF_P_L );
        HRF_V1_L_mice_anes = cat(1,HRF_V1_L_mice_anes,HRF_V1_L);
        HRF_V2_L_mice_anes = cat(1,HRF_V2_L_mice_anes,HRF_V2_L);

        
        HRF_M2_R_mice_anes = cat(1,HRF_M2_R_mice_anes,HRF_M2_R);
        HRF_M1_R_mice_anes = cat(1,HRF_M1_R_mice_anes,HRF_M1_R);
        HRF_SS_R_mice_anes = cat(1,HRF_SS_R_mice_anes,HRF_SS_R);
        HRF_P_R_mice_anes  = cat(1,HRF_P_R_mice_anes ,HRF_P_R );
        HRF_V1_R_mice_anes = cat(1,HRF_V1_R_mice_anes,HRF_V1_R);
        HRF_V2_R_mice_anes = cat(1,HRF_V2_R_mice_anes,HRF_V2_R);

        % cat r_MRF
        r_MRF_M2_L_mice_anes = cat(2,r_MRF_M2_L_mice_anes,r_MRF_M2_L);
        r_MRF_M1_L_mice_anes = cat(2,r_MRF_M1_L_mice_anes,r_MRF_M1_L);
        r_MRF_SS_L_mice_anes = cat(2,r_MRF_SS_L_mice_anes,r_MRF_SS_L);
        r_MRF_P_L_mice_anes  = cat(2,r_MRF_P_L_mice_anes ,r_MRF_P_L );
        r_MRF_V1_L_mice_anes = cat(2,r_MRF_V1_L_mice_anes,r_MRF_V1_L);
        r_MRF_V2_L_mice_anes = cat(2,r_MRF_V2_L_mice_anes,r_MRF_V2_L);

        
        r_MRF_M2_R_mice_anes = cat(2,r_MRF_M2_R_mice_anes,r_MRF_M2_R);
        r_MRF_M1_R_mice_anes = cat(2,r_MRF_M1_R_mice_anes,r_MRF_M1_R);
        r_MRF_SS_R_mice_anes = cat(2,r_MRF_SS_R_mice_anes,r_MRF_SS_R);
        r_MRF_P_R_mice_anes  = cat(2,r_MRF_P_R_mice_anes ,r_MRF_P_R );
        r_MRF_V1_R_mice_anes = cat(2,r_MRF_V1_R_mice_anes,r_MRF_V1_R);
        r_MRF_V2_R_mice_anes = cat(2,r_MRF_V2_R_mice_anes,r_MRF_V2_R);

        %cat MRF
        MRF_M2_L_mice_anes = cat(1,MRF_M2_L_mice_anes,MRF_M2_L);
        MRF_M1_L_mice_anes = cat(1,MRF_M1_L_mice_anes,MRF_M1_L);
        MRF_SS_L_mice_anes = cat(1,MRF_SS_L_mice_anes,MRF_SS_L);
        MRF_P_L_mice_anes  = cat(1,MRF_P_L_mice_anes ,MRF_P_L );
        MRF_V1_L_mice_anes = cat(1,MRF_V1_L_mice_anes,MRF_V1_L);
        MRF_V2_L_mice_anes = cat(1,MRF_V2_L_mice_anes,MRF_V2_L);

        
        MRF_M2_R_mice_anes = cat(1,MRF_M2_R_mice_anes,MRF_M2_R);
        MRF_M1_R_mice_anes = cat(1,MRF_M1_R_mice_anes,MRF_M1_R);
        MRF_SS_R_mice_anes = cat(1,MRF_SS_R_mice_anes,MRF_SS_R);
        MRF_P_R_mice_anes  = cat(1,MRF_P_R_mice_anes ,MRF_P_R );
        MRF_V1_R_mice_anes = cat(1,MRF_V1_R_mice_anes,MRF_V1_R);
        MRF_V2_R_mice_anes = cat(1,MRF_V2_R_mice_anes,MRF_V2_R);
    end
end

% %% Visualization
% % Visulize left regional masks
% figure('units','normalized','outerposition',[0 0 1 1])
% subplot(3,6,1)
% imagesc(mask_M2_L)
% axis image off
% title('M2 L')
% 
% subplot(3,6,2)
% imagesc(mask_M1_L)
% axis image off
% title('M1 L')
% 
% subplot(3,6,3)
% imagesc(mask_SS_L)
% axis image off
% title('SS L')
% 
% subplot(3,6,4)
% imagesc(mask_P_L)
% axis image off
% title('P L')
% 
% subplot(3,6,5)
% imagesc(mask_V1_L)
% axis image off
% title('V1 L')
% 
% subplot(3,6,6)
% imagesc(mask_V2_L)
% axis image off
% title('V2 L')
% 
% % HRF for left regions
% subplot(3,6,7)
% plot_distribution_prctile(t,HRF_M2_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_M2_L_mice_anes,'Color',[0 0 1])
% title('HRF for M2 L')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,8)
% plot_distribution_prctile(t,HRF_M1_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_M1_L_mice_anes,'Color',[0 0 1])
% title('HRF for M1 L')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,9)
% plot_distribution_prctile(t,HRF_SS_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_SS_L_mice_anes,'Color',[0 0 1])
% title('HRF for SS L')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,10)
% plot_distribution_prctile(t,HRF_P_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_P_L_mice_anes,'Color',[0 0 1])
% title('HRF for P L')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,11)
% plot_distribution_prctile(t,HRF_V1_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_V1_L_mice_anes,'Color',[0 0 1])
% title('HRF for V1 L')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,12)
% plot_distribution_prctile(t,HRF_V2_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_V2_L_mice_anes,'Color',[0 0 1])
% title('HRF for V2 L')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% % MRF for left regions
% subplot(3,6,13)
% plot_distribution_prctile(t,MRF_M2_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_M2_L_mice_anes,'Color',[0 0 1])
% title('MRF for M2 L')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,14)
% plot_distribution_prctile(t,MRF_M1_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_M1_L_mice_anes,'Color',[0 0 1])
% title('MRF for M1 L')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,15)
% plot_distribution_prctile(t,MRF_SS_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_SS_L_mice_anes,'Color',[0 0 1])
% title('MRF for SS L')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,16)
% plot_distribution_prctile(t,MRF_P_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_P_L_mice_anes,'Color',[0 0 1])
% title('MRF for P L')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,17)
% plot_distribution_prctile(t,MRF_V1_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_V1_L_mice_anes,'Color',[0 0 1])
% title('MRF for V1 L')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,18)
% plot_distribution_prctile(t,MRF_V2_L_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_V2_L_mice_anes,'Color',[0 0 1])
% title('MRF for V2 L')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% sgtitle('Left Side Regional NVC and NMC. Red is Awake and Blue is Anesthetized')
% 
% % Visulize right regional masks
% figure('units','normalized','outerposition',[0 0 1 1])
% subplot(3,6,1)
% imagesc(mask_M2_R)
% axis image off
% title('M2 R')
% 
% subplot(3,6,2)
% imagesc(mask_M1_R)
% axis image off
% title('M1 R')
% 
% subplot(3,6,3)
% imagesc(mask_SS_R)
% axis image off
% title('SS R')
% 
% subplot(3,6,4)
% imagesc(mask_P_R)
% axis image off
% title('P R')
% 
% subplot(3,6,5)
% imagesc(mask_V1_R)
% axis image off
% title('V1 R')
% 
% subplot(3,6,6)
% imagesc(mask_V2_R)
% axis image off
% title('V2 R')
% 
% % HRF for right regions
% subplot(3,6,7)
% plot_distribution_prctile(t,HRF_M2_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_M2_R_mice_anes,'Color',[0 0 1])
% title('HRF for M2 R')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,8)
% plot_distribution_prctile(t,HRF_M1_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_M1_R_mice_anes,'Color',[0 0 1])
% title('HRF for M1 R')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,9)
% plot_distribution_prctile(t,HRF_SS_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_SS_R_mice_anes,'Color',[0 0 1])
% title('HRF for SS R')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,10)
% plot_distribution_prctile(t,HRF_P_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_P_R_mice_anes,'Color',[0 0 1])
% title('HRF for P R')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,11)
% plot_distribution_prctile(t,HRF_V1_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_V1_R_mice_anes,'Color',[0 0 1])
% title('HRF for V1 R')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,12)
% plot_distribution_prctile(t,HRF_V2_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,HRF_V2_R_mice_anes,'Color',[0 0 1])
% title('HRF for V2 R')
% xlim([-3 5])
% ylim([-0.05 0.15])
% xlabel('Time(s)')
% grid on
% 
% % MRF for right regions
% subplot(3,6,13)
% plot_distribution_prctile(t,MRF_M2_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_M2_R_mice_anes,'Color',[0 0 1])
% title('MRF for M2 R')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,14)
% plot_distribution_prctile(t,MRF_M1_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_M1_R_mice_anes,'Color',[0 0 1])
% title('MRF for M1 R')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,15)
% plot_distribution_prctile(t,MRF_SS_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_SS_R_mice_anes,'Color',[0 0 1])
% title('MRF for SS R')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,16)
% plot_distribution_prctile(t,MRF_P_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_P_R_mice_anes,'Color',[0 0 1])
% title('MRF for P R')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,17)
% plot_distribution_prctile(t,MRF_V1_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_V1_R_mice_anes,'Color',[0 0 1])
% title('MRF for V1 R')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% 
% subplot(3,6,18)
% plot_distribution_prctile(t,MRF_V2_R_mice_awake,'Color',[1 0 0])
% hold on
% plot_distribution_prctile(t,MRF_V2_R_mice_anes,'Color',[0 0 1])
% title('MRF for V2 R')
% xlim([-3 5])
% ylim([-0.03 0.04])
% xlabel('Time(s)')
% grid on
% sgtitle('Right Side Regional NVC and NMC. Red is Awake and Blue is Anesthetized')

%% Calculate T, W, A, r 
% Calculate T, W, A for awake median HRF for each region
for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
    eval(strcat('HRF_',region{1},'_mice_awake_median = median(HRF_',region{1},'_mice_awake);'))
    eval(strcat('[A_HRF_',region{1},'_mice_awake,T_HRF_',region{1},'_mice_awake,W_HRF_',region{1},'_mice_awake] = ',...
        'findpeaks(HRF_',region{1},'_mice_awake_median,t,',char(39),'MinPeakProminence',char(39),',',num2str(0.001),');'))
end

% Calculate T, W, A for anes median HRF for each region
for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
    eval(strcat('HRF_',region{1},'_mice_anes_median = median(HRF_',region{1},'_mice_anes);'))
    eval(strcat('[A_HRF_',region{1},'_mice_anes,T_HRF_',region{1},'_mice_anes,W_HRF_',region{1},'_mice_anes] = ',...
        'findpeaks(HRF_',region{1},'_mice_anes_median,t,',char(39),'MinPeakProminence',char(39),',',num2str(0.0006),');'))
end

% Calculate T,W,A,r for median MRF for each region
for condition = {'awake','anes'}
    for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
        eval(strcat('MRF_',region{1},'_mice_',condition{1},'_median = median(MRF_',region{1},'_mice_',condition{1},');'));        
        eval(strcat('[A_MRF_',region{1},'_mice_',condition{1},',T_MRF_',region{1},'_mice_',condition{1},',W_MRF_',region{1},'_mice_',condition{1},'] = ',...
            'findpeaks(MRF_',region{1},'_mice_',condition{1},'_median,t,',char(39),'MinPeakProminence',char(39),',',num2str(0.0008),');'));
    end
end

% Calculate median r
for condition = {'awake','anes'}
    for h = {'HRF_','MRF_'}
        for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
        temp = strcat('r_',h{1},region{1},'_mice_',condition{1},'_median = median(r_',h,region{1},'_mice_',condition{1},');');
        eval(temp{1})
        end
    end
end

%% Maps with regional values
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
       for var = {'T','W','A'}
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map =  zeros(1,128*128);'))
           for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}                
                eval(strcat(var{1},'_',h{1},'_',condition{1},'_map(mask_',region{1},'(:))=',var{1},'_',h{1},'_',region{1},'_mice_',condition{1},';'))
           end
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map = reshape(',var{1},'_',h{1},'_',condition{1},'_map,128,128);'))
        end
    end
end

for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map =  zeros(1,128*128);'))
           for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}                
                eval(strcat('r_',h{1},'_',condition{1},'_map(mask_',region{1},'(:))=','r_',h{1},'_',region{1},'_mice_',condition{1},'_median;'))
           end
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map = reshape(',var{1},'_',h{1},'_',condition{1},'_map,128,128);'))
    end
end

%% HRF and MRF for the whole brain
% total number of pixels in all interested regions
for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
    eval(strcat('pixNum_',region{1},' = sum(mask_',region{1},',',char(39),'all',char(39),');'));
end
% pixel number in each region
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        % initialization
        disp(strcat(condition,h))
        eval(strcat(h{1},'_',condition{1},'=[];'))
        for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
            disp(region)
            eval(strcat('temp = repmat(',h{1},'_',region{1},'_mice_',condition{1},'_median,','pixNum_',region{1},',1);'))
            eval(strcat(h{1},'_',condition{1},'= cat(1,',h{1},'_',condition{1},',temp);'))
        end
        eval(strcat(h{1},'_',condition{1},'_median = median(',h{1},'_',condition{1},');'))
        saveName = "D:\XiaodanPaperData\cat\deconvolution_regions.mat";
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),h{1},'_',condition{1},'_median',char(39),',',...
                char(39),h{1},'_',condition{1},char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),h{1},'_',condition{1},'_median',char(39),',',...
                char(39),h{1},'_',condition{1},char(39),')'))
        end
    end
end

%% Visualization
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\GoodWL.mat")
mask = 0;
for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
    temp = strcat('mask = mask + mask_',region,';');
    eval(temp{1})
end


for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        figure('units','normalized','outerposition',[0 0 1 1])
        subplot(2,3,4)
        temp = strcat('imagesc(r_',h{1},'_',condition{1},'_map,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
        cb=colorbar;
        clim([-1 1])
        axis image off
        colormap jet
        title('r')
        set(gca,'FontSize',14,'FontWeight','Bold')

        subplot(2,3,5)
        eval(strcat('plot_distribution_prctile(t,',h{1},'_',condition{1},',',char(39),'Color',char(39),',[0 0 0])'))   
        title(h)
        xlabel('Time(s)')
        xlim([-3 10])
        set(gca,'FontSize',14,'FontWeight','Bold')

        subplot(2,3,1)
        eval(strcat('imagesc(T_',h{1},'_',condition{1},'_map,',char(39),'AlphaData',char(39),',mask)'));
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
        cb=colorbar;
        
        if strcmp(h,'HRF')
            clim([0 2])
        else
            clim([0 0.1])
        end
        axis image off
        cmocean('ice')
        title('T(s)')
        set(gca,'FontSize',14,'FontWeight','Bold')

        subplot(2,3,2)
        temp = strcat('imagesc(W_',h{1},'_',condition{1},'_map,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
        cb=colorbar;
        if strcmp(h,'HRF')
            clim([0 3])
        else
            clim([0 0.6])
        end
        axis image off
        cmocean('ice')
        title('W(s)')
        set(gca,'FontSize',14,'FontWeight','Bold')

        subplot(2,3,3)
        temp = strcat('imagesc(A_',h{1},'_',condition{1},'_map,',char(39),'AlphaData',char(39),',mask)');
        eval(temp) 
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
        cb=colorbar;
      
        clim([0 0.01])

        axis image off
        cmocean('ice')
        title('A')
        set(gca,'FontSize',14,'FontWeight','Bold')
        sgtitle(strcat('Deconvolution',{' '},h,' for RGECO mice under',{' '},condition,' condition'))

    end
end


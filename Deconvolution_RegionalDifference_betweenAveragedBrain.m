% load
clear all;close all;clc
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\GoodWL.mat")
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
excelRows_awake = [181 183 185 228 232 236];
excelRows_anes  = [202 195 204 230 234 240];
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        eval(strcat('load(',char(39),saveName,char(39),',',...
            char(39),'T_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
            char(39),'W_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
            char(39),'A_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
            char(39),'r_',h{1},'_mice_',condition{1},'_allRegions',char(39),...
            ')'))
    end
end

numMice = eval(strcat('length(excelRows_',condition{1},');'));
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

%% mask
load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')
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
% Region inside of mouse brain
mask = AtlasSeeds.*xform_isbrain_mice;
mask(isnan(mask)) = 0;
% Exclude FRP an PL
mask(mask==1)  = 0;
mask(mask==2)  = 0;
mask(mask==5)  = 0;
mask(mask==26) = 0;
mask(mask==27) = 0;
mask(mask==30) = 0;
% median
% table of comparison between M SS P V RS A
mask_region_ind = cell(1,6);
mask_region_ind{1} = [3,4,28,29];
mask_region_ind{2} = [6:13,31:38];
mask_region_ind{3} = [14,19,20,39,44,45];
mask_region_ind{4} = [15:18,40:43];
mask_region_ind{5} = [21:23,46:48];
mask_region_ind{6} = [24,25,49,50];

mask_combined = zeros(128*128,6);
mask_combined(ismember(mask,mask_region_ind{1}),1) = 1; % motor
mask_combined(ismember(mask,mask_region_ind{2}),2) = 1; % Somatosensory
mask_combined(ismember(mask,mask_region_ind{3}),3) = 1; % Parietal
mask_combined(ismember(mask,mask_region_ind{4}),4) = 1; % Visual
mask_combined(ismember(mask,mask_region_ind{5}),5) = 1; % Retrosplenial
mask_combined(ismember(mask,mask_region_ind{6}),6) = 1; % Auditory


% pixel number for each region
pixelNum = zeros(1,50);
for region = 1:50
    mask_region = zeros(128,128);
    mask_region(mask == region) = 1;
    pixelNum(region) = sum(mask_region,'all');
end

% Calculate T W A r for each mouse for each combined region
for var = {'T','W','A','r'}
    for condition = {'awake','anes'}
        for h = {'HRF','MRF'}
            eval(strcat(var{1},'_',h{1},'_',condition{1},'_combined = nan(6,6);'))% mouse*combined region
            eval(strcat(var{1},'_',h{1},'_',condition{1},'_brain = nan(6,1);'))% mouse*combined region
            for mouseInd = 1:6
                tempBrain = 0;
                pixelNum_brain = 0;
                for ii = 1:6
                    pixelNum_combined = sum(pixelNum(mask_region_ind{ii}));
                    pixelNum_brain = pixelNum_brain+pixelNum_combined;
                    temp = 0;
                    for jj = mask_region_ind{ii}
                        eval(strcat('bool = isnan(',var{1},'_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,jj));'))
                        if ~bool
                            eval(strcat('temp = temp+',...
                                var{1},'_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,jj)*pixelNum(jj)/pixelNum_combined;'))
                        end
                    end
                    if temp ==0
                        temp=NaN;
                    end
                    eval(strcat(var{1},'_',h{1},'_',condition{1},'_combined(mouseInd,ii) = temp;'))
                    if ~isnan(temp)
                        tempBrain = tempBrain +temp*pixelNum_combined;
                    end
                end
                tempBrain = tempBrain/pixelNum_brain;
                if tempBrain ==0
                    tempBrain =NaN;
                end
                eval(strcat(var{1},'_',h{1},'_',condition{1},'_brain(mouseInd) = tempBrain;'))
            end
        end
    end
end


% Calculate h and p
for h = {'HRF','MRF'}
    for condition = {'awake','anes'}
        for var = {'T','W','A','r'}
            eval(strcat('p_',var{1},'_',h{1},'_',condition{1},'_combined_brain = nan(6,1);'))
            eval(strcat('h_',var{1},'_',h{1},'_',condition{1},'_combined_brain = zeros(6,1);'))
            for ii = 1:6
                eval(strcat('[h_',var{1},'_',h{1},'_',condition{1},'_combined_brain(ii),',...
                    'p_',var{1},'_',h{1},'_',condition{1},'_combined_brain(ii)] = ',...
                    ' ttest(',var{1},'_',h{1},'_',condition{1},'_combined(:,ii),',...
                    var{1},'_',h{1},'_',condition{1},'_brain,',...
                    char(39),'Tail',char(39),',',char(39),'both',char(39),');'))
            end
        end

    end
end

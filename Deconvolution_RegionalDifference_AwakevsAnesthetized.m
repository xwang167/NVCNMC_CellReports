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

%% mean difference threshold with WN p value between conditions
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
% mean
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        for var = {'T','W','A'}
              eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'_mean = nanmean(',var{1},'_',h{1},'_mice_',condition{1},'_allRegions);'));
        end
    end
end
% mean map for T W A
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
       for var = {'T','W','A'}
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map_mean =  zeros(1,128*128);'))
           for region = [3:25,28:50]  
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat(var{1},'_',h{1},'_',condition{1},'_map_mean(mask_region(:))=',...
                    var{1},'_',h{1},'_mice_',condition{1},'_mean(region);'))
           end
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map_mean = reshape(',var{1},'_',h{1},'_',condition{1},'_map_mean,128,128);'))           
       end
       if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_',condition{1},'_map_mean',char(39),',',...
                char(39),'W_',h{1},'_',condition{1},'_map_mean',char(39),',',...
                char(39),'A_',h{1},'_',condition{1},'_map_mean',char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_',condition{1},'_map_mean',char(39),',',...
                char(39),'W_',h{1},'_',condition{1},'_map_mean',char(39),',',...
                char(39),'A_',h{1},'_',condition{1},'_map_mean',char(39),')'))
        end
    end
end

% Mean map for r
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
           eval(strcat('r_',h{1},'_',condition{1},'_map_mean =  zeros(1,128*128);'))
           for region = [3:25,28:50] 
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat('r_',h{1},'_',condition{1},'_map_mean(mask_region(:))=nanmean(r_',h{1},'_mice_',condition{1},'_allRegions(:,region));'))
           end
           eval(strcat('r_',h{1},'_',condition{1},'_map_mean = reshape(r_',h{1},'_',condition{1},'_map_mean,128,128);'))
           if exist(saveName,'file')
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'r_',h{1},'_',condition{1},'_map_mean',char(39),',',...
                   char(39),'-append',char(39),')'))
           else
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'r_',h{1},'_',condition{1},'_map_mean',char(39),')'))
           end
    end
end

%% Visualization
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\GoodWL.mat")
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        figure('units','normalized','outerposition',[0 0 1 1])

        ax1 = subplot(2,2,1);
        imagesc(xform_WL);
        hold on;
        eval(strcat('imagesc(T_',h{1},'_',condition{1},'_map_mean,',char(39),'AlphaData',char(39),',mask)'));
        
        
        cb=colorbar;
        cb.Label.String = 'Seconds';
        if strcmp(h,'HRF')
            clim([0 2])
        else
            clim([0 0.1])
        end
        axis image off
        colormap(ax1,cmocean('ice'))
        title('T(s)')
        set(gca,'FontSize',14,'FontWeight','Bold')

        ax2 = subplot(2,2,2);
        imagesc(xform_WL)
        hold on;
        temp = strcat('imagesc(W_',h{1},'_',condition{1},'_map_mean,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)
        cb=colorbar;
        cb.Label.String = 'Seconds';
        if strcmp(h,'HRF')
            clim([0 3])
        else
            clim([0 0.6])
        end
        axis image off
        colormap(ax2,cmocean('ice'))
        title('W(s)')
        set(gca,'FontSize',14,'FontWeight','Bold')

        ax3 = subplot(2,2,3);
        imagesc(xform_WL);
        hold on;
        temp = strcat('imagesc(A_',h{1},'_',condition{1},'_map_mean,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)       
        cb=colorbar;
        cb.Label.String = 'Arbitrary Unit';
        if strcmp(h,'HRF')
            clim([0 0.005])
        else
            clim([0 0.002])
        end
        axis image off
        colormap(ax3,cmocean('ice'))
        title('A')
        set(gca,'FontSize',14,'FontWeight','Bold')

        ax4 = subplot(2,2,4);
        imagesc(xform_WL);
        hold on;
        temp = strcat('imagesc(r_',h{1},'_',condition{1},'_map_mean,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)       
        cb=colorbar;
        cb.Label.String = 'Correlation Coefficient';
        clim([0 1])
        axis image off
        colormap(ax4,brewermap(256, '-Spectral'));
        title('r')
        set(gca,'FontSize',14,'FontWeight','Bold')


        sgtitle(strcat('Deconvolution',{' '},h,' for RGECO mice under',{' '},condition,' condition, Mean'))
        saveName =  fullfile('D:\XiaodanPaperData\cat', strcat('Deconvoltuion_',h{1},'_',condition{1}));
        saveas(gcf,strcat(saveName,'_mean.fig'))
        saveas(gcf,strcat(saveName,'_mean.png'))
    end
end
% t test
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for h = {'HRF','MRF'}
    for var = {'T','W','A','r'}
        eval(strcat('p_',var{1},'_',h{1},' = nan(1,50);'));
        eval(strcat('h_',var{1},'_',h{1},' = zeros(1,50);'));
        for region = [3,4,6:25,28,29,31:50]
            eval(strcat('[h_',var{1},'_',h{1},'(region),','p_',var{1},'_',h{1},...
                '(region)] = ttest(',var{1},'_',h{1},'_mice_awake_allRegions(:,region)',...
                ',',var{1},'_',h{1},'_mice_anes_allRegions(:,region));'))
        end
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'p_',var{1},'_',h{1},char(39),',',...
                char(39),'h_',var{1},'_',h{1},char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'p_',var{1},'_',h{1},char(39),',',...
                char(39),'h_',var{1},'_',h{1},char(39),')'))
        end
    end
end
% h map
for var = {'T','W','A','r'}
    for h = {'HRF','MRF'}        
           eval(strcat('h_',var{1},'_',h{1},'_map =  zeros(1,128*128);'))
           for region = [3:25,28:50] 
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat('h_',var{1},'_',h{1},'_map(mask_region(:))=h_',var{1},'_',h{1},'(region);'))
           end
           eval(strcat('h_',var{1},'_',h{1},'_map = reshape(','h_',var{1},'_',h{1},'_map,128,128);'))
           if exist(saveName,'file')
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'h_',var{1},'_',h{1},'_map',char(39),',',...
                   char(39),'-append',char(39),')'))
           else
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'h_',var{1},'_',h{1},'_map',char(39),')'))
           end
    end
end

% difference map threshold by h

for h = {'HRF','MRF'}
    figure('units','normalized','outerposition',[0 0 1 1])

    ax1 = subplot(2,2,1);
    eval(strcat('T_',h{1},'_map_mean_difference = T_',h{1},'_anes_map_mean-T_',h{1},'_awake_map_mean;'))
    imagesc(xform_WL)
    hold on;
    eval(strcat('imagesc(T_',h{1},'_map_mean_difference,',char(39),'AlphaData',char(39),',h_T_',h{1},'_map)'));
    
    
    cb=colorbar;
    cb.Location = "southoutside";
    cb.Label.String = 'Seconds';
    if strcmp(h,'HRF')
        clim([-0.6 0.6])
    else
        clim([-0.03 0.03])
    end
    axis image off
    colormap(ax1,brewermap(256, '-Spectral'))
    title('T(s)')
    set(gca,'FontSize',14,'FontWeight','Bold')

    ax2 = subplot(2,2,2);
    eval(strcat('W_',h{1},'_map_mean_difference = W_',h{1},'_anes_map_mean-W_',h{1},'_awake_map_mean;'))
    imagesc(xform_WL)
    hold on;
    eval(strcat('imagesc(W_',h{1},'_map_mean_difference,',char(39),'AlphaData',char(39),',h_W_',h{1},'_map)'));
    cb=colorbar;
    cb.Location = "southoutside";
    cb.Label.String = 'Seconds';
    if strcmp(h,'HRF')
        clim([-1.5 1.5])
    else
        clim([-0.2 0.2])
    end
    axis image off
    colormap(ax2,brewermap(256, '-Spectral'))
    title('W(s)')
    set(gca,'FontSize',14,'FontWeight','Bold')

    ax3 = subplot(2,2,3);
    eval(strcat('A_',h{1},'_map_mean_difference = A_',h{1},'_anes_map_mean-A_',h{1},'_awake_map_mean;'))
    imagesc(xform_WL)
    hold on;
    eval(strcat('imagesc(A_',h{1},'_map_mean_difference,',char(39),'AlphaData',char(39),',h_A_',h{1},'_map)'));
    cb=colorbar;
    cb.Location = "southoutside";
    cb.Label.String = 'Arbitrary Unit';
    if strcmp(h,'HRF')
        clim([-0.0036 0.0036])
    else
        clim([-0.0004 0.0004])
    end
    axis image off
    colorbar
    colormap(ax3,brewermap(256, '-Spectral'))
    title('A')
    set(gca,'FontSize',14,'FontWeight','Bold')

    ax4 = subplot(2,2,4);
    eval(strcat('r_',h{1},'_map_mean_difference = r_',h{1},'_anes_map_mean-r_',h{1},'_awake_map_mean;'))
    imagesc(xform_WL)
    hold on;
    eval(strcat('imagesc(r_',h{1},'_map_mean_difference,',char(39),'AlphaData',char(39),',h_r_',h{1},'_map)'));
    cb=colorbar;
    cb.Location = "southoutside";
    cb.Label.String = 'Correlation Coefficient';
    if strcmp(h,'HRF')
        clim([-0.2 0.2])
    else
        clim([-0.5 0.5])
    end
    axis image off
    colormap(ax4,brewermap(256, '-Spectral'));
    title('r')
    set(gca,'FontSize',14,'FontWeight','Bold')


    sgtitle(strcat(h{1},{' '},'Mean Difference (Anesthetized - Awake) for RGECO mice, Only Region with Significant Difference is Shown'))
    saveName =  fullfile('D:\XiaodanPaperData\cat', strcat('Deconvoltuion_',h{1},'_',condition{1}));
    saveas(gcf,strcat(saveName,'_mean_difference_h.fig'))
    saveas(gcf,strcat(saveName,'_mean_difference_h.png'))
end







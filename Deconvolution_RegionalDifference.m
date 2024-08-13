% load
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



%% median difference threshold with WN p value between conditions
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
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        for var = {'T','W','A'}
              eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'_median = nanmedian(',var{1},'_',h{1},'_mice_',condition{1},'_allRegions);'));
        end
    end
end
% median map for T W A
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
       for var = {'T','W','A'}
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map_median =  zeros(1,128*128);'))
           for region = [3:25,28:50]  
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat(var{1},'_',h{1},'_',condition{1},'_map_median(mask_region(:))=',...
                    var{1},'_',h{1},'_mice_',condition{1},'_median(region);'))
           end
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map_median = reshape(',var{1},'_',h{1},'_',condition{1},'_map_median,128,128);'))           
       end
       if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_',condition{1},'_map_median',char(39),',',...
                char(39),'W_',h{1},'_',condition{1},'_map_median',char(39),',',...
                char(39),'A_',h{1},'_',condition{1},'_map_median',char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_',condition{1},'_map_median',char(39),',',...
                char(39),'W_',h{1},'_',condition{1},'_map_median',char(39),',',...
                char(39),'A_',h{1},'_',condition{1},'_map_median',char(39),')'))
        end
    end
end

% Median map for r
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
           eval(strcat('r_',h{1},'_',condition{1},'_map_median =  zeros(1,128*128);'))
           for region = [3:25,28:50] 
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat('r_',h{1},'_',condition{1},'_map_median(mask_region(:))=median(r_',h{1},'_mice_',condition{1},'_allRegions(:,region));'))
           end
           eval(strcat('r_',h{1},'_',condition{1},'_map_median = reshape(r_',h{1},'_',condition{1},'_map_median,128,128);'))
           if exist(saveName,'file')
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'r_',h{1},'_',condition{1},'_map_median',char(39),',',...
                   char(39),'-append',char(39),')'))
           else
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'r_',h{1},'_',condition{1},'_map_median',char(39),')'))
           end
    end
end

%% Visualization
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\GoodWL.mat")
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        figure('units','normalized','outerposition',[0 0 1 1])

        ax1 = subplot(2,2,1);
        eval(strcat('imagesc(T_',h{1},'_',condition{1},'_map_median,',char(39),'AlphaData',char(39),',mask)'));
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
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
        temp = strcat('imagesc(W_',h{1},'_',condition{1},'_map_median,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
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
        temp = strcat('imagesc(A_',h{1},'_',condition{1},'_map_median,',char(39),'AlphaData',char(39),',mask)');
        eval(temp) 
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
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
        temp = strcat('imagesc(r_',h{1},'_',condition{1},'_map_median,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
        cb=colorbar;
        cb.Label.String = 'Correlation Coefficient';
        clim([0 1])
        axis image off
        colormap(ax4,brewermap(256, '-Spectral'));
        title('r')
        set(gca,'FontSize',14,'FontWeight','Bold')


        sgtitle(strcat('Deconvolution',{' '},h,' for RGECO mice under',{' '},condition,' condition, Median'))
        saveName =  fullfile('D:\XiaodanPaperData\cat', strcat('Deconvoltuion_',h{1},'_',condition{1}));
        saveas(gcf,strcat(saveName,'_median.fig'))
        saveas(gcf,strcat(saveName,'_median.png'))
    end
end
% WN test
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for h = {'HRF','MRF'}
    for var = {'T','W','A','r'}
        eval(strcat('p_',var{1},'_',h{1},' = nan(1,50);'));
        eval(strcat('h_',var{1},'_',h{1},' = zeros(1,50);'));
        for region = [3,4,6:25,28,29,31:50]
            eval(strcat('[p_',var{1},'_',h{1},'(region),','h_',var{1},'_',h{1},...
                '(region)] = ranksum(',var{1},'_',h{1},'_mice_awake_allRegions(:,region)',...
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
    eval(strcat('T_',h{1},'_map_median_difference = T_',h{1},'_anes_map_median-T_',h{1},'_awake_map_median;'))
    eval(strcat('imagesc(T_',h{1},'_map_median_difference,',char(39),'AlphaData',char(39),',h_T_',h{1},'_map)'));
    hold on;
    eval(strcat('imagesc(xform_WL,',char(39),'AlphaData',char(39),',1-h_T_',h{1},'_map)'));
    cb=colorbar;
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
    eval(strcat('W_',h{1},'_map_median_difference = W_',h{1},'_anes_map_median-W_',h{1},'_awake_map_median;'))
    eval(strcat('imagesc(W_',h{1},'_map_median_difference,',char(39),'AlphaData',char(39),',h_W_',h{1},'_map)'));
    hold on;
    eval(strcat('imagesc(xform_WL,',char(39),'AlphaData',char(39),',1-h_W_',h{1},'_map)'));
    cb=colorbar;
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
    eval(strcat('A_',h{1},'_map_median_difference = A_',h{1},'_anes_map_median-A_',h{1},'_awake_map_median;'))
    eval(strcat('imagesc(A_',h{1},'_map_median_difference,',char(39),'AlphaData',char(39),',h_A_',h{1},'_map)'));
    hold on;
    eval(strcat('imagesc(xform_WL,',char(39),'AlphaData',char(39),',1-h_A_',h{1},'_map)'));
    cb=colorbar;
    cb.Label.String = 'Arbitrary Unit';
    if strcmp(h,'HRF')
        clim([-0.0036 0.0036])
    else
        clim([-0.0004 0.0004])
    end
    axis image off
    colormap(ax3,brewermap(256, '-Spectral'))
    title('A')
    set(gca,'FontSize',14,'FontWeight','Bold')

    ax4 = subplot(2,2,4);
    eval(strcat('r_',h{1},'_map_median_difference = r_',h{1},'_anes_map_median-r_',h{1},'_awake_map_median;'))
    eval(strcat('imagesc(r_',h{1},'_map_median_difference,',char(39),'AlphaData',char(39),',h_r_',h{1},'_map)'));
    hold on;
    eval(strcat('imagesc(xform_WL,',char(39),'AlphaData',char(39),',1-h_r_',h{1},'_map)'));
    cb=colorbar;
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


    sgtitle(strcat(h{1},{' '},'Median Difference (Anesthetized - Awake) for RGECO mice, Only Region with Significant Difference is Shown'))
    saveName =  fullfile('D:\XiaodanPaperData\cat', strcat('Deconvoltuion_',h{1},'_',condition{1}));
    saveas(gcf,strcat(saveName,'_median_difference_h.fig'))
    saveas(gcf,strcat(saveName,'_median_difference_h.png'))
end


%% Difference between regions

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

% Visualize the mask
figure
for ii = 1:6
    subplot(1,6,ii)
    imagesc(reshape(mask_combined(:,ii),128,128))
    axis image off
    switch ii
        case 1
            title('Motor')
        case 2
            title('Somatosensory')
        case 3
            title('Parietal')
        case 4
            title('Visual')
        case 5
            title('Retrosplenial')
        case 6
            title('Auditory')
    end
end          
colormap('gray')

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
            for mouseInd = 1:6
                for ii = 1:6
                    pixelNum_combined = sum(pixelNum(mask_region_ind{ii}));
                    temp = 0;
                    for jj = mask_region_ind{ii}
                        eval(strcat('temp = temp+',...
                            var{1},'_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,jj)*pixelNum(jj)/pixelNum_combined;'))
                    end
                    eval(strcat(var{1},'_',h{1},'_',condition{1},'_combined(mouseInd,ii) = temp;'))
                end
            end

        end
    end
end

% Calculate median map for combined region
close all
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        figure('units','normalized','outerposition',[0 0 1 1])
        kk = 1;
        for var = {'T','W','A','r'}
            eval(strcat(var{1},'_',h{1},'_',condition{1},'_combined_map = nan(128,128);'))% mouse*combined region
            for ii = 1:6
                eval(strcat(var{1},'_',h{1},'_',condition{1},'_combined_map(logical(mask_combined(:,ii))) = median(',var{1},'_',h{1},'_',condition{1},'_combined(:,ii));'))
            end
            ax = subplot(2,2,kk);
            eval(strcat('imagesc(',var{1},'_',h{1},'_',condition{1},'_combined_map,',...
                char(39),'AlphaData',char(39),',mask)'));
            hold on
            imagesc(xform_WL,'AlphaData',1-mask);
            axis image off
            if strcmp('r',var{1})
                colormap(ax,brewermap(256, '-Spectral'));
            else
                colormap(ax,cmocean('ice'))
            end
            kk = kk+1;
            cb = colorbar;
            if strcmp('r',var{1})
                clabel = 'Correlation Coefficient';
            elseif strcmp('A',var{1})
                clabel = 'Arbitrary Unit';
            else
                clabel = 'Seconds';
            end
            cb.Label.String = clabel;
            title(var{1})
        end
        % Visualize median map for combined region
        temp = strcat('sgtitle(',char(39),'Median for Combined Region for',{' '},h{1},{' '},'under',{' '},condition{1},' Condition',char(39),')');
        eval(temp{1})
    end
end





% Calculate h and p
for h = {'HRF','MRF'}
    for condition = {'awake','anes'}
        kk = 1;
        figure('units','normalized','outerposition',[0 0 0.6 1])
        for var = {'T','W','A','r'}
            eval(strcat('p_',var{1},'_',h{1},'_',condition{1},'_combined = nan(6,6);'))
            eval(strcat('h_',var{1},'_',h{1},'_',condition{1},'_combined = zeros(6,6);'))
            eval(strcat('difference_',var{1},'_',h{1},'_',condition{1},'_combined = nan(6,6);'))
            for ii = 1:6
                for jj = 1:6
                    eval(strcat('[p_',var{1},'_',h{1},'_',condition{1},'_combined(ii,jj),',...
                        'h_',var{1},'_',h{1},'_',condition{1},'_combined(ii,jj)] = ',...
                        ' ranksum(',var{1},'_',h{1},'_',condition{1},'_combined(:,ii),',...
                        var{1},'_',h{1},'_',condition{1},'_combined(:,jj));'))
                    eval(strcat('difference_',var{1},'_',h{1},'_',condition{1},'_combined(ii,jj) = ',...
                        'median(',var{1},'_',h{1},'_',condition{1},'_combined(:,ii))-',...
                        'median(',var{1},'_',h{1},'_',condition{1},'_combined(:,jj));'))
                end
            end
            eval(strcat('h_',var{1},'_',h{1},'_',condition{1},'_combined(logical(triu(ones(6)))) = 0;')) 
            subplot(2,2,kk)
            eval(strcat('imagesc(difference_',var{1},'_',h{1},'_',condition{1},'_combined,',...
                char(39),'AlphaData',char(39),',h_',var{1},'_',h{1},'_',condition{1},'_combined)'));
            axis image
            ax = gca;
            ax.TickLength = [0, 0];
            xticklabels({'M','SS','P','V','RS','A'})
            yticklabels({'M','SS','P','V','RS','A'})
            colorbar
            colormap(brewermap(256, '-Spectral'));
            title(var{1})
            kk = kk+1;
            set(gca,'Color','k')
        end
        sgtitle(strcat(h{1},{' '},condition{1},{' '},'Median Difference (y - x) for RGECO mice, Only Significant Difference is Shown'))
    end
end

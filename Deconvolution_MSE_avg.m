clear ;close all;clc
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
freq_new     = 250;
t_kernel = 30;
t = (-3*freq_new:(t_kernel-3)*freq_new-1)/freq_new ;

load("AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')

% Overlapped brain mask
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
% total number of pixels in all interested regions
pixelNum = zeros(1,50);
for region = [3,4,6:25,28,29,31:50]
    mask_region = zeros(128,128);
    mask_region(mask == region) = 1;
    pixelNum(region) = sum(mask_region,'all');
end
pixelNumTotal = sum(pixelNum);
%% Initialize
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}   
        eval(strcat('MSE_norm_',h{1},'_mice_',condition{1},'_allRegions = nan(6,50);'))   
        eval(strcat('MSE_norm_',h{1},'_mice_',condition{1},' = zeros(6,1);'))  
    end
end

excelRows_awake = [181 183 185 228 232 236];
excelRows_anes  = [202 195 204 230 234 240];

%% Concatinate the matrix
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for condition = {'awake','anes'}
    mouseInd =1;
    for excelRow = eval(strcat('excelRows_',condition{1}))
        [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
        recDate = excelRaw{1}; recDate = string(recDate);
        mouseName = excelRaw{2}; mouseName = string(mouseName);
        saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
        sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
        for h = {'HRF','MRF'}
             eval(strcat('MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions = [];'))
        end
        for n = 1:3
            disp(strcat(mouseName,', run #',num2str(n)))
            load(fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Upsample.mat')))
            load(fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Upsample.mat')))
            % cat r,MRF, HRF
            for h = {'HRF','MRF'}
                eval(strcat( 'MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions = cat(1,MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions,MSE_norm_',h{1},');'))
            end    
        end

        for h = {'HRF','MRF'}
            eval(strcat( 'MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions = mean(MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions);'))
            saveName_mouse = fullfile(saveDir,strcat(h{1},'_Upsample'), strcat(recDate,'-',mouseName,'_',h{1},'_Upsample.mat'));
            if exist(saveName_mouse,'file')
                eval(strcat('save(',char(39),saveName_mouse,char(39),',',...
                    char(39),'MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions',char(39),',',...
                    char(39),'-append',char(39),')'))
            else
                eval(strcat('save(',char(39),saveName_mouse,char(39),',',...
                    char(39),'MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions',char(39),')'))
            end

            eval(strcat( 'MSE_norm_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,:) = MSE_norm_',h{1},'_mouse_',condition{1},'_allRegions;'))           
        end        
        mouseInd = mouseInd+1;
    end
    for h = {'HRF','MRF'}
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'MSE_norm_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'MSE_norm_',h{1},'_mice_',condition{1},'_allRegions',char(39),')'))
        end
    end
end


%% Average across all regions 
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        for mouseInd = 1:6
            for region = [3,4,6:25,28,29,31:50]
                eval(strcat('temp = squeeze(nanmean(MSE_norm_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,region)))*pixelNum(region)/pixelNumTotal;'))
                eval(strcat( 'MSE_norm_',h{1},'_mice_',condition{1},'(mouseInd)=MSE_norm_',h{1},'_mice_',condition{1},'(mouseInd)+temp;'))
                clear temp
            end
        end
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'MSE_norm_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'MSE_norm_',h{1},'_mice_',condition{1},'_allRegions',char(39),')'))
        end
    end
end


for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
           eval(strcat('MSE_norm_',h{1},'_',condition{1},'_map =  zeros(1,128*128);'))
           for region = [3,4,6:25,28,29,31:50] 
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat('MSE_norm_',h{1},'_',condition{1},'_map(mask_region(:))=mean(MSE_norm_',h{1},'_mice_',condition{1},'_allRegions(:,region));'))
           end
           eval(strcat('MSE_norm_',h{1},'_',condition{1},'_map = reshape(MSE_norm_',h{1},'_',condition{1},'_map,128,128);'))
           if exist(saveName,'file')
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'MSE_norm_',h{1},'_',condition{1},'_map',char(39),',',...
                   char(39),'-append',char(39),')'))
           else
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'MSE_norm_',h{1},'_',condition{1},'_map',char(39),')'))
           end
    end
end


%% Visualization
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\GoodWL.mat")
load("D:\XiaodanPaperData\cat\deconvolution_allRegions.mat")
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
        cmocean('ice')
        title('r')
        set(gca,'FontSize',14,'FontWeight','Bold')

        subplot(2,3,5)
        temp = strcat('imagesc(MSE_norm_',h{1},'_',condition{1},'_map,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
        cb=colorbar;
        clim([0 1.3])
 

        axis image off
        cmocean('ice')
        title('R^2')
        set(gca,'FontSize',14,'FontWeight','Bold')

        subplot(2,3,6)
        eval(strcat('plot_distribution_prctile(t,',h{1},'_mice_',condition{1},',',char(39),'Color',char(39),',[0 0 0])'))   
        title(h)
        xlabel('Time(s)')
        xlim([-3 10])
        set(gca,'FontSize',14,'FontWeight','Bold')
         if strcmp(h,'HRF')
            ylim([-0.0005 0.0035])
        else
            ylim([-0.0004 0.0013])
        end
        grid on

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
        if strcmp(h,'HRF')
            clim([0 0.005])
        else
            clim([0 0.002])
        end
        axis image off
        cmocean('ice')
        title('A')
        set(gca,'FontSize',14,'FontWeight','Bold')
        sgtitle(strcat('Deconvolution',{' '},h,' for RGECO mice under',{' '},condition,' condition'))
        saveName =  fullfile('D:\XiaodanPaperData\cat', strcat('Deconvoltuion_',h{1},'_',condition{1}));
        saveas(gcf,strcat(saveName,'_normError.fig'))
        saveas(gcf,strcat(saveName,'_normError.png'))
    end
end

clear ;close all;clc
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
freq_new     = 250;
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
% total number of pixels in all interested regions
pixelNum = zeros(1,50);
for region = 1:50
    mask_region = zeros(128,128);
    mask_region(mask == region) = 1;
    pixelNum(region) = sum(mask_region,'all');
end
pixelNumTotal = sum(pixelNum);
%% Initialize
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}   
        eval(strcat( h{1},'_mice_',condition{1},'_allRegions = nan(6,7500,50);'))
        eval(strcat('r_',h{1},'_mice_',condition{1},'_allRegions = nan(6,50);'))   
        eval(strcat( h{1},'_mice_',condition{1},' = zeros(6,7500);'))
        eval(strcat('r_',h{1},'_mice_',condition{1},' = zeros(6,1);'))  
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
             eval(strcat( h{1},'_mouse_',condition{1},'_allRegions = [];'))
             eval(strcat('r_',h{1},'_mouse_',condition{1},'_allRegions = [];'))
        end
        for n = 1:3
            disp(strcat(mouseName,', run #',num2str(n)))
            load(fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Upsample.mat')))
            load(fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Upsample.mat')))
            % cat r,MRF, HRF
            for h = {'HRF','MRF'}
                eval(strcat( h{1},'_mouse_',condition{1},'_allRegions = cat(1,',h{1},'_mouse_',condition{1},'_allRegions,',h{1},');'))
                eval(strcat( 'r_',h{1},'_mouse_',condition{1},'_allRegions = cat(1,r_',h{1},'_mouse_',condition{1},'_allRegions,r_',h{1},');'))
            end    
        end

        for h = {'HRF','MRF'}
            eval(strcat( h{1},'_mouse_',condition{1},'_allRegions = mean(',h{1},'_mouse_',condition{1},'_allRegions);'))
            eval(strcat( 'r_',h{1},'_mouse_',condition{1},'_allRegions = mean(r_',h{1},'_mouse_',condition{1},'_allRegions);'))
            saveName_mouse = fullfile(saveDir,strcat(h{1},'_Upsample'), strcat(recDate,'-',mouseName,'_',h{1},'_Upsample.mat'));
            if exist(saveName_mouse,'file')
                eval(strcat('save(',char(39),saveName_mouse,char(39),',',...
                    char(39),h{1},'_mouse_',condition{1},'_allRegions',char(39),',',...
                    char(39),'r_',h{1},'_mouse_',condition{1},'_allRegions',char(39),',',...
                    char(39),'-append',char(39),')'))
            else
                eval(strcat('save(',char(39),saveName_mouse,char(39),',',...
                    char(39),h{1},'_mouse_',condition{1},'_allRegions',char(39),',',...
                    char(39),'r_',h{1},'_mouse_',condition{1},'_allRegions',char(39),')'))
            end

            eval(strcat( h{1},'_mice_',condition{1},'_allRegions(mouseInd,:,:) =',h{1},'_mouse_',condition{1},'_allRegions;'))
            eval(strcat( 'r_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,:) = r_',h{1},'_mouse_',condition{1},'_allRegions;'))           
        end        
        mouseInd = mouseInd+1;
    end
    for h = {'HRF','MRF'}
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'r_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'r_',h{1},'_mice_',condition{1},'_allRegions',char(39),')'))
        end
    end
end
%% Plot HRF for each region and each mouse
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        figure
        for region = 1:50
            subplot(5,10,region)
            eval(strcat('plot(t,',h{1},'_mice_',condition{1},'_allRegions(:,:,region))'))
            title(parcelnames{region})
            xlabel('Time(s)')
            xlim([-3 5])
            %                 if strcmp(h,'HRF')
            %                     ylim([-0.0005 0.0035])
            %                 else
            %                     ylim([-0.0004 0.0013])
            %                 end
            grid on
        end
        sgtitle(strcat(h{1},{' '},condition{1}))
    end
end


%% find T, W, A for each mouse
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName)
for condition = {'awake','anes'}
    numMice = eval(strcat('length(excelRows_',condition{1},');'));
    for h = {'HRF','MRF'}  
        for var = {'T','W','A'}
            eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'_allRegions= nan(numMice,50);'))
        end
        for region = 
            [3:25,28:50]% region 1,2,5,25,26,30 have biggest peak before 0 s
            for mouseInd = 1:numMice
                eval(strcat(h{1},'_temp =',h{1},'_mice_',condition{1},'_allRegions(mouseInd,:,region);'))    
                
                if strcmp('HRF',h{1})  
                    eval(strcat('M = max(',h{1},'_temp(783:end));'))
                    [A,T,W] = findpeaks(HRF_temp,t,'MinPeakHeight',M*0.999999);
                else
                    eval(strcat('M = max(',h{1},'_temp(751:end));'))
                    [A,T,W] = findpeaks(MRF_temp,t,'MinPeakHeight',M*0.999999);
                end
                eval(strcat('A_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,region) = A(end);'))
                eval(strcat('T_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,region) = T(end);'))
                eval(strcat('W_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,region) = W(end);'))
            end
        end
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'W_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'A_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'W_',h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'A_',h{1},'_mice_',condition{1},'_allRegions',char(39),')'))
        end
    end
end
      
% T W A for averaged across mice Response function
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}  
        for var = {'T','W','A'}
            eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'= nan(1,50);'))
        end
        for region = 1:50 
            eval(strcat(h{1},'_temp = mean(',h{1},'_mice_',condition{1},'_allRegions(:,:,region));'))
            eval(strcat('M = max(',h{1},'_temp);'))

            if strcmp('HRF',h{1})
                [A,T,W] = findpeaks(HRF_temp,t,'MinPeakHeight',M*0.999999);
            else
                [A,T,W] = findpeaks(MRF_temp,t,'MinPeakHeight',M*0.999999);
            end

            eval(strcat('A_',h{1},'_mice_',condition{1},'(region) = A;'))
            eval(strcat('T_',h{1},'_mice_',condition{1},'(region) = T;'))
            eval(strcat('W_',h{1},'_mice_',condition{1},'(region) = W;'))
        end
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'W_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'A_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'W_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'A_',h{1},'_mice_',condition{1},char(39),')'))
        end
    end
end

%% Average across all regions 
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        for mouseInd = 1:6
            for region = 1:50
                eval(strcat('temp = squeeze(',h{1},'_mice_',condition{1},'_allRegions(mouseInd,:,region))*pixelNum(region)/pixelNumTotal;'))
                eval(strcat( h{1},'_mice_',condition{1},'(mouseInd,:)=',h{1},'_mice_',condition{1},'(mouseInd,:)+temp;'))
                clear temp
                eval(strcat('temp = squeeze(nanmean(r_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,region)))*pixelNum(region)/pixelNumTotal;'))
                eval(strcat( 'r_',h{1},'_mice_',condition{1},'(mouseInd)=r_',h{1},'_mice_',condition{1},'(mouseInd)+temp;'))
                clear temp
            end
        end
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),h{1},'_mice_',condition{1},char(39),',',...
                char(39),'r_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),h{1},'_mice_',condition{1},'_allRegions',char(39),',',...
                char(39),'r_',h{1},'_mice_',condition{1},'_allRegions',char(39),')'))
        end
    end
end

%% Calculate T, W, A, r for each region
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}  
        for var = {'T','W','A'}
            eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'= nan(1,50);'))
        end
        for region = 1:50 
            eval(strcat(h{1},'_temp = mean(',h{1},'_mice_',condition{1},'_allRegions(:,:,region));'))
            eval(strcat('M = max(',h{1},'_temp);'))

            if strcmp('HRF',h{1})
                [A,T,W] = findpeaks(HRF_temp,t,'MinPeakHeight',M*0.999999);
            else
                [A,T,W] = findpeaks(MRF_temp,t,'MinPeakHeight',M*0.999999);
            end

            eval(strcat('A_',h{1},'_mice_',condition{1},'(region) = A;'))
            eval(strcat('T_',h{1},'_mice_',condition{1},'(region) = T;'))
            eval(strcat('W_',h{1},'_mice_',condition{1},'(region) = W;'))
        end
        if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'W_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'A_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'W_',h{1},'_mice_',condition{1},char(39),',',...
                char(39),'A_',h{1},'_mice_',condition{1},char(39),')'))
        end
    end
end
           
%% Maps with regional values
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
       for var = {'T','W','A'}
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map =  zeros(1,128*128);'))
           for region = 1:50  
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat(var{1},'_',h{1},'_',condition{1},'_map(mask_region(:))=',var{1},'_',h{1},'_mice_',condition{1},'(region);'))
           end
           eval(strcat(var{1},'_',h{1},'_',condition{1},'_map = reshape(',var{1},'_',h{1},'_',condition{1},'_map,128,128);'))           
       end
       if exist(saveName,'file')
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_',condition{1},'_map',char(39),',',...
                char(39),'W_',h{1},'_',condition{1},'_map',char(39),',',...
                char(39),'A_',h{1},'_',condition{1},'_map',char(39),',',...
                char(39),'-append',char(39),')'))
        else
            eval(strcat('save(',char(39),saveName,char(39),',',...
                char(39),'T_',h{1},'_',condition{1},'_map',char(39),',',...
                char(39),'W_',h{1},'_',condition{1},'_map',char(39),',',...
                char(39),'A_',h{1},'_',condition{1},'_map',char(39),')'))
        end
    end
end

for condition = {'awake','anes'}
    for h = {'HRF','MRF'}        
           eval(strcat('r_',h{1},'_',condition{1},'_map =  zeros(1,128*128);'))
           for region = 1:50  
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                eval(strcat('r_',h{1},'_',condition{1},'_map(mask_region(:))=mean(r_',h{1},'_mice_',condition{1},'_allRegions(:,region));'))
           end
           eval(strcat('r_',h{1},'_',condition{1},'_map = reshape(r_',h{1},'_',condition{1},'_map,128,128);'))
           if exist(saveName,'file')
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'r_',h{1},'_',condition{1},'_map',char(39),',',...
                   char(39),'-append',char(39),')'))
           else
               eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),'r_',h{1},'_',condition{1},'_map',char(39),')'))
           end
    end
end


%% Visualization
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\GoodWL.mat")
for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        figure('units','normalized','outerposition',[0 0 1 1])
        subplot(2,3,4)
        temp = strcat('imagesc(r_',h{1},'_',condition{1},'_map,',char(39),'AlphaData',char(39),',mask)');
        eval(temp)
        hold on;
        imagesc(xform_WL,'AlphaData',1-mask);
        cb=colorbar;
        clim([0 1])
        axis image off
        colormap(brewermap(256, '-Spectral'));
        title('r')
        set(gca,'FontSize',14,'FontWeight','Bold')

        subplot(2,3,5)
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
        saveas(gcf,strcat(saveName,'.fig'))
        saveas(gcf,strcat(saveName,'.png'))
    end
end

% Awake vs Anes
load('deconvolution_allRegions.mat', 'HRF_mice_awake', 'MRF_mice_awake', 'HRF_mice_anes', 'MRF_mice_anes')
freq_new = 250;
t_kernel = 30;
t = (-3*freq_new :(t_kernel-3)*freq_new-1)/freq_new;
figure
yyaxis left
plot_distribution_prctile(t,MRF_mice_awake,'Color',[0.2,0.2,0.2])
ylim([-0.0004, 0.0012])
hold on
yyaxis right
plot_distribution_prctile(t,HRF_mice_awake,'Color',[0.5,0,0.5])
% ax = gca;
% ax.YAxis(1).Color = [0.2,0.2,0.2];
% ax.YAxis(2).Color = [0.5,0,0.5];
xlim([0, 4])
ylim([-0.0012, 0.0036])
xlabel('Time(s)')

figure
yyaxis left
plot_distribution_prctile(t,MRF_mice_anes,'Color',[0.2,0.2,0.2])
ylim([-0.0004, 0.0012])
hold on
yyaxis right
plot_distribution_prctile(t,HRF_mice_anes,'Color',[0.5,0,0.5])
% ax = gca;
% ax.YAxis(1).Color = [0.2,0.2,0.2];
% ax.YAxis(2).Color = [0.5,0,0.5];
xlim([0, 4])
ylim([-0.0012, 0.0036])
xlabel('Time(s)')

%% Generate value for paper table

% find mean and std for r
mean_r_HRF_mice_awake = mean(r_HRF_mice_awake);
std_r_HRF_mice_awake = std(r_HRF_mice_awake);

mean_r_MRF_mice_awake = mean(r_MRF_mice_awake);
std_r_MRF_mice_awake = std(r_MRF_mice_awake);

mean_r_HRF_mice_anes = mean(r_HRF_mice_anes);
std_r_HRF_mice_anes = std(r_HRF_mice_anes);

mean_r_MRF_mice_anes = mean(r_MRF_mice_anes);
std_r_MRF_mice_anes = std(r_MRF_mice_anes);

% Test if there is significant difference between awake and anesthetized
% condigtion for r
[~,p_r_HRF_mice] = ttest(r_HRF_mice_awake,r_HRF_mice_anes,'Tail','both');
[~,p_r_MRF_mice] = ttest(r_MRF_mice_awake,r_MRF_mice_anes,'Tail','both');

% Initialize
T_HRF_mice_awake = zeros(6,1);
W_HRF_mice_awake = zeros(6,1);
A_HRF_mice_awake = zeros(6,1);

T_HRF_mice_anes = zeros(6,1);
W_HRF_mice_anes = zeros(6,1);
A_HRF_mice_anes = zeros(6,1);

T_MRF_mice_awake = zeros(6,1);
W_MRF_mice_awake = zeros(6,1);
A_MRF_mice_awake = zeros(6,1);

T_MRF_mice_anes = zeros(6,1);
W_MRF_mice_anes = zeros(6,1);
A_MRF_mice_anes = zeros(6,1);

% Calculate T, W, A
for mouseInd = 1:6
    M_HRF_mice_awake = max(HRF_mice_awake(mouseInd,:));
    [A_HRF_mice_awake(mouseInd),T_HRF_mice_awake(mouseInd),W_HRF_mice_awake(mouseInd)] = findpeaks(HRF_mice_awake(mouseInd,:),t,'MinPeakHeight',M_HRF_mice_awake*0.999999);
    
    M_HRF_mice_anes = max(HRF_mice_anes(mouseInd,:));
    [A_HRF_mice_anes(mouseInd),T_HRF_mice_anes(mouseInd),W_HRF_mice_anes(mouseInd)] = findpeaks(HRF_mice_anes(mouseInd,:),t,'MinPeakHeight',M_HRF_mice_anes*0.999999);

    M_MRF_mice_awake = max(MRF_mice_awake(mouseInd,:));
    [A_MRF_mice_awake(mouseInd),T_MRF_mice_awake(mouseInd),W_MRF_mice_awake(mouseInd)] = findpeaks(MRF_mice_awake(mouseInd,:),t,'MinPeakHeight',M_MRF_mice_awake*0.999999);
    
    M_MRF_mice_anes = max(MRF_mice_anes(mouseInd,:));
    [A_MRF_mice_anes(mouseInd),T_MRF_mice_anes(mouseInd),W_MRF_mice_anes(mouseInd)] = findpeaks(MRF_mice_anes(mouseInd,:),t,'MinPeakHeight',M_MRF_mice_anes*0.999999);
end

% mean and std for T
mean_T_HRF_mice_awake = mean(T_HRF_mice_awake);
std_T_HRF_mice_awake = std(T_HRF_mice_awake);

mean_T_MRF_mice_awake = mean(T_MRF_mice_awake);
std_T_MRF_mice_awake = std(T_MRF_mice_awake);

mean_T_HRF_mice_anes = mean(T_HRF_mice_anes);
std_T_HRF_mice_anes = std(T_HRF_mice_anes);

mean_T_MRF_mice_anes = mean(T_MRF_mice_anes);
std_T_MRF_mice_anes = std(T_MRF_mice_anes);

[~,p_T_HRF_mice] = ttest(T_HRF_mice_awake,T_HRF_mice_anes,'Tail','both');
[~,p_T_MRF_mice] = ttest(T_MRF_mice_awake,T_MRF_mice_anes,'Tail','both');

% mean and std for W
mean_W_HRF_mice_awake = mean(W_HRF_mice_awake);
std_W_HRF_mice_awake = std(W_HRF_mice_awake);

mean_W_MRF_mice_awake = mean(W_MRF_mice_awake);
std_W_MRF_mice_awake = std(W_MRF_mice_awake);

mean_W_HRF_mice_anes = mean(W_HRF_mice_anes);
std_W_HRF_mice_anes = std(W_HRF_mice_anes);

mean_W_MRF_mice_anes = mean(W_MRF_mice_anes);
std_W_MRF_mice_anes = std(W_MRF_mice_anes);

[~,p_W_HRF_mice] = ttest(W_HRF_mice_awake,W_HRF_mice_anes,'Tail','both');
[~,p_W_MRF_mice] = ttest(W_MRF_mice_awake,W_MRF_mice_anes,'Tail','both');

% mean and std for A
mean_A_HRF_mice_awake = mean(A_HRF_mice_awake);
std_A_HRF_mice_awake = std(A_HRF_mice_awake);

mean_A_MRF_mice_awake = mean(A_MRF_mice_awake);
std_A_MRF_mice_awake = std(A_MRF_mice_awake);

mean_A_HRF_mice_anes = mean(A_HRF_mice_anes);
std_A_HRF_mice_anes = std(A_HRF_mice_anes);

mean_A_MRF_mice_anes = mean(A_MRF_mice_anes);
std_A_MRF_mice_anes = std(A_MRF_mice_anes);

[~,p_A_HRF_mice] = ttest(A_HRF_mice_awake,A_HRF_mice_anes,'Tail','both');
[~,p_A_MRF_mice] = ttest(A_MRF_mice_awake,A_MRF_mice_anes,'Tail','both');

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

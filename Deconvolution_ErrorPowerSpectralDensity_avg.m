
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
    for h = {'FAD','HbT'}
        eval(strcat('fft_error_', h{1},'_mice_',condition{1},'_allRegions = nan(6,1025,50);'))
        eval(strcat('fft_error_', h{1},'_mice_',condition{1},' = zeros(6,1025);'))
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
        for h = {'FAD','HbT'}
            eval(strcat('fft_error_',h{1},'_mouse_',condition{1},'_allRegions = [];'))
        end
        for n = 1:3
            disp(strcat(mouseName,', run #',num2str(n)))
            load(fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Upsample.mat')))
            load(fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Upsample.mat')))
            % cat r,MRF, HRF
            for h = {'FAD','HbT'}
                eval(strcat('fft_error_', h{1},'_mouse_',condition{1},'_allRegions = cat(1,fft_error_',h{1},'_mouse_',condition{1},'_allRegions,fft_error_',h{1},');'))
            end
        end

        eval(strcat( 'fft_error_FAD_mouse_',condition{1},'_allRegions = mean(fft_error_FAD_mouse_',condition{1},'_allRegions);'))
        eval(strcat( 'fft_error_HbT_mouse_',condition{1},'_allRegions = mean(fft_error_HbT_mouse_',condition{1},'_allRegions);'))
        saveName_mouse_MRF = fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'_MRF_Upsample.mat'));
        saveName_mouse_HRF = fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'_HRF_Upsample.mat'));

        eval(strcat('save(',char(39),saveName_mouse_MRF,char(39),',',...
            char(39),'fft_error_FAD_mouse_',condition{1},'_allRegions',char(39),',',...
            char(39),'-append',char(39),')'))
        eval(strcat('save(',char(39),saveName_mouse_HRF,char(39),',',...
            char(39),'fft_error_HbT_mouse_',condition{1},'_allRegions',char(39),',',...
            char(39),'-append',char(39),')'))

        for h = {'FAD','HbT'}
            eval(strcat('fft_error_', h{1},'_mice_',condition{1},'_allRegions(mouseInd,:,:) = fft_error_',h{1},'_mouse_',condition{1},'_allRegions;'))
        end
        mouseInd = mouseInd+1;
    end
    
    eval(strcat('save(',char(39),saveName,char(39),',',...
        char(39),'fft_error_FAD_mice_',condition{1},'_allRegions',char(39),',',...
        char(39),'fft_error_HbT_mice_',condition{1},'_allRegions',char(39),',',...
        char(39),'-append',char(39),')'))

end
%% Plot HRF for each region and each mouse
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName,'hz')
for condition = {'awake','anes'}
    for h = {'FAD','HbT'}
        figure
        for region = 1:50
            subplot(5,10,region)
            eval(strcat('loglog(hz,fft_error_',h{1},'_mice_',condition{1},'_allRegions(:,:,region))'))
            title(parcelnames{region})
            xlabel('Time(s)')
            xlim([-3 5])
            grid on
        end
        sgtitle(strcat(h{1},{' '},condition{1}))
    end
end


%% Average across all regions
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
for condition = {'awake','anes'}
    for h = {'FAD','HbT'}
        for mouseInd = 1:6
            for region = 1:50
                eval(strcat('temp = squeeze(fft_error_',h{1},'_mice_',condition{1},'_allRegions(mouseInd,:,region))*pixelNum(region)/pixelNumTotal;'))
                eval(strcat('fft_error_', h{1},'_mice_',condition{1},'(mouseInd,:)=fft_error_',h{1},'_mice_',condition{1},'(mouseInd,:)+temp;'))
                clear temp
            end
        end
    end

    eval(strcat('save(',char(39),saveName,char(39),',',...
        char(39),'fft_error_FAD_mice_',condition{1},char(39),',',...
        char(39),'fft_error_HbT_mice_',condition{1},char(39),',',...
        char(39),'-append',char(39),')'))
    
end


%% Visualization linear linear
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName)
figure
subplot(2,2,1)
plot_distribution_prctile(hz,fft_error_FAD_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Awake FAF ')
ylabel('FAF((\DeltaF/F)^2/Hz)')
xlim([0.2 2])

subplot(2,2,2)
plot_distribution_prctile(hz,fft_error_HbT_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Awake HbT ')
ylabel('HbT((\DeltamuM)^2/Hz)')
xlim([0.2 2])

subplot(2,2,3)
plot_distribution_prctile(hz,fft_error_FAD_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Anesthetized FAF ')
ylabel('FAF((\DeltaF/F)^2/Hz)')
xlim([0.2 2])

subplot(2,2,4)
plot_distribution_prctile(hz,fft_error_HbT_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Anesthetized HbT ')
ylabel('HbT((\DeltamuM)^2/Hz)')
xlim([0.2 2])

%% Visualization semilog-y
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName)
figure
subplot(2,2,1)
plot_distribution_prctile(hz,fft_error_FAD_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Awake FAF ')
ylabel('FAF((\DeltaF/F)^2/Hz)')
xlim([0.2 2])
ylim([0.0001 1])
set(gca, 'YScale', 'log')

subplot(2,2,2)
plot_distribution_prctile(hz,fft_error_HbT_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Awake HbT ')
ylabel('HbT((\DeltamuM)^2/Hz)')
xlim([0.2 2])
ylim([0.001 10])
set(gca, 'YScale', 'log')

subplot(2,2,3)
plot_distribution_prctile(hz,fft_error_FAD_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Anesthetized FAF ')
ylabel('FAF((\DeltaF/F)^2/Hz)')
xlim([0.2 2])
ylim([0.0001 1])
set(gca, 'YScale', 'log')

subplot(2,2,4)
plot_distribution_prctile(hz,fft_error_HbT_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
title('Anesthetized HbT ')
ylabel('HbT((\DeltamuM)^2/Hz)')
xlim([0.2 2])
ylim([0.001 10])
set(gca, 'YScale', 'log')
%% Visualization loglog
saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName)
figure
subplot(2,2,1)
plot_distribution_prctile(hz,fft_error_FAD_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Awake FAF ')

subplot(2,2,2)
plot_distribution_prctile(hz,fft_error_FAD_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Anesthetized FAF ')

subplot(2,2,3)
plot_distribution_prctile(hz,fft_error_HbT_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Awake HbT ')

subplot(2,2,4)
plot_distribution_prctile(hz,fft_error_HbT_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Anesthetized HbT ')

figure
subplot(2,2,1)
plot_distribution_prctile(hz,fft_error_FAD_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Awake FAF ')
xlim([0.1 2])
subplot(2,2,2)
plot_distribution_prctile(hz,fft_error_FAD_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Anesthetized FAF ')
xlim([0.1 2])
subplot(2,2,3)
plot_distribution_prctile(hz,fft_error_HbT_mice_awake,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Awake HbT ')
xlim([0.1 2])
subplot(2,2,4)
plot_distribution_prctile(hz,fft_error_HbT_mice_anes,'Color',[0 0 0])
xlabel('Frequency(Hz)')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Anesthetized HbT ')
xlim([0.1 2])

%% Visualization 
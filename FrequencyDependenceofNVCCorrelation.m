
import mouse.*

excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";

load('D:\OIS_Process\noVasculatureMask.mat')
%
% %
% excelRows = [181,183,185,228,232,236,195,202,204,230,234,240];%321:327;
% runs = 1:3;
% edgeLen =1;
% tZone = 4;
% corrThr = 0;
% % frequency = 0.035:0.035:(5-0.35);
% % window = 0.35;
frequency = 0.01:0.03:(5-0.3);
% window = 0.3;
% newfs = 10;
% for excelRow = excelRows
%     [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
%     recDate = excelRaw{1}; recDate = string(recDate);
%     mouseName = excelRaw{2}; mouseName = string(mouseName);
%     saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
%     sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
%     fs = excelRaw{7};
%     validRange = - edgeLen: round(tZone*newfs); %4*frequency(end)
%     %maskName = strcat(recDate,'-',mouseName,'-',sessionType,'1-datahb','.mat');
%     %load(fullfile(maskDir,maskName), 'xform_isbrain')
%     %save(fullfile(maskDir_new,maskName_new),'xform_isbrain')
%     maskDir = strcat('L:\RGECO\Kenny\', recDate, '\');
%     if exist(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'file')
%         load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'xform_isbrain');
%         load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-','LandmarksAndMask.mat')),'affineMarkers')
%     else
%         maskDir = saveDir;
%         maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
%         load(fullfile(maskDir,maskName),'affineMarkers','xform_isbrain','isbrain')
%     end
%     mask = mask_new.*xform_isbrain;
%     
%     for n = runs
%         disp(strcat('Lag analysis on ', recDate, ' ', mouseName, ' run#', num2str(n)))        
%         visName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n));
%         processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
%         saveFreqCorr = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_freqLag','.mat');
%         disp('loading processed data')
%         load(fullfile(saveDir,processedName),'xform_datahb','xform_FADCorr','xform_jrgeco1aCorr')
%         xform_jrgeco1aCorr = squeeze(xform_jrgeco1aCorr);
%         xform_total = squeeze(xform_datahb(:,:,1,:)+ xform_datahb(:,:,2,:));
%         clear xform_datahb
%         xform_total(isinf(xform_total)) = 0;
%         xform_total(isnan(xform_total)) = 0;
%         xform_FADCorr(isnan(xform_FADCorr)) = 0;
%         xform_FADCorr(isinf(xform_FADCorr)) = 0;
%         xform_jrgeco1aCorr(isinf(xform_jrgeco1aCorr)) = 0;
%         xform_jrgeco1aCorr(isnan(xform_jrgeco1aCorr)) = 0;
%         xform_total_downsample=resampledata_ori(xform_total,fs,newfs,10^(-5));
%         clear xform_total
%         xform_FADCorr_downsample=resampledata_ori(xform_FADCorr,fs,newfs,10^(-5));
%         clear xform_FADCorr
%         xform_jrgeco1aCorr_downsample=resampledata_ori(xform_jrgeco1aCorr,fs,newfs,10^(-5));
%         clear xform_jrgeco1aCorr
%         
%         lagTimeTrial_HbTCalcium_vector = nan(1,length(frequency));
%         lagAmpTrial_HbTCalcium_vector = nan(1,length(frequency));
%         lagTimeTrial_FADCalcium_vector = nan(1,length(frequency));
%         lagAmpTrial_FADCalcium_vector = nan(1,length(frequency));
%         %%comparing our NVC measures to Hillman (0.02-2)
%         
%         ii = 1;
%         for startFreq = frequency   
%             tic
%             disp(['filter starting at' num2str(startFreq)])
%             xform_total_filtered = mouse.freq.filterData(double(xform_total_downsample),startFreq,startFreq+window,newfs);
%             xform_FADCorr_filtered = mouse.freq.filterData(double(xform_FADCorr_downsample),startFreq,startFreq+window,newfs);
%             xform_jrgeco1aCorr_filtered = mouse.freq.filterData(double(xform_jrgeco1aCorr_downsample),startFreq,startFreq+window,newfs);
%             
%             [lagTimeTrial_HbTCalcium,lagAmpTrial_HbTCalcium] = dotLag_mask(xform_total_filtered,...
%                 xform_jrgeco1aCorr_filtered,edgeLen,validRange,mask,corrThr, true,true);
%             lagTimeTrial_HbTCalcium = lagTimeTrial_HbTCalcium/newfs;
%             
%             [lagTimeTrial_FADCalcium,lagAmpTrial_FADCalcium] = dotLag_mask(xform_FADCorr_filtered,...
%                 xform_jrgeco1aCorr_filtered,edgeLen,validRange,mask,corrThr, true,true);
%             lagTimeTrial_FADCalcium = lagTimeTrial_FADCalcium/newfs;
%             
%             clear xform_total_filtered xform_FADCorr_filtered xform_jrgeco1aCorr_filtered
%             
%             lagTimeTrial_HbTCalcium_vector(ii) = nanmean(lagTimeTrial_HbTCalcium,'all');
%             lagAmpTrial_HbTCalcium_vector(ii) = nanmean(lagAmpTrial_HbTCalcium,'all');
%             
%             
%             lagTimeTrial_FADCalcium_vector(ii) = nanmean(lagTimeTrial_FADCalcium,'all');
%             lagAmpTrial_FADCalcium_vector(ii) = nanmean(lagAmpTrial_FADCalcium,'all');
%             
%             ii = ii+1;
%             
%             clear lagTimeTrial_HbTCalcium lagAmpTrial_HbTCalcium lagTimeTrial_FADCalcium lagAmpTrial_FADCalcium
%             toc
%         end
%         
%         figure('units','normalized','outerposition',[0 0 0.5 0.5])
%         subplot(1,2,1)
%         semilogx(frequency,lagAmpTrial_HbTCalcium_vector,'k')
%         xlabel('Frequency(Hz)')
%         ylabel('Correlation')
%         grid on
%         hold on
%         semilogx(frequency,lagAmpTrial_FADCalcium_vector,'g')
%         legend('Calcium HbT','Calcium FAD')
%         xlim([0 5])
%         subplot(1,2,2)
%         semilogx(frequency,lagTimeTrial_HbTCalcium_vector,'k')
%         xlabel('Frequency(Hz)')
%         ylabel('Lag Time(s)')
%         grid on
%         hold on
%         semilogx(frequency,lagTimeTrial_FADCalcium_vector,'g')
%         legend('Calcium HbT','Calcium FAD','location','northwest')
%         xlim([0 5])
%         
%   
%         
%         suptitle(strcat(recDate,'-',mouseName,'-',sessionType,num2str(n)))
%         saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_freqLag.png')));
%         saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_freqLag.fig')));
%         
%         if exist(fullfile(saveDir,saveFreqCorr),'file')
%             save(fullfile(saveDir,saveFreqCorr),'lagTimeTrial_HbTCalcium_vector',...
%                 'lagAmpTrial_HbTCalcium_vector', 'lagTimeTrial_FADCalcium_vector',...
%                 'lagAmpTrial_FADCalcium_vector','frequency','-append')
%         else
%             save(fullfile(saveDir,saveFreqCorr),'lagTimeTrial_HbTCalcium_vector',...
%                 'lagAmpTrial_HbTCalcium_vector', 'lagTimeTrial_FADCalcium_vector',...
%                 'lagAmpTrial_FADCalcium_vector','frequency','-v7.3')
%         end
%         clear lagTimeTrial_HbTCalcium_vector lagApmTrial_HbTCalcium_vector...
%             lagTimeTrial_FADCalcium_vector lagAmpTrial_FADCalcium_vector
%         close all
%     end
% end



excelRows = 240;%[181,183,185,228,232,236,195,202,204,230,234];%,
runs = 1:3;

for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    lagTimeTrial_HbTCalcium_vector_mouse = nan(length(runs),length(frequency));
    lagAmpTrial_HbTCalcium_vector_mouse = nan(length(runs),length(frequency));
    lagTimeTrial_FADCalcium_vector_mouse = nan(length(runs),length(frequency));
    lagAmpTrial_FADCalcium_vector_mouse = nan(length(runs),length(frequency));
    disp(strcat('Average on ', recDate, ' ', mouseName))
    for n = runs
        saveFreqCorr = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_freqLag','.mat');
        load(fullfile(saveDir,saveFreqCorr))
        lagTimeTrial_HbTCalcium_vector_mouse(n,:) = lagTimeTrial_HbTCalcium_vector;
        lagAmpTrial_HbTCalcium_vector_mouse(n,:) = lagAmpTrial_HbTCalcium_vector;
        lagTimeTrial_FADCalcium_vector_mouse(n,:) = lagTimeTrial_FADCalcium_vector;
        lagAmpTrial_FADCalcium_vector_mouse(n,:) = lagAmpTrial_FADCalcium_vector;
    end
    lagTimeTrial_HbTCalcium_vector_mouse = mean(lagTimeTrial_HbTCalcium_vector_mouse,1);
    lagAmpTrial_HbTCalcium_vector_mouse = mean(lagAmpTrial_HbTCalcium_vector_mouse,1);
    lagTimeTrial_FADCalcium_vector_mouse = mean(lagTimeTrial_FADCalcium_vector_mouse,1);
    lagAmpTrial_FADCalcium_vector_mouse = mean(lagAmpTrial_FADCalcium_vector_mouse,1);
    
    figure('units','normalized','outerposition',[0 0 0.5 0.5])
    subplot(1,2,1)
    semilogx(frequency,lagAmpTrial_HbTCalcium_vector_mouse,'k')
    xlabel('Frequency(Hz)')
    ylabel('Correlation')
    hold on
    plot(frequency,lagAmpTrial_FADCalcium_vector_mouse,'g')
    legend('Calcium HbT','Calcium FAD','location','southwest')
    grid on
    subplot(1,2,2)
    semilogx(frequency,lagTimeTrial_HbTCalcium_vector_mouse,'k')
    xlabel('Frequency(Hz)')
    ylabel('Lag Time(s)')
    hold on
    plot(frequency,lagTimeTrial_FADCalcium_vector_mouse,'g')
    legend('Calcium HbT','Calcium FAD','location','southwest')
    grid on
    suptitle(strcat(recDate,'-',mouseName,'-',sessionType))
    saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,'_freqLag.png')));
    saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,'_freqLag.fig')));
    saveFreqCorr_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_freqLag','.mat');
    if exist(fullfile(saveDir,saveFreqCorr_mouse),'file')
        save(fullfile(saveDir,saveFreqCorr_mouse),'lagTimeTrial_HbTCalcium_vector_mouse',...
            'lagAmpTrial_HbTCalcium_vector_mouse', 'lagTimeTrial_FADCalcium_vector_mouse',...
            'lagAmpTrial_FADCalcium_vector_mouse','frequency','-append')
    else
        save(fullfile(saveDir,saveFreqCorr_mouse),'lagTimeTrial_HbTCalcium_vector_mouse',...
            'lagAmpTrial_HbTCalcium_vector_mouse', 'lagTimeTrial_FADCalcium_vector_mouse',...
            'lagAmpTrial_FADCalcium_vector_mouse','frequency','-v7.3')
    end
    close all
end


% 
% 
% excelRows = [181,183,185,228,232,236];
% lagTimeTrial_HbTCalcium_vector_mice = nan(length(excelRows),length(frequency));
% lagAmpTrial_HbTCalcium_vector_mice = nan(length(excelRows),length(frequency));
% lagTimeTrial_FADCalcium_vector_mice = nan(length(excelRows),length(frequency));
% lagAmpTrial_FADCalcium_vector_mice = nan(length(excelRows),length(frequency));
% saveDir_cat = 'L:\RGECO\cat';
% jj = 1;
% miceName = [];
% for excelRow = excelRows
%     [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
%     recDate = excelRaw{1}; recDate = string(recDate);
%     mouseName = excelRaw{2}; mouseName = string(mouseName);
%     miceName = strcat(miceName,'-',mouseName);
%     saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
%     sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
%     saveFreqCorr_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_freqLag','.mat');
%     load(fullfile(saveDir,saveFreqCorr_mouse))
%     
%     lagTimeTrial_HbTCalcium_vector_mice(jj,:) = lagTimeTrial_HbTCalcium_vector_mouse;
%     lagAmpTrial_HbTCalcium_vector_mice(jj,:) = lagAmpTrial_HbTCalcium_vector_mouse;
%    
%     lagTimeTrial_FADCalcium_vector_mice(jj,:) = lagTimeTrial_FADCalcium_vector_mouse;
%     lagAmpTrial_FADCalcium_vector_mice(jj,:) = lagAmpTrial_FADCalcium_vector_mouse;
%     jj = jj+1;   
% end
% 
% lagTimeTrial_HbTCalcium_vector_mice_avg = mean(lagTimeTrial_HbTCalcium_vector_mice,1);
% lagAmpTrial_HbTCalcium_vector_mice_avg = mean(lagAmpTrial_HbTCalcium_vector_mice,1);
% 
% lagTimeTrial_FADCalcium_vector_mice_avg = mean(lagTimeTrial_FADCalcium_vector_mice,1);
% lagAmpTrial_FADCalcium_vector_mice_avg = mean(lagAmpTrial_FADCalcium_vector_mice,1);
% 
% 
% figure('units','normalized','outerposition',[0 0 0.5 0.5])
% subplot(1,2,1)
% semilogx(frequency,lagAmpTrial_HbTCalcium_vector_mice_avg,'k')
% xlabel('Frequency(Hz)')
% ylabel('Correlation')
% hold on
% plot(frequency,lagAmpTrial_FADCalcium_vector_mice_avg,'g')
% legend('Calcium HbT','Calcium FAD','location','southwest')
% grid on
% subplot(1,2,2)
% semilogx(frequency,lagTimeTrial_HbTCalcium_vector_mice_avg,'k')
% xlabel('Frequency(Hz)')
% ylabel('Lag Time(s)')
% hold on
% plot(frequency,lagTimeTrial_FADCalcium_vector_mice_avg,'g')
% legend('Calcium HbT','Calcium FAD','location','southwest')
% grid on
% suptitle('Awake')
% saveas(gcf,fullfile(saveDir_cat,strcat(recDate,'-',miceName,'-',sessionType,'_freqLag.png')));
% saveas(gcf,fullfile(saveDir_cat,strcat(recDate,'-',miceName,'-',sessionType,'_freqLag.fig')));
% saveFreqCorr_mice = strcat(recDate,'-',miceName,'-',sessionType,'_freqLag','.mat');
% if exist(fullfile(saveDir_cat,saveFreqCorr_mice),'file')
%     save(fullfile(saveDir_cat,saveFreqCorr_mice),'lagTimeTrial_HbTCalcium_vector_mice',...
%         'lagAmpTrial_HbTCalcium_vector_mice', 'lagTimeTrial_FADCalcium_vector_mice',...
%         'lagAmpTrial_FADCalcium_vector_mice','frequency','-append')
% else
%     save(fullfile(saveDir_cat,saveFreqCorr_mice),'lagTimeTrial_HbTCalcium_vector_mice',...
%         'lagAmpTrial_HbTCalcium_vector_mice', 'lagTimeTrial_FADCalcium_vector_mice',...
%         'lagAmpTrial_FADCalcium_vector_mice','frequency','-v7.3')
% end
% save(fullfile(saveDir_cat,saveFreqCorr_mice),'lagTimeTrial_HbTCalcium_vector_mice_avg',...
%     'lagAmpTrial_HbTCalcium_vector_mice_avg', 'lagTimeTrial_FADCalcium_vector_mice_avg',...
%     'lagAmpTrial_FADCalcium_vector_mice_avg','-append')





% figure('units','normalized','outerposition',[0 0 0.5 0.5])
% options.handle = figure(1);
% options.color_area = [0 0 0];
% options.color_line = [0 0 0];
% options.alpha = 0.5;
% options.line_width = 2;
% options.x_axis = frequency;
% options.error = 'c95';
% 
% subplot(1,2,1)
% h = zeros(1,2);
% options.color_area = [0 0 0];
% options.color_line = [0 0 0];
% plot_areaerrorbar(lagAmpTrial_HbTCalcium_vector_mice,options)
% options.color_area = [0 1 0];
% options.color_line = [0 1 0];
% hold on
% plot_areaerrorbar(lagAmpTrial_FADCalcium_vector_mice,options)
% xlabel('Frequency(Hz)')
% ylabel('Lag Amplitude')
% legend('Calcium HbT','Calcium FAD')
% subplot(1,2,2)
% options.color_area = [0 0 0];
% options.color_line = [0 0 0];
% plot_areaerrorbar(lagTimeTrial_HbTCalcium_vector_mice,options)
% options.color_area = [0 1 0];
% options.color_line = [0 1 0];
% hold on
% plot_areaerrorbar(lagTimeTrial_FADCalcium_vector_mice,options)
% xlabel('Frequency(Hz)')
% ylabel('Lag Time(s)')
% legend('Calcium HbT','Calcium FAD')
% 
% suptitle('Awake')





excelRows = [195 202 204 230 234 240];
lagTimeTrial_HbTCalcium_vector_mice = nan(length(excelRows),length(frequency));
lagAmpTrial_HbTCalcium_vector_mice = nan(length(excelRows),length(frequency));
lagTimeTrial_FADCalcium_vector_mice = nan(length(excelRows),length(frequency));
lagAmpTrial_FADCalcium_vector_mice = nan(length(excelRows),length(frequency));
saveDir_cat = 'L:\RGECO\cat';
jj = 1;
miceName = [];
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    miceName = strcat(miceName,'-',mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    saveFreqCorr_mouse = strcat(recDate,'-',mouseName,'-',sessionType,'_freqLag','.mat');
    load(fullfile(saveDir,saveFreqCorr_mouse))
    
    lagTimeTrial_HbTCalcium_vector_mice(jj,:) = lagTimeTrial_HbTCalcium_vector_mouse;
    lagAmpTrial_HbTCalcium_vector_mice(jj,:) = lagAmpTrial_HbTCalcium_vector_mouse;
   
    lagTimeTrial_FADCalcium_vector_mice(jj,:) = lagTimeTrial_FADCalcium_vector_mouse;
    lagAmpTrial_FADCalcium_vector_mice(jj,:) = lagAmpTrial_FADCalcium_vector_mouse;
    jj = jj+1;   
end

lagTimeTrial_HbTCalcium_vector_mice_avg = mean(lagTimeTrial_HbTCalcium_vector_mice,1);
lagAmpTrial_HbTCalcium_vector_mice_avg = mean(lagAmpTrial_HbTCalcium_vector_mice,1);

lagTimeTrial_FADCalcium_vector_mice_avg = mean(lagTimeTrial_FADCalcium_vector_mice,1);
lagAmpTrial_FADCalcium_vector_mice_avg = mean(lagAmpTrial_FADCalcium_vector_mice,1);


figure('units','normalized','outerposition',[0 0 0.5 0.5])
subplot(1,2,1)
semilogx(frequency,lagAmpTrial_HbTCalcium_vector_mice_avg,'k')
xlabel('Frequency(Hz)')
ylabel('Correlation')
hold on
plot(frequency,lagAmpTrial_FADCalcium_vector_mice_avg,'g')
legend('Calcium HbT','Calcium FAD','location','southwest')
grid on
subplot(1,2,2)
semilogx(frequency,lagTimeTrial_HbTCalcium_vector_mice_avg,'k')
xlabel('Frequency(Hz)')
ylabel('Lag Time(s)')
hold on
plot(frequency,lagTimeTrial_FADCalcium_vector_mice_avg,'g')
legend('Calcium HbT','Calcium FAD','location','southwest')
grid on
suptitle('Anesthetized')
saveas(gcf,fullfile(saveDir_cat,strcat(recDate,'-',miceName,'-',sessionType,'_freqLag.png')));
saveas(gcf,fullfile(saveDir_cat,strcat(recDate,'-',miceName,'-',sessionType,'_freqLag.fig')));
saveFreqCorr_mice = strcat(recDate,'-',miceName,'-',sessionType,'_freqLag','.mat');
if exist(fullfile(saveDir_cat,saveFreqCorr_mice),'file')
    save(fullfile(saveDir_cat,saveFreqCorr_mice),'lagTimeTrial_HbTCalcium_vector_mice',...
        'lagAmpTrial_HbTCalcium_vector_mice', 'lagTimeTrial_FADCalcium_vector_mice',...
        'lagAmpTrial_FADCalcium_vector_mice','frequency','-append')
else
    save(fullfile(saveDir_cat,saveFreqCorr_mice),'lagTimeTrial_HbTCalcium_vector_mice',...
        'lagAmpTrial_HbTCalcium_vector_mice', 'lagTimeTrial_FADCalcium_vector_mice',...
        'lagAmpTrial_FADCalcium_vector_mice','frequency','-v7.3')
end
save(fullfile(saveDir_cat,saveFreqCorr_mice),'lagTimeTrial_HbTCalcium_vector_mice_avg',...
    'lagAmpTrial_HbTCalcium_vector_mice_avg', 'lagTimeTrial_FADCalcium_vector_mice_avg',...
    'lagAmpTrial_FADCalcium_vector_mice_avg','-append')





figure('units','normalized','outerposition',[0 0 0.5 0.5])
options.handle = figure(1);
options.color_area = [0 0 0];
options.color_line = [0 0 0];
options.alpha = 0.5;
options.line_width = 2;
options.x_axis = frequency;
options.error = 'c95';

subplot(1,2,1)
h = zeros(1,2);
options.color_area = [0 0 0];
options.color_line = [0 0 0];
plot_areaerrorbar(lagAmpTrial_HbTCalcium_vector_mice,options)
options.color_area = [0 1 0];
options.color_line = [0 1 0];
hold on
plot_areaerrorbar(lagAmpTrial_FADCalcium_vector_mice,options)
xlabel('Frequency(Hz)')
ylabel('Lag Amplitude')
legend('Calcium HbT','Calcium FAD')
subplot(1,2,2)
options.color_area = [0 0 0];
options.color_line = [0 0 0];
plot_areaerrorbar(lagTimeTrial_HbTCalcium_vector_mice,options)
options.color_area = [0 1 0];
options.color_line = [0 1 0];
hold on
plot_areaerrorbar(lagTimeTrial_FADCalcium_vector_mice,options)
xlabel('Frequency(Hz)')
ylabel('Lag Time(s)')
legend('Calcium HbT','Calcium FAD')

suptitle('Anesthetized')




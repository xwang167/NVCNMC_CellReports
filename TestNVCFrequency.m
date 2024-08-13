
import mouse.*

excelFile = "C:\Users\xiaodanwang\Documents\GitHub\BauerLabXiaodanScripts\DataBase_Xiaodan.xlsx";

load('D:\OIS_Process\noVasculatureMask.mat')
%
% %
% excelRows = [181,183,185,228,232,236,195,202,204,230,234,240];%321:327;
% runs = 1:3;
excelRows = 181;
runs = 3;
edgeLen =1;
tZone = 4;
corrThr = 0;

frequency = 0.01:0.03:(5-0.3);
window = 0.3;
 newfs = 10;
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    fs = excelRaw{7};
    validRange = - edgeLen: round(tZone*newfs); %4*frequency(end)
    %maskName = strcat(recDate,'-',mouseName,'-',sessionType,'1-datahb','.mat');
    %load(fullfile(maskDir,maskName), 'xform_isbrain')
    %save(fullfile(maskDir_new,maskName_new),'xform_isbrain')
    maskDir = strcat('L:\RGECO\Kenny\', recDate, '\');
    if exist(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'file')
        load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(1),'-dataFluor.mat')),'xform_isbrain');
        load(fullfile(maskDir,strcat(recDate,'-',mouseName,'-','LandmarksAndMask.mat')),'affineMarkers')
    else
        maskDir = saveDir;
        maskName = strcat(recDate,'-',mouseName,'-LandmarksAndMask','.mat');
        load(fullfile(maskDir,maskName),'affineMarkers','xform_isbrain','isbrain')
    end
    mask = mask_new.*xform_isbrain;
    
    for n = runs
        disp(strcat('Lag analysis on ', recDate, ' ', mouseName, ' run#', num2str(n)))        
        visName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n));
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        saveFreqCorr = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_freqLag','.mat');
        disp('loading processed data')
        load(fullfile(saveDir,processedName),'xform_datahb','xform_FADCorr','xform_jrgeco1aCorr')
        xform_jrgeco1aCorr = squeeze(xform_jrgeco1aCorr);
        xform_total = squeeze(xform_datahb(:,:,1,:)+ xform_datahb(:,:,2,:));
        clear xform_datahb
        xform_total(isinf(xform_total)) = 0;
        xform_total(isnan(xform_total)) = 0;
        xform_FADCorr(isnan(xform_FADCorr)) = 0;
        xform_FADCorr(isinf(xform_FADCorr)) = 0;
        xform_jrgeco1aCorr(isinf(xform_jrgeco1aCorr)) = 0;
        xform_jrgeco1aCorr(isnan(xform_jrgeco1aCorr)) = 0;
        xform_total = xform_total(77,41,:);
        xform_FADCorr = xform_FADCorr(77,41,:); 
        xform_jrgeco1aCorr = xform_jrgeco1aCorr(77,41,:);
        
        xform_total = xform_total-mean(xform_total,3);
        xform_FADCorr = xform_FADCorr-mean(xform_FADCorr,3);
        xform_jrgeco1aCorr = xform_jrgeco1aCorr-mean(xform_jrgeco1aCorr,3);
        
        
        xform_total_downsample=resampledata_ori(xform_total,fs,newfs,10^(-5));
        clear xform_total
        xform_FADCorr_downsample=resampledata_ori(xform_FADCorr,fs,newfs,10^(-5));
        clear xform_FADCorr
        xform_jrgeco1aCorr_downsample=resampledata_ori(xform_jrgeco1aCorr,fs,newfs,10^(-5));
        clear xform_jrgeco1aCorr
        
        lagTimeTrial_HbTCalcium_vector = nan(1,length(frequency));
        lagAmpTrial_HbTCalcium_vector = nan(1,length(frequency));
        lagTimeTrial_FADCalcium_vector = nan(1,length(frequency));
        lagAmpTrial_FADCalcium_vector = nan(1,length(frequency));
        %%comparing our NVC measures to Hillman (0.02-2)
        
        ii = 1;
        for startFreq = frequency   
            tic
            disp(['filter starting at' num2str(startFreq)])
            xform_total_filtered = mouse.freq.filterData(double(xform_total_downsample),startFreq,startFreq+window,newfs);
            xform_FADCorr_filtered = mouse.freq.filterData(double(xform_FADCorr_downsample),startFreq,startFreq+window,newfs);
            xform_jrgeco1aCorr_filtered = mouse.freq.filterData(double(xform_jrgeco1aCorr_downsample),startFreq,startFreq+window,newfs);
            
            [lagTimeTrial_HbTCalcium,lagAmpTrial_HbTCalcium] = dotLag_mask(xform_total_filtered,...
                xform_jrgeco1aCorr_filtered,edgeLen,validRange,mask,corrThr, true,true);
            lagTimeTrial_HbTCalcium = lagTimeTrial_HbTCalcium/newfs;
            
            [lagTimeTrial_FADCalcium,lagAmpTrial_FADCalcium] = dotLag_mask(xform_FADCorr_filtered,...
                xform_jrgeco1aCorr_filtered,edgeLen,validRange,mask,corrThr, true,true);
            lagTimeTrial_FADCalcium = lagTimeTrial_FADCalcium/newfs;
            
            clear xform_total_filtered xform_FADCorr_filtered xform_jrgeco1aCorr_filtered
            
            lagTimeTrial_HbTCalcium_vector(ii) = nanmean(lagTimeTrial_HbTCalcium,'all');
            lagAmpTrial_HbTCalcium_vector(ii) = nanmean(lagAmpTrial_HbTCalcium,'all');
            
            
            lagTimeTrial_FADCalcium_vector(ii) = nanmean(lagTimeTrial_FADCalcium,'all');
            lagAmpTrial_FADCalcium_vector(ii) = nanmean(lagAmpTrial_FADCalcium,'all');
            
            ii = ii+1;
            
            clear lagTimeTrial_HbTCalcium lagAmpTrial_HbTCalcium lagTimeTrial_FADCalcium lagAmpTrial_FADCalcium
            toc
        end
        
        figure('units','normalized','outerposition',[0 0 0.5 0.5])
        subplot(1,2,1)
        semilogx(frequency,lagAmpTrial_HbTCalcium_vector,'k')
        xlabel('Frequency(Hz)')
        ylabel('Correlation')
        grid on
        hold on
        semilogx(frequency,lagAmpTrial_FADCalcium_vector,'g')
        legend('Calcium HbT','Calcium FAD')
        xlim([0 5])
        subplot(1,2,2)
        semilogx(frequency,lagTimeTrial_HbTCalcium_vector,'k')
        xlabel('Frequency(Hz)')
        ylabel('Lag Time(s)')
        grid on
        hold on
        semilogx(frequency,lagTimeTrial_FADCalcium_vector,'g')
        legend('Calcium HbT','Calcium FAD','location','northwest')
        xlim([0 5])
        
  
        
        suptitle(strcat(recDate,'-',mouseName,'-',sessionType,num2str(n)))
        saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_freqLag.png')));
        saveas(gcf,fullfile(saveDir,strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_freqLag.fig')));
        
        if exist(fullfile(saveDir,saveFreqCorr),'file')
            save(fullfile(saveDir,saveFreqCorr),'lagTimeTrial_HbTCalcium_vector',...
                'lagAmpTrial_HbTCalcium_vector', 'lagTimeTrial_FADCalcium_vector',...
                'lagAmpTrial_FADCalcium_vector','frequency','-append')
        else
            save(fullfile(saveDir,saveFreqCorr),'lagTimeTrial_HbTCalcium_vector',...
                'lagAmpTrial_HbTCalcium_vector', 'lagTimeTrial_FADCalcium_vector',...
                'lagAmpTrial_FADCalcium_vector','frequency','-v7.3')
        end
        clear lagTimeTrial_HbTCalcium_vector lagApmTrial_HbTCalcium_vector...
            lagTimeTrial_FADCalcium_vector lagAmpTrial_FADCalcium_vector
        close all
    end
end
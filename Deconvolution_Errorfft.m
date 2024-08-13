clear ;close all;clc
excelFile = "X:\RGECO\DataBase_Xiaodan_3.xlsx";
startInd = 2;
freqLow = 0.02;
calMax = 8;
hbMax  = 2.5;
FADMax = 1;
hrfMax = 0.007;
mrfMax = 0.0015;
samplingRate = 25;
freq_new     = 250;
t_kernel = 30;
t = (-3*freq_new :(t_kernel-3)*freq_new-1)/freq_new;
load("C:\Users\Xiaodan Wang\Documents\GitHub\BauerLabXiaodanScripts\AtlasandIsbrain_Allen.mat",'parcelnames','AtlasSeeds')

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

for excelRow = [181 183 185 228 232 236 202 195 204 230 234 240]
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    if ~exist(strcat(saveDir,'\Barrel_HRF'),'dir')
        mkdir(strcat(saveDir,'\Barrel_HRF'))
    end
    for n = 1:3
        tic
        disp(strcat(mouseName,', run#',num2str(n)))
        processedName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_processed','.mat');
        load(fullfile(saveDir,processedName),'xform_datahb','xform_FADCorr','xform_jrgeco1aCorr')
        % mask within brain
        HbT = squeeze(xform_datahb(:,:,1,:)+xform_datahb(:,:,2,:))*10^6;% convert to muM
        clear xform_datahb
        FAD = xform_FADCorr*100;
        clear xform_FADCorr
        Calcium = squeeze(xform_jrgeco1aCorr)*100; % convert to DeltaF/F%
        clear xform_jrgeco1aCorr
        % Pad one more frame to full 10 mins
        HbT    (:,:,end+1) = HbT    (:,:,end);
        FAD    (:,:,end+1) = FAD    (:,:,end);
        Calcium(:,:,end+1) = Calcium(:,:,end);
        % Filter 0.02-2Hz, downsample to 10 Hz
        HbT     = filterData(HbT,    freqLow,2,samplingRate);
        FAD     = filterData(FAD,    freqLow,2,samplingRate);
        Calcium = filterData(Calcium,freqLow,2,samplingRate);

        % Reshape into 30 seconds
        HbT     = reshape(HbT    ,128,128,t_kernel*samplingRate,[]);
        FAD     = reshape(FAD    ,128,128,t_kernel*samplingRate,[]);
        Calcium = reshape(Calcium,128,128,t_kernel*samplingRate,[]);

        % load HRF and MRF
        load(fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Upsample','.mat')),'HRF')
        load(fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Upsample','.mat')),'MRF')

        fft2_error_HbT = zeros(21-startInd,7500,50);
        fft2_error_FAD = zeros(21-startInd,7500,50);
        jj = 1;
        HbT_pred = zeros(21-startInd,7500,50);
        FAD_pred = zeros(21-startInd,7500,50);
        for ii = startInd:20

            % reshape for each window
            HbT_temp     = reshape(HbT    (:,:,:,ii),128*128,[]);
            FAD_temp     = reshape(FAD    (:,:,:,ii),128*128,[]);
            Calcium_temp = reshape(Calcium(:,:,:,ii),128*128,[]);

            % upsample to 250 Hz
            HbT_resample     = resample(HbT_temp    ,freq_new,samplingRate,'Dimension',2);
            FAD_resample     = resample(FAD_temp    ,freq_new,samplingRate,'Dimension',2);
            Calcium_resample = resample(Calcium_temp,freq_new,samplingRate,'Dimension',2);
            %% Calculate HRF and MRF

            for region = 1:50
                % Mean signal inside of the regional mask
                mask_region = zeros(128,128);
                mask_region(mask == region) = 1;
                mask_region = logical(mask_region);
                HbT_region     = mean(HbT_resample    (mask_region(:),:));
                FAD_region     = mean(FAD_resample    (mask_region(:),:));
                Calcium_region = mean(Calcium_resample(mask_region(:),:));

                % starting point to be zero
                HbT_region     = tukeywin(length(HbT_region)    ,.3).*squeeze(HbT_region'    );
                FAD_region     = tukeywin(length(FAD_region)    ,.3).*squeeze(FAD_region'    );
                Calcium_region = tukeywin(length(Calcium_region),.3).*squeeze(Calcium_region');

                             
                % Predicted HbT
                temp = conv(Calcium_region,HRF(jj,:,region));
                temp = temp(1:(length(HbT_region)+3*freq_new))';
                HbT_pred(jj,:,region) = temp(3*freq_new+1:3*freq_new+length(HbT_region));
                % Error
                mu_ori = mean(HbT_region);
                sig_ori = std(HbT_region);
                mu_pred = mean(HbT_pred(jj,:,region));

                HbT_region_norm = (HbT_region'-mu_ori)/sig_ori;
                HbT_pred_norm = (HbT_pred(jj,:,region)-mu_pred)/sig_ori;
                error_HbT_norm = HbT_region_norm-HbT_pred_norm;
                % Power Spectral Density of Error
                fft2_error_HbT(jj,:,region)= fft(error_HbT_norm);

                % Predicted FAD
                temp = conv(Calcium_region,MRF(jj,:,region));
                temp = temp(1:(length(FAD_region)+3*freq_new))';
                FAD_pred(jj,:,region) = temp(3*freq_new+1:3*freq_new+length(FAD_region));
                % Error
                mu_ori = mean(FAD_region);
                sig_ori = std(FAD_region);
                mu_pred = mean(FAD_pred(jj,:,region));
                
                FAD_region_norm = (FAD_region'-mu_ori)/sig_ori;
                FAD_pred_norm = (FAD_pred(jj,:,region)-mu_pred)/sig_ori;
                error_FAD_norm = FAD_region_norm-FAD_pred_norm;
                % Power Spectral Density of Error
                fft2_error_FAD(jj,:,region) = fft(error_FAD_norm);
                hz2 = 250/7500*(0:7500-1);
                % Visualization 

                % FAD
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(2,3,1)
                plot((1:t_kernel*freq_new)/freq_new,FAD_region_norm,'g')
                hold on
                plot((1:t_kernel*freq_new)/freq_new,FAD_pred_norm,'c')
                xlabel('Time(s)')
                ylabel('\DeltaF/F')
                legend('Norm Actual','Norm Predicted')               
                grid on
                title('FAD Time Series')

                subplot(2,3,2)
                plot((1:t_kernel*freq_new)/freq_new,error_FAD_norm,'g')
                xlabel('Time(s)')
                ylabel('\DeltaF/F')          
                grid on
                title('FAD Error Time Series')


                subplot(2,3,3)
                loglog(hz2,abs(fft2_error_FAD(jj,:,region)),'g')
                xlabel('Frequency(Hz)')
                ylabel('Power/Frequency((\DeltaF/F)^2/Hz)')
                xlim([0.2 2])
                title('FAD Error fft')

                % HbT
                subplot(2,3,4)
                plot((1:t_kernel*freq_new)/freq_new,HbT_region_norm,'k')
                hold on
                plot((1:t_kernel*freq_new)/freq_new,HbT_pred_norm,'Color',[0.5 0.5 0.5])
                xlabel('Time(s)')
                ylabel('\Delta\muM')
                legend('Norm Actual','Norm Predicted')               
                grid on
                title('HbT Time Series')

                subplot(2,3,5)
                plot((1:t_kernel*freq_new)/freq_new,error_HbT_norm,'k')
                xlabel('Time(s)')
                ylabel('\Delta\muM')          
                grid on
                title('HbT Error Time Series')


                subplot(2,3,6)
                loglog(hz2,abs(fft2_error_HbT(jj,:,region)),'k')
                xlabel('Frequency(Hz)')
                ylabel('Power/Frequency((\Delta\muM)^2/Hz)')
                xlim([0.2 2])
                title('HbT Error fft')


                sgtitle(strcat('HbT Error fft for Region',{' '},parcelnames{region},', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))

                saveName =  fullfile(saveDir, strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-',parcelnames{region},'-HRF-Error-fft'));
                saveas(gcf,strcat(saveName,'.fig'))
                saveas(gcf,strcat(saveName,'.png'))
                close all
            end
            jj = jj+1;
        end
        clear HbT FAD Calcium
         % save HRF
        save(fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Upsample','.mat')),'HbT_pred','fft2_error_HbT','hz2','-append')

        % save MRF
        save(fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Upsample','.mat')),'FAD_pred','fft2_error_FAD','hz2','-append')

    toc
    end
end

save("D:\XiaodanPaperData\cat\deconvolution_allRegions.mat",'hz2','-append')



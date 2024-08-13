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
lambda_HRF = 5e-7;
lambda_MRF = 5e-7;
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

        % Initialization
        for h = {'HRF','MRF'}
            eval(strcat('r_',h{1},'= zeros(21-startInd,50);'))
            eval(strcat(h{1},'     = zeros(21-startInd,freq_new*t_kernel,50);'))
        end
        jj = 1;
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

                X = convmtx(Calcium_region,length(Calcium_region));
                % make it square
                X = X(1:length(Calcium_region),1:length(Calcium_region));
                [~,S,~]=svd(X);
                
                % Least square deconvolution
                HRF(jj,:,region)= (X'*S*X+(S(1,1).^2)*lambda_HRF*eye(length(Calcium_region))) \ (X'*S*[zeros(3*freq_new,1); HbT_region(1:end-3*freq_new)]);% add 3s of zeros
                MRF(jj,:,region)= (X'*S*X+(S(1,1).^2)*lambda_MRF*eye(length(Calcium_region))) \ (X'*S*[zeros(3*freq_new,1); FAD_region(1:end-3*freq_new)]);% add 3s of zeros
                
                % Predicted HbT
                HbT_pred = conv(Calcium_region,HRF(jj,:,region));
                HbT_pred = HbT_pred(1:(length(HbT_region)+3*freq_new))';
                r_HRF(jj,region)= corr(HbT_region,HbT_pred(3*freq_new+1:end));
                % Visualization for HRF
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(2,2,1)
                imagesc(mask_region)
                axis image off
                title(parcelnames{region})
                
                subplot(2,2,2)
                plot((1:t_kernel*freq_new)/freq_new,HbT_region,'k')
                ylabel('\Delta\muM')
                ylim([-hbMax hbMax])
                hold on
                yyaxis right
                plot((1:t_kernel*freq_new)/freq_new,Calcium_region,'m')
                legend('HbT','jRGECO1a')
                ylim([-calMax calMax])
                ylabel('\DeltaF/F%')
                xlabel('Time(s)')
                title(strcat('Time Course for',{' '},parcelnames{region}))
                grid on

                subplot(2,2,3)
                plot(t,HRF(jj,:,region))
                xlim([-3 10])
                ylim([-hrfMax hrfMax])
                ylabel('\Delta\muM/\DeltaF/F%')
                xlabel('Time(s)')
                title(strcat('HRF for',{' '},parcelnames{region}))
                grid on

                subplot(2,2,4)
                plot((1:t_kernel*freq_new)/freq_new,HbT_region,'k')
                hold on
                plot((1:t_kernel*freq_new)/freq_new,HbT_pred(3*freq_new+1:3*freq_new+length(HbT_region)),'Color',[0 0.5 0])
                xlabel('Time(s)')
                ylabel('\Delta\muM')
                legend('Actual HbT','Predicted HbT')
                title(strcat('r = ',num2str(r_HRF(jj,region))))
                grid on

                sgtitle(strcat('HRF for Region',{' '},parcelnames{region},',',{' '},num2str(freqLow),'-2Hz, no GSR, lambda = ',num2str(lambda_HRF),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
                if ~exist(fullfile(saveDir,'HRF_Upsample'))
                    mkdir(fullfile(saveDir,'HRF_Upsample'))
                end
                saveName =  fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-',parcelnames{region},'-NoGSR-HRF'));
                saveas(gcf,strcat(saveName,'.fig'))
                saveas(gcf,strcat(saveName,'.png'))

                % Predicted FAD
                FAD_pred = conv(Calcium_region,MRF(jj,:,region));
                FAD_pred = FAD_pred(1:(length(FAD_region)+3*freq_new))';
                r_MRF(jj,region)= corr(FAD_region,FAD_pred(3*freq_new+1:end));

                % Visualize MRF
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(2,2,1)
                imagesc(mask_region)
                axis image off
                title(parcelnames{region})
                grid on

                subplot(2,2,2)
                plot((1:t_kernel*freq_new)/freq_new,FAD_region,'g')
                ylabel('\DeltaF/F%')
                ylim([-FADMax FADMax])
                hold on
                yyaxis right
                plot((1:t_kernel*freq_new)/freq_new,Calcium_region,'m')
                legend('FAD','jRGECO1a')
                ylim([-calMax calMax])
                ylabel('\DeltaF/F%')
                xlabel('Time(s)')
                title(strcat('Time Course for',{' '},parcelnames{region}))
                grid on

                subplot(2,2,3)
                plot(t,MRF(jj,:,region))
                xlim([-3 10])
                ylim([-mrfMax mrfMax])
                ylabel('\DeltaF/F%/\DeltaF/F%')
                xlabel('Time(s)')
                title(strcat('MRF for',{' '},parcelnames{region}))
                grid on

                subplot(2,2,4)
                plot((1:t_kernel*freq_new)/freq_new,FAD_region,'g')
                hold on
                plot((1:t_kernel*freq_new)/freq_new,FAD_pred(3*freq_new+1:3*freq_new+length(FAD_region)),'k')
                xlabel('Time(s)')
                ylabel('\DeltaF/F%')
                legend('Actual FAD','Predicted FAD')

                title(strcat('r = ',num2str(r_MRF(jj,region))))
                ylim([-FADMax FADMax])
                grid on

                sgtitle(strcat('MRF for Region',{' '},parcelnames{region},',',{' '},num2str(freqLow),'-2Hz, no GSR, lambda = ',num2str(lambda_MRF),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
                if ~exist(fullfile(saveDir,'MRF_Upsample'))
                    mkdir(fullfile(saveDir,'MRF_Upsample'))
                end
                saveName =  fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-',rparcelnames{region},'-NoGSR-MRF'));
                saveas(gcf,strcat(saveName,'.fig'))
                saveas(gcf,strcat(saveName,'.png'))
                close all
            end
            jj = jj+1;
        end
        clear HbT FAD Calcium

        % save HRF
        save(fullfile(saveDir,'HRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Upsample','.mat')),'HRF','r_HRF')

        % save MRF
        save(fullfile(saveDir,'MRF_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Upsample','.mat')),'MRF','r_MRF')
    toc
    end
end



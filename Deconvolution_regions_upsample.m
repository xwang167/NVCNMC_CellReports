clear ;close all;clc
excelFile = "X:\RGECO\DataBase_Xiaodan_4.xlsx";
startInd = 2;
freqLow = 0.02;
calMax = 8;
hbMax  = 1.5;
FADMax = 1;
hrfMax = 0.02;
mrfMax = 0.002;
samplingRate =25;
freq_new     = 250;
lambda_HRF = 5e-7;
lambda_MRF = 5e-7;
t_kernel = 30;
t = (-3*freq_new :(t_kernel-3)*freq_new-1)/freq_new        ;
load("noVasculatureMask.mat",'mask_new')
load('AtlasandIsbrain.mat','AtlasSeedsFilled')
AtlasSeedsFilled(AtlasSeedsFilled==0) = nan;
AtlasSeedsFilled(:,65:128) = AtlasSeedsFilled(:,65:128)+20;

% Mask for different regions
mask_M2_L = AtlasSeedsFilled==4;
mask_M1_L = AtlasSeedsFilled==5;
mask_SS_L = AtlasSeedsFilled==6 | AtlasSeedsFilled==7 | AtlasSeedsFilled==8 | AtlasSeedsFilled==9 | AtlasSeedsFilled==10 | AtlasSeedsFilled==11;
mask_P_L  = AtlasSeedsFilled==13 | AtlasSeedsFilled==14 | AtlasSeedsFilled==15;
mask_V1_L = AtlasSeedsFilled==17;
mask_V2_L = AtlasSeedsFilled==16|AtlasSeedsFilled==18;

mask_M2_R = AtlasSeedsFilled==24;
mask_M1_R = AtlasSeedsFilled==25;
mask_SS_R = AtlasSeedsFilled==26 | AtlasSeedsFilled==27 | AtlasSeedsFilled==28 | AtlasSeedsFilled==29 | AtlasSeedsFilled==30 | AtlasSeedsFilled==31;
mask_P_R  = AtlasSeedsFilled==33 | AtlasSeedsFilled==34 | AtlasSeedsFilled==35;
mask_V1_R = AtlasSeedsFilled==37;
mask_V2_R = AtlasSeedsFilled==36|AtlasSeedsFilled==38;


for excelRow = [ 202 195 204 230 234 240]%181 183 185 228 232 236

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
        load(fullfile(saveDir,processedName),'xform_datahb','xform_FADCorr','xform_jrgeco1aCorr','xform_isbrain')
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

        % Regions within brain without vasculature
        mask_M2_L = logical(mask_M2_L.*mask_new.*xform_isbrain);
        mask_M1_L = logical(mask_M1_L.*mask_new.*xform_isbrain);
        mask_SS_L = logical(mask_SS_L.*mask_new.*xform_isbrain);
        mask_P_L  = logical(mask_P_L .*mask_new.*xform_isbrain);
        mask_V1_L = logical(mask_V1_L.*mask_new.*xform_isbrain);
        mask_V2_L = logical(mask_V2_L.*mask_new.*xform_isbrain);

        mask_M2_R = logical(mask_M2_R.*mask_new.*xform_isbrain);
        mask_M1_R = logical(mask_M1_R.*mask_new.*xform_isbrain);
        mask_SS_R = logical(mask_SS_R.*mask_new.*xform_isbrain);
        mask_P_R  = logical(mask_P_R .*mask_new.*xform_isbrain);
        mask_V1_R = logical(mask_V1_R.*mask_new.*xform_isbrain);
        mask_V2_R = logical(mask_V2_R.*mask_new.*xform_isbrain);

        % Initialization
        for h = {'HRF','MRF'}
            for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}
                eval(strcat('r_',h{1},'_',region{1},'=zeros(1,21-startInd);'))
                eval(strcat(h{1},'_',region{1},'=zeros(21-startInd,freq_new*t_kernel);'))
            end
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

            for region = {'M2_L','M1_L','SS_L','P_L','V1_L','V2_L','M2_R','M1_R','SS_R','P_R','V1_R','V2_R'}

                % Mean signal inside of the regional mask
                eval(strcat('HbT_region     = mean(HbT_resample    (mask','_',region{1},'(:),:));'))
                eval(strcat('FAD_region     = mean(FAD_resample    (mask','_',region{1},'(:),:));'))
                eval(strcat('Calcium_region = mean(Calcium_resample(mask','_',region{1},'(:),:));'))

                % starting point to be zero
                HbT_region     = tukeywin(length(HbT_region)    ,.3).*squeeze(HbT_region'    );
                FAD_region     = tukeywin(length(FAD_region)    ,.3).*squeeze(FAD_region'    );
                Calcium_region = tukeywin(length(Calcium_region),.3).*squeeze(Calcium_region');

                X = convmtx(Calcium_region,length(Calcium_region));
                % make it square
                X = X(1:length(Calcium_region),1:length(Calcium_region));
                [~,S,~]=svd(X);
                
                % Least square deconvolution
                eval(strcat('HRF_',region{1},'(jj,:)= (X',char(39),'*S*X+(S(1,1).^2)*lambda_HRF','*eye(length(Calcium_region))) \ (X',char(39),'*S*[zeros(3*freq_new,1); HbT_region(1:end-3*freq_new)]);'));% add 3s of zeros
                eval(strcat('MRF_',region{1},'(jj,:)= (X',char(39),'*S*X+(S(1,1).^2)*lambda_MRF','*eye(length(Calcium_region))) \ (X',char(39),'*S*[zeros(3*freq_new,1); FAD_region(1:end-3*freq_new)]);'));% add 3s of zeros
                
                % Predicted HbT
                eval(strcat('HbT_pred = conv(Calcium_region,HRF_',region{1},'(jj,:));'))
                HbT_pred = HbT_pred(1:(length(HbT_region)+3*freq_new))';
                eval(strcat('r_HRF_',region{1},'(jj)= corr(HbT_region,HbT_pred(3*freq_new+1:end));'));
                % Visualization for HRF
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(2,2,1)
                eval(strcat('imagesc(mask_',region{1},')'))
                axis image off
                title(region)
                grid on

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
                title(strcat('Time Course for',{' '},region{1}))
                grid on

                subplot(2,2,3)
                eval(strcat('plot(t,HRF_',region{1},'(jj,:))'))
                xlim([-3 10])
                ylim([-hrfMax hrfMax])
                ylabel('\Delta\muM/\DeltaF/F%')
                xlabel('Time(s)')
                title(strcat('HRF for',{' '},region{1}))
                grid on

                subplot(2,2,4)
                plot((1:t_kernel*freq_new)/freq_new,HbT_region,'k')
                hold on
                plot((1:t_kernel*freq_new)/freq_new,HbT_pred(3*freq_new+1:3*freq_new+length(HbT_region)),'Color',[0 0.5 0])
                xlabel('Time(s)')
                ylabel('\Delta\muM')
                legend('Actual HbT','Predicted HbT')
                eval(strcat('title(strcat(',char(39),'r = ',char(39),',num2str(r_HRF_',region{1},'(jj))))'))
                ylim([-hbMax hbMax])
                grid on

                sgtitle(strcat('HRF for Region',{' '},region{1},',',{' '},num2str(freqLow),'-2Hz, no GSR, lambda = ',num2str(lambda_HRF),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
                if ~exist(fullfile(saveDir,'HRF_Regions_Upsample'))
                    mkdir(fullfile(saveDir,'HRF_Regions_Upsample'))
                end
                saveName =  fullfile(saveDir,'HRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-',region{1},'-NoGSR-HRF'));
                saveas(gcf,strcat(saveName,'.fig'))
                saveas(gcf,strcat(saveName,'.png'))

                % Predicted FAD
                eval(strcat('FAD_pred = conv(Calcium_region,MRF_',region{1},'(jj,:));'))
                FAD_pred = FAD_pred(1:(length(FAD_region)+3*freq_new))';
                eval(strcat('r_MRF_',region{1},'(jj)= corr(FAD_region,FAD_pred(3*freq_new+1:end));'));

                % Visualize MRF
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(2,2,1)
                eval(strcat('imagesc(mask_',region{1},')'))
                axis image off
                title(region)
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
                title(strcat('Time Course for',{' '},region{1}))
                grid on

                subplot(2,2,3)
                eval(strcat('plot(t,MRF_',region{1},'(jj,:))'))
                xlim([-3 10])
                ylim([-mrfMax mrfMax])
                ylabel('\DeltaF/F%/\DeltaF/F%')
                xlabel('Time(s)')
                title(strcat('MRF for',{' '},region{1}))
                grid on

                subplot(2,2,4)
                plot((1:t_kernel*freq_new)/freq_new,FAD_region,'g')
                hold on
                plot((1:t_kernel*freq_new)/freq_new,FAD_pred(3*freq_new+1:3*freq_new+length(FAD_region)),'k')
                xlabel('Time(s)')
                ylabel('\DeltaF/F%')
                legend('Actual FAD','Predicted FAD')
                eval(strcat('title(strcat(',char(39),'r = ',char(39),',num2str(r_MRF_',region{1},'(jj))))'))
                ylim([-FADMax FADMax])
                grid on

                sgtitle(strcat('MRF for Region',{' '},region{1},',',{' '},num2str(freqLow),'-2Hz, no GSR, lambda = ',num2str(lambda_MRF),', ',mouseName,' Run #',num2str(n),', Segment #',num2str(ii)))
                if ~exist(fullfile(saveDir,'MRF_Regions_Upsample'))
                    mkdir(fullfile(saveDir,'MRF_Regions_Upsample'))
                end
                saveName =  fullfile(saveDir,'MRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'-segment#',num2str(ii),'-',region{1},'-NoGSR-MRF'));
                saveas(gcf,strcat(saveName,'.fig'))
                saveas(gcf,strcat(saveName,'.png'))
                close all
            end
            jj = jj+1;
        end
        clear HbT FAD Calcium

        % save HRF
        save(fullfile(saveDir,'HRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_HRF_Regions_Upsample','.mat')),...
            'HRF_M2_L','HRF_M1_L','HRF_SS_L','HRF_P_L','HRF_V1_L','HRF_V2_L',...
            'HRF_M2_R','HRF_M1_R','HRF_SS_R','HRF_P_R','HRF_V1_R','HRF_V2_R',...
            'r_HRF_M2_L','r_HRF_M1_L','r_HRF_SS_L','r_HRF_P_L','r_HRF_V1_L','r_HRF_V2_L',...
            'r_HRF_M2_R','r_HRF_M1_R','r_HRF_SS_R','r_HRF_P_R','r_HRF_V1_R','r_HRF_V2_R')

        % save MRF
        save(fullfile(saveDir,'MRF_Regions_Upsample', strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'_MRF_Regions_Upsample','.mat')),...
            'MRF_M2_L','MRF_M1_L','MRF_SS_L','MRF_P_L','MRF_V1_L','MRF_V2_L',...
            'MRF_M2_R','MRF_M1_R','MRF_SS_R','MRF_P_R','MRF_V1_R','MRF_V2_R',...
            'r_MRF_M2_L','r_MRF_M1_L','r_MRF_SS_L','r_MRF_P_L','r_MRF_V1_L','r_MRF_V2_L',...
            'r_MRF_M2_R','r_MRF_M1_R','r_MRF_SS_R','r_MRF_P_R','r_MRF_V1_R','r_MRF_V2_R')
    toc
    end
end



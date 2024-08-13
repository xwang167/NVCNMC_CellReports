%%Example load
clear all
path='X:\jonah_gamma\Stim\RGECO\';
tmp=readtable([path, 'RGECO_stim.xlsx']);
runsInfo.samplingRate=25;
% OGFS=25;
% FS=10;
%run level
% for row=1:size(tmp,1)
%
%     for stim=1:3
%         save_name=[path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim' ,num2str(stim) , '-NVC.mat'];
%         if exist(save_name)
%             disp(['Already Processed: '  save_name])
%         else
%
%             mouse_name= [path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim', num2str(stim),'_processed.mat'];
%             disp(mouse_name(1:end-4))
%             load(mouse_name,'xform_jrgeco1aCorr','xform_datahb')
%             try
%                 load([path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim1-dataFluor.mat'])
%             catch
%                 load([path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-LandmarksandMask.mat'])
%             end
%
%
%             xform_jrgeco1aCorr=squeeze(xform_jrgeco1aCorr);
%             isbrain=find(xform_isbrain);
%
%             oxy=squeeze(xform_datahb(:,:,1,:));
%             doxy=squeeze(xform_datahb(:,:,2,:));
%             total=oxy+doxy;
%             calcium=squeeze(xform_jrgeco1aCorr);
%
%             OGsize=size(oxy);
%             OGsize(end)=round(OGsize(end)*(FS/OGFS));
%             data_full=nan([128^2,OGsize(end),4]);
%
%             data_full(:,:,1)=  reshape(resample(filterData(oxy,    0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
%             data_full(:,:,2)=  reshape(resample(filterData(doxy ,  0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
%             data_full(:,:,3)=  reshape(resample(filterData(total,  0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
%             data_full(:,:,4)=  reshape(resample(filterData(calcium,0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*100;
%             data_full=data_full(isbrain,:,:);
%             data_full=data_full-mean(data_full,2); %mean shift
%             data_full=reshape(data_full,[],300,10,4); %reshape into blocks
%
%             clear oxy doxy total calcium xform_isbrian
%
%
%             %% for whole brain
%             %initializing
%             Contrast={'HbO','HbR','HbT','Calcium'};
%             kernel_size=30;
%             pixHrfParam_BRAIN=nan(numel(isbrain),size(data_full,3),3,3);
%             h_brain=nan(numel(isbrain),size(data_full,3),3,size(data_full,2));
%             h_deriv_brain=nan(numel(isbrain),size(data_full,3),3,size(data_full,2));
%             h_mp_brain=nan(numel(isbrain),size(data_full,3),3,size(data_full,2));
%             e = ones(size(data_full,2), 1);
%             D = spdiags([e -2*e e], 0:2, size(data_full,2)-2, size(data_full,2));       % second-order difference
%             lam=1E5; %regularization
%             lam_mp=1E0;
%             lam_deriv=1E4; %regularization
%             t=linspace(0,kernel_size,kernel_size*FS );
%
%             weight=blackman(600);
%             weight=weight(301:end);
%             W=diag(weight.^4);
%
%             for block=1:size(data_full,3)
%                 parfor pix=1:length(isbrain)
%                     for species=1:3
%                         %gamma-fit
%                         [~, pixHrfParam_BRAIN(pix,block,species,:),~,~,~] =...
%                             parforEvalc(t,squeeze(squeeze(data_full(pix,:,block,4))),squeeze(squeeze(data_full(pix,:,block,species))));
%                         %Deconvolution
%                         X = convmtx(squeeze(squeeze(data_full(pix,:,block,4)))', (size(data_full,2))); %convolution matrix
%                         X=X(1:size(data_full,2),1:size(data_full,2)); %truncate because it pads with zeroes
%                         normie=norm(X'*X,2);
% %                         [~,S,~]=svd(X'*X);
% %                         S=S.^.1;
%
%                         h_brain(pix,block,species,:)=(X'*X+lam*eye(size(data_full,2))) \ (X'*data_full(pix,:,block,species)' );
%                         h_deriv_brain(pix,block,species,:)=(X'*X+lam_deriv*D'*D) \ (X'*data_full(pix,:,block,species)' );
%                         h_mp_brain(pix,block,species,:)=X'*(((X*X'+normie*(lam_mp) *eye(size(data_full,2)) )))^-1 * data_full(pix,:,block,species)';
%                     end
%                 end
%             end
%
%
%             save(save_name,'pixHrfParam_BRAIN','h_brain','h_deriv_brain','h_mp_brain')
%
%         end
%     end
% end


%% Vis for each run
OGFS=25;
FS=10;

for row=1:size(tmp,1)
    
    %load mask
    try
        load([path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim1-dataFluor.mat'])
    catch
        load([path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-LandmarksandMask.mat'])
    end
    
    for stim=1:3
        %loading things
        mouse_name= [path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim', num2str(stim),'_processed.mat'];
        disp(['Averaging: ' mouse_name(1:end-4)])
        load(mouse_name,'xform_jrgeco1aCorr','xform_datahb')
        loadname=[path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim' ,num2str(stim) , '-NVC.mat'];
        load(loadname)
        % Find ROI
        try
            load(mouse_name,'ROI_GSR')
        catch
            load(mouse_name,'xform_jrgeco1aCorr_GSR')
            calcium = reshape(xform_jrgeco1aCorr_GSR,128,128,[],10);
            calcium = mean(calcium,4);
            peakMap = mean(calcium(:,:,125:250),3);
            figure
            imagesc(peakMap)
            [X,Y] = meshgrid(1:128,1:128);
            
            [x1,y1] = ginput(1);
            [x2,y2] = ginput(1);
            
            radius = sqrt((x1-x2)^2+(y1-y2)^2);
            
            ROI = sqrt((X-x1).^2+(Y-y1).^2)<radius;
            min_ROI = prctile(peakMap(ROI),1);
            temp = double(peakMap).*double(ROI);
            ROI = temp<min_ROI*0.75;
            ROI_GSR = ROI;
        end
        ROI_GSR=find(xform_isbrain.*ROI_GSR);
        %Data shaping
        xform_jrgeco1aCorr=squeeze(xform_jrgeco1aCorr);
        isbrain=find(xform_isbrain);
        [~,isROI_GSR] = intersect(isbrain,ROI_GSR);
        
        
        oxy=squeeze(xform_datahb(:,:,1,:));
        doxy=squeeze(xform_datahb(:,:,2,:));
        clear xform_datahb
        total=oxy+doxy;
        calcium=squeeze(xform_jrgeco1aCorr);
        clear xform_jrgeco1aCorr
        
        OGsize=size(oxy);
        OGsize(end)=round(OGsize(end)*(FS/OGFS));
        data_full=nan([128^2,OGsize(end),4]);
        
        data_full(:,:,1)=  reshape(resample(filterData(oxy,    0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
        data_full(:,:,2)=  reshape(resample(filterData(doxy ,  0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
        data_full(:,:,3)=  reshape(resample(filterData(total,  0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
        data_full(:,:,4)=  reshape(resample(filterData(calcium,0.02,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*100;
        clear oxy doxy total calcium xform_isbrian
        data_full=data_full(ROI_GSR,:,:);
        data_full=data_full-mean(data_full,2); %mean shift
        data_full=reshape(data_full,[],300,10,4); %reshape into blocks
        runInfo.samplingRate=10;
        
        h_ROI = h_brain(isROI_GSR,:,:,:);
        h_mp_ROI = h_mp_brain(isROI_GSR,:,:,:);
        h_deriv_ROI = h_deriv_brain(isROI_GSR,:,:,:);
        pixHrfParam_ROI = pixHrfParam_BRAIN(isROI_GSR,:,:,:);
        
        data_full_pixs_blocks = nan(size(data_full,1)*size(data_full,3),size(data_full,2),size(data_full,4));
        hrfPix = nan(size(h_ROI,1)*size(h_ROI,2),size(h_ROI,4),size(h_ROI,3));
        hrfPixMP = nan(size(h_mp_ROI,1)*size(h_mp_ROI,2),size(h_mp_ROI,4),size(h_mp_ROI,3));
        hrfPixDeriv = nan(size(h_deriv_ROI,1)*size(h_deriv_ROI,2),size(h_deriv_ROI,4),size(h_deriv_ROI,3));
        gamma = nan(size(pixHrfParam_ROI,1)*size(pixHrfParam_ROI,2),300,size(pixHrfParam_ROI,4));
        
        
        out_hrfPix = nan(size(h_ROI,1)*size(h_ROI,2),size(h_ROI,4),size(h_ROI,3));
        out_hrfPixMP = nan(size(h_mp_ROI,1)*size(h_mp_ROI,2),size(h_mp_ROI,4),size(h_mp_ROI,3));
        out_hrfPixDeriv = nan(size(h_deriv_ROI,1)*size(h_deriv_ROI,2),size(h_deriv_ROI,4),size(h_deriv_ROI,3));
        out_gamma = nan(size(pixHrfParam_ROI,1)*size(pixHrfParam_ROI,2),300,size(pixHrfParam_ROI,4));
        kk = 1;
        for ii = 1:size(data_full,3)
            for jj = 1:size(data_full,1)
                data_full_pixs_blocks(kk,:,:) = squeeze(data_full(jj,:,ii,:));
                hrfPix(kk,:,:) = transpose(squeeze(h_ROI(jj,ii,:,:)));
                hrfPixMP(kk,:,:) = transpose(squeeze(h_mp_ROI(jj,ii,:,:)));
                hrfPixDeriv(kk,:,:) = transpose(squeeze(h_deriv_ROI(jj,ii,:,:)));
                for contrast = 1:3
                    in = squeeze(data_full_pixs_blocks(kk,:,contrast));
                    gamma(kk,:,contrast) = hrfGamma(linspace(0,30,30*10),pixHrfParam_ROI(jj,ii,contrast,1),pixHrfParam_ROI(jj,ii,contrast,2),pixHrfParam_ROI(jj,ii,contrast,3));
                    tmp = conv(squeeze(hrfPix(kk,:,contrast)),in);
                    out_hrfPix(kk,:,contrast) = tmp(1:length(in));
                    tmp_MP = conv(squeeze(hrfPixMP(kk,:,contrast)),in);
                    out_hrfPixMP(kk,:,contrast) = tmp_MP(1:length(in));
                    tmp_Deriv = conv(squeeze(hrfPixDeriv(kk,:,contrast)),in);
                    out_hrfPixDeriv(kk,:,contrast) = tmp_Deriv(1:length(in));
                    tmp_gamma = conv(squeeze(gamma(kk,:,contrast)),in);
                    out_gamma(kk,:,contrast) = tmp_gamma(1:length(in));
                end
                kk = kk+1;
            end
        end
        %plotting things
        ContName={'HbO','HbR','HbT'};
        colors={[1 0 0],[0 0 1],[ 0 0 0]};
        
        in = data_full_pixs_blocks(:,:,4);
        for contrast=1:3
            
            figure('units','normalized','outerposition',[0 0 1 1])
            subplot(241)
            plot_distribution_prctile((1:300)/10,in,'Prctile',[5 95],'Color',[1 0 1],'Alpha',0.4)
            grid on
            xlabel('Time(s)')
            ylabel('\DeltaF/F%')
            title('jRGECO1a')
            
            subplot(242)
            plot_distribution_prctile((1:300)/10,hrfPix(:,:,contrast),'Prctile',[5 95],'Color',[0.8500, 0.3250, 0.0980],'Alpha',0.4)
            hold on
            plot_distribution_prctile((1:300)/10,hrfPixMP(:,:,contrast),'Prctile',[5 95],'Color',[0.4940, 0.1840, 0.5560],'Alpha',0.4)
            
            title('HRF')
            [hh,icons,plots,txt] = legend({'\color[rgb]{0.8500, 0.3250, 0.0980} Deconv','\color[rgb]{0.4940, 0.1840, 0.5560} Deconv_{Pseudo}'});
            icons(3).FaceColor = [0.8500, 0.3250, 0.0980];
            icons(4).FaceColor = [0.4940, 0.1840, 0.5560];
            xlabel('Time(s)')
            %icons(6).FaceColor = [0, 0.5, 0];
            grid on
            subplot(243)
            plot_distribution_prctile((1:300)/10,hrfPixDeriv(:,:,contrast),'Prctile',[5 95],'Color',[0.3010, 0.7450, 0.9330],'Alpha',0.4)
            title('Derivative Deconvolution')
            xlabel('Time(s)')
            grid on
            subplot(244)
            plot_distribution_prctile((1:300)/10,gamma(:,:,contrast),'Prctile',[5 95],'Color',[0, 0.5, 0],'Alpha',0.4)
            title('Gamma HRF')
            grid on
            xlabel('Time(s)')
            
            %             subplot(133)
            %             plot(linspace(0,30,30*runInfo.samplingRate),out,'color',colors{contrast})
            %             grid on
            %             hold on
            %             plot(linspace(0,60,60*runInfo.samplingRate-1),...
            %                 conv(hrfPix, in)  ...
            %                 )
            %             plot(linspace(0,60,60*runInfo.samplingRate-1),...
            %                 conv(hrfPixMP, in)  ...
            %                 )
            %             plot(linspace(0,60,60*runInfo.samplingRate-1),...
            %                 conv(hrfPixDeriv, in)  ...
            %                 )
            %             plot(linspace(0,60,60*runInfo.samplingRate-1),...
            %                 conv(gamma, in)  ...
            %                 )
            %             legend({'OG','Deconv','Deconv_{Pseudo}','Deconv_{Deriv}','Gamma'})
            %             xlim([0 30])
            color_legend = cell(1,3);
            color_legend{1} = num2str(colors{contrast}(1));
            color_legend{2} = num2str(colors{contrast}(2));
            color_legend{3} = num2str(colors{contrast}(3));
            Contrast_legend = strcat('\color[rgb]','{',color_legend{1},',',color_legend{2}, ',',color_legend{3},'}',32, ContName{contrast});
            subplot(245)
            plot_distribution_prctile((1:300)/10,data_full_pixs_blocks(:,:,contrast),'Prctile',[5 95],'Color',colors{contrast},'Alpha',0.4)
            hold on
            plot_distribution_prctile((1:300)/10,out_hrfPix(:,:,contrast),'Prctile',[5 95],'Color',[0.8500, 0.3250, 0.0980],'Alpha',0.4)
            title('Decovolution')
            [hh,icons,plots,txt] = legend({Contrast_legend,'\color[rgb]{0.8500, 0.3250, 0.0980} Deconv'});
            icons(3).FaceColor = colors{contrast};
            icons(4).FaceColor = [0.8500, 0.3250, 0.0980];
            ylim([-20 40])
            grid on
            xlabel('Time(s)')
            
            subplot(246)
            plot_distribution_prctile((1:300)/10,data_full_pixs_blocks(:,:,contrast),'Prctile',[5 95],'Color',colors{contrast},'Alpha',0.4)
            hold on
            plot_distribution_prctile((1:300)/10,out_hrfPixMP(:,:,contrast),'Prctile',[5 95],'Color',[0.4940, 0.1840, 0.5560],'Alpha',0.4)
            title('Pseudo Inverse Decovolution')
            [hh,icons,plots,txt] = legend({Contrast_legend,'\color[rgb]{0.4940, 0.1840, 0.5560}  Pseudo Deconv'});
            icons(3).FaceColor = colors{contrast};
            icons(4).FaceColor = [0.4940, 0.1840, 0.5560];
            ylim([-20 40])
            grid on
            xlabel('Time(s)')
            ylabel('\Delta\muM')
            subplot(247)
            plot_distribution_prctile((1:300)/10,data_full_pixs_blocks(:,:,contrast),'Prctile',[5 95],'Color',colors{contrast},'Alpha',0.4)
            hold on
            plot_distribution_prctile((1:300)/10,out_hrfPixDeriv(:,:,contrast),'Prctile',[5 95],'Color',[0.3010, 0.7450, 0.9330],'Alpha',0.4)
            [hh,icons,plots,txt] = legend({Contrast_legend,'\color[rgb]{0.3010, 0.7450, 0.9330}  Deriv Deconv'});
            icons(3).FaceColor = colors{contrast};
            icons(4).FaceColor = [0.3010, 0.7450, 0.9330];
            title('Derivative Deconvolution')
            ylim([-20 40])
            grid on
            xlabel('Time(s)')
            
            subplot(248)
            plot_distribution_prctile((1:300)/10,data_full_pixs_blocks(:,:,contrast),'Prctile',[5 95],'Color',colors{contrast},'Alpha',0.4)
            hold on
            plot_distribution_prctile((1:300)/10,out_gamma(:,:,contrast),'Prctile',[5 95],'Color',[0, 0.5, 0],'Alpha',0.4)
            [hh,icons,plots,txt] = legend({Contrast_legend,'\color[rgb]{0, 0.5, 0}  Gamma'});
            icons(3).FaceColor = colors{contrast};
            icons(4).FaceColor = [0, 0.5, 0];           
            ylim([-20 40])
            title('Gamma')
            grid on
            xlabel('Time(s)')
            
            sgtitle(ContName{contrast},'Color',colors{contrast},'FontSize',20,'FontWeight','bold')
        end
        
    end
    
end


















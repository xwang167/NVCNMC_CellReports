%%Example load
clear all
path='E:\RGECO\';
tmp=readtable([path, 'RGECO_stim.xlsx']);
runsInfo.samplingRate=25;
OGFS=25;
FS=10;
%run level
for row=1:size(tmp,1)
    for stim=1:3
        save_name=[path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim' ,num2str(stim) , '-NVC.mat'];


        mouse_name= [path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim', num2str(stim),'_processed.mat'];
        disp(mouse_name(1:end-4))
        load(mouse_name,'xform_jrgeco1aCorr','xform_datahb')
        try
            load([path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-stim1-dataFluor.mat'])
        catch
            load([path, num2str(tmp{row,1}) ,'-',tmp{row,2}{:},'-LandmarksandMask.mat'])
        end


        xform_jrgeco1aCorr=squeeze(xform_jrgeco1aCorr);
        isbrain=find(xform_isbrain);

        oxy=squeeze(xform_datahb(:,:,1,:));
        doxy=squeeze(xform_datahb(:,:,2,:));
        total=oxy+doxy;
        calcium=squeeze(xform_jrgeco1aCorr);

        OGsize=size(oxy);
        OGsize(end)=round(OGsize(end)*(FS/OGFS));
        data_full=nan([128^2,OGsize(end),4]);

        data_full(:,:,1)=  reshape(resample(filterData(oxy,    0.01,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
        data_full(:,:,2)=  reshape(resample(filterData(doxy ,  0.01,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
        data_full(:,:,3)=  reshape(resample(filterData(total,  0.01,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*10^6;
        data_full(:,:,4)=  reshape(resample(filterData(calcium,0.01,FS/2,OGFS),FS,OGFS,'dimension',3),128*128,[])*100;
        data_full=data_full(isbrain,:,:);
        data_full=data_full-mean(data_full,2); %mean shift
        data_full=reshape(data_full,[],300,10,4); %reshape into blocks

        clear oxy doxy total calcium xform_isbrian

        %% for whole brain
        %initializing
        Contrast={'HbO','HbR','HbT','Calcium'};
        kernel_size=30;
        pixHrfParam_BRAIN=nan(numel(isbrain),size(data_full,3),3,3);
        h_brain=nan(numel(isbrain),size(data_full,3),3,size(data_full,2));
        lam=1E-1;
        t=linspace(0,kernel_size,kernel_size*FS );

        for block=1:size(data_full,3)
            parfor pix=1:length(isbrain)
                for species=1:3

                    pixBlockTimeseries=dataNormalizer_JPC(squeeze((data_full(pix,:,block,:)))'); %get rid of the first second
                    
                    pixBlockTimeseries=(pixBlockTimeseries'.*tukeywin(size(data_full,2),.1))';

                    pixBlockTimeseries=pixBlockTimeseries-mean(pixBlockTimeseries(:,1:FS),2);
                    %gamma-fit

                    [~, pixHrfParam_BRAIN(pix,block,species,:),~,~,~] =...
                        parforEvalc(t,pixBlockTimeseries(4,:),pixBlockTimeseries(species,:));
                    %Deconvolution
                    X = convmtx(pixBlockTimeseries(4,:)',size(pixBlockTimeseries,2)); %convolution matrix
                    X=X(1:size(pixBlockTimeseries,2),1:size(pixBlockTimeseries,2)); %truncate because it pads with zeroes
                    [~,S,~]=svd(X);

                    h_brain(pix,block,species,:)=(X'*S*X+S(1,1).^2*lam*eye(size(pixBlockTimeseries,2)))\X'*S*pixBlockTimeseries(species,:)';

                end
            end
        end


        save(save_name,'pixHrfParam_BRAIN','h_brain','h_deriv_brain','h_mp_brain')

    end
end



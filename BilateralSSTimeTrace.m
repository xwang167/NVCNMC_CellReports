load('E:\RGECO\190627\190627-R5M2286-fc1_processed.mat', 'xform_datahb','xform_jrgeco1aCorr','xform_FADCorr')
load('E:\RGECO\Kenny\190627\190627-R5M2285-fc1-dataFluor.mat', 'xform_isbrain')

% GSR
HbT = squeeze(xform_datahb(:,:,1,:)+xform_datahb(:,:,2,:));
clear xform_datahb
calcium = mouse.process.gsr(xform_jrgeco1aCorr,xform_isbrain);
clear xform_jrgeco1aCorr
FAD     = mouse.process.gsr(xform_FADCorr,     xform_isbrain);
clear xform_FADCorr
HbT     = mouse.process.gsr(HbT,               xform_isbrain);

% ISA Bandpass
calcium = mouse.freq.filterData(double(calcium),0.009,0.08,25);
FAD     = mouse.freq.filterData(double(FAD),    0.009,0.08,25);
HbT     = mouse.freq.filterData(double(HbT),    0.009,0.08,25);

% Reshape
nVy =128;
nVx =128;
calcium = reshape(calcium,nVy*nVx,[]);
FAD     = reshape(FAD,nVy*nVx,[]);
HbT     = reshape(HbT,nVy*nVx,[]);


% Find seeds
refseeds=GetReferenceSeeds;
if size(refseeds,1)>3
    for n=1:2:size(refseeds,1)-1
        if xform_isbrain(refseeds(n,2),refseeds(n,1))==1 && xform_isbrain(refseeds(n+1,2),refseeds(n+1,1))==1;  %%remove 129- on y coordinate for newer data sets
            SeedsUsed(n,:)=refseeds(n,:);
            SeedsUsed(n+1,:)=refseeds(n+1,:);
        else
            SeedsUsed(n,:)=[NaN, NaN];
            SeedsUsed(n+1,:)=[NaN, NaN];
        end
    end
else
    SeedsUsed= refseeds;
end
mm=10;
mpp=mm/nVx;
seedradmm=0.25;
seedradpix=seedradmm/mpp;
P=burnseeds(SeedsUsed,seedradpix,xform_isbrain); 

% Time trace for different seeds
strace_calcium = P2strace(P,calcium,SeedsUsed); 
strace_FAD     = P2strace(P,FAD,    SeedsUsed); 
strace_HbT     = P2strace(P,HbT,    SeedsUsed);

strace_calcium_SSL = strace_calcium(4,:);
strace_calcium_SSR = strace_calcium(12,:);

strace_FAD_SSL = strace_FAD(4,:);
strace_FAD_SSR = strace_FAD(12,:);

strace_HbT_SSL = strace_HbT(4,:);
strace_HbT_SSR = strace_HbT(12,:);

figure
subplot(311)
plot((1:14999)/25,strace_calcium_SSL,'Color',[1,0.6,0])
hold on
plot((1:14999)/25,strace_calcium_SSR,'b-')

subplot(312)
plot((1:14999)/25,strace_FAD_SSL,'Color',[1,0.6,0])
hold on
plot((1:14999)/25,strace_FAD_SSR,'b-')

subplot(313)
plot((1:14999)/25,strace_HbT_SSL,'Color',[1,0.6,0])
hold on
plot((1:14999)/25,strace_HbT_SSR,'b-')
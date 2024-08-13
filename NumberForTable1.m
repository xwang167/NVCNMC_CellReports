load('191030--R5M2285-R5M2286-R5M2288-R6M2460-awake-R6M1-awake-R6M2497-awake-stim_processed_mice.mat', 'ROI_NoGSR')
load('190627-R5M2285-stim_processed.mat', 'xform_datahb_mouse_goodBlocks',...
    'xform_FADCorr_mouse_goodBlocks','xform_jrgeco1aCorr_mouse_goodBlocks')
iROI = reshape(ROI_NoGSR,1,[]);

baseline_calcium = mean(xform_jrgeco1aCorr_mouse_goodBlocks(:,:,1:125),3);
xform_jrgeco1aCorr_mouse_goodBlocks = xform_jrgeco1aCorr_mouse_goodBlocks - repmat(baseline_calcium,1,1,750);
calcium = reshape(xform_jrgeco1aCorr_mouse_goodBlocks,128*128,[]);
clear xform_jrgeco1aCorr_mouse_goodBlocks

baseline_FAD = mean(xform_FADCorr_mouse_goodBlocks(:,:,1:125),3);
xform_FADCorr_mouse_goodBlocks = xform_FADCorr_mouse_goodBlocks - repmat(baseline_FAD,1,1,750);
FAD = reshape(xform_FADCorr_mouse_goodBlocks,128*128,[]);
clear xform_FADCorr_mouse_goodBlocks

HbT = squeeze(xform_datahb_mouse_goodBlocks(:,:,1,:) + xform_datahb_mouse_goodBlocks(:,:,2,:));
clear xform_datahb_mouse_goodBlocks
baseline_HbT = mean(HbT(:,:,1:125),3);
HbT = HbT - repmat(baseline_HbT,1,1,750);
HbT = reshape(HbT,128*128,[]);
calcium = mean(calcium(iROI,:),1);
FAD = mean(FAD(iROI,:),1);
HbT = mean(HbT(iROI,:),1);
figure
yyaxis left
plot((1:750)/25,calcium*100,'m-')
hold on
plot((1:750)/25,FAD*100,'g-')
ylim([-5 5])
hold on

yyaxis right
plot((1:750)/25,HbT*1000000,'k-')
ylim([-6,6])


t90_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.9)
t10_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.1)

t90_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.9)
t10_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.1)


t90_HbT = interp1(HbT(125:147),(125:147)/25,HbT(147)*0.9)
t10_HbT = interp1(HbT(125:147),(125:147)/25,HbT(147)*0.1)


5-3.6+4.4-2.9+3.6-2.5+3.6-2.6+3.6-3.1+3.8-3.0+3.5-2.7+3.4-2.8+3.5-3.1+3.7-3.0+3.5-3+3.7-3+3.5-3.2



load('190627-R5M2286-stim_processed.mat', 'xform_datahb_mouse_goodBlocks',...
    'xform_FADCorr_mouse_goodBlocks','xform_jrgeco1aCorr_mouse_goodBlocks')
iROI = reshape(ROI_NoGSR,1,[]);

baseline_calcium = mean(xform_jrgeco1aCorr_mouse_goodBlocks(:,:,1:125),3);
xform_jrgeco1aCorr_mouse_goodBlocks = xform_jrgeco1aCorr_mouse_goodBlocks - repmat(baseline_calcium,1,1,750);
calcium = reshape(xform_jrgeco1aCorr_mouse_goodBlocks,128*128,[]);
clear xform_jrgeco1aCorr_mouse_goodBlocks

baseline_FAD = mean(xform_FADCorr_mouse_goodBlocks(:,:,1:125),3);
xform_FADCorr_mouse_goodBlocks = xform_FADCorr_mouse_goodBlocks - repmat(baseline_FAD,1,1,750);
FAD = reshape(xform_FADCorr_mouse_goodBlocks,128*128,[]);
clear xform_FADCorr_mouse_goodBlocks

HbT = squeeze(xform_datahb_mouse_goodBlocks(:,:,1,:) + xform_datahb_mouse_goodBlocks(:,:,2,:));
clear xform_datahb_mouse_goodBlocks
baseline_HbT = mean(HbT(:,:,1:125),3);
HbT = HbT - repmat(baseline_HbT,1,1,750);
HbT = reshape(HbT,128*128,[]);
calcium = mean(calcium(iROI,:),1);
FAD = mean(FAD(iROI,:),1);
HbT = mean(HbT(iROI,:),1);
figure
yyaxis left
plot((1:750)/25,calcium*100,'m-')
hold on
plot((1:750)/25,FAD*100,'g-')
ylim([-5 5])
hold on

yyaxis right
plot((1:750)/25,HbT*1000000,'k-')
ylim([-6,6])


t90_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.9)
t10_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.1)

t90_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.9)
t10_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.1)


t90_HbT = interp1(HbT(125:163),(125:163)/25,HbT(163)*0.9)
t10_HbT = interp1(HbT(125:163),(125:163)/25,HbT(163)*0.1)


(4.2-2.8+3.5-2.1+3.0-2.0+2.9-2.2+3.2-2.3+3-2+2.8-2.1+2.7-2.2+2.7-1.9+2.6-2+2.6-1.9+2.5-1.8+2.5-1.9+2.4-1.7)/14


load('L:\RGECO\190701\190701-R5M2288-stim_processed.mat', 'xform_datahb_mouse_goodBlocks',...
    'xform_FADCorr_mouse_goodBlocks','xform_jrgeco1aCorr_mouse_goodBlocks')
iROI = reshape(ROI_NoGSR,1,[]);

baseline_calcium = mean(xform_jrgeco1aCorr_mouse_goodBlocks(:,:,1:125),3);
xform_jrgeco1aCorr_mouse_goodBlocks = xform_jrgeco1aCorr_mouse_goodBlocks - repmat(baseline_calcium,1,1,750);
calcium = reshape(xform_jrgeco1aCorr_mouse_goodBlocks,128*128,[]);
clear xform_jrgeco1aCorr_mouse_goodBlocks

baseline_FAD = mean(xform_FADCorr_mouse_goodBlocks(:,:,1:125),3);
xform_FADCorr_mouse_goodBlocks = xform_FADCorr_mouse_goodBlocks - repmat(baseline_FAD,1,1,750);
FAD = reshape(xform_FADCorr_mouse_goodBlocks,128*128,[]);
clear xform_FADCorr_mouse_goodBlocks

HbT = squeeze(xform_datahb_mouse_goodBlocks(:,:,1,:) + xform_datahb_mouse_goodBlocks(:,:,2,:));
clear xform_datahb_mouse_goodBlocks
baseline_HbT = mean(HbT(:,:,1:125),3);
HbT = HbT - repmat(baseline_HbT,1,1,750);
HbT = reshape(HbT,128*128,[]);
calcium = mean(calcium(iROI,:),1);
FAD = mean(FAD(iROI,:),1);
HbT = mean(HbT(iROI,:),1);
figure
yyaxis left
plot((1:750)/25,calcium*100,'m-')
hold on
plot((1:750)/25,FAD*100,'g-')
ylim([-5 5])
hold on

yyaxis right
plot((1:750)/25,HbT*1000000,'k-')
ylim([-6,6])


t90_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.9)
t10_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.1)

t90_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.9)
t10_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.1)


t90_HbT = interp1(HbT(125:147),(125:147)/25,HbT(147)*0.9)
t10_HbT = interp1(HbT(125:147),(125:147)/25,HbT(147)*0.1)


(3.6-2.7+2.9-1.8+2.4-1.6+2.6-1.9+2.8-2.1+2.9-2.3+3.1-2.5+3.1-2.6+3.3-2.6+3.3-2.8+3.3-2.8+3.3-2.6+3.3-2.7+3.3-2.7)/14

load('L:\RGECO\191028\191028-R6M2460-awake-stim_processed.mat', 'xform_datahb_mouse_goodBlocks',...
    'xform_FADCorr_mouse_goodBlocks','xform_jrgeco1aCorr_mouse_goodBlocks')
iROI = reshape(ROI_NoGSR,1,[]);

baseline_calcium = mean(xform_jrgeco1aCorr_mouse_goodBlocks(:,:,1:125),3);
xform_jrgeco1aCorr_mouse_goodBlocks = xform_jrgeco1aCorr_mouse_goodBlocks - repmat(baseline_calcium,1,1,750);
calcium = reshape(xform_jrgeco1aCorr_mouse_goodBlocks,128*128,[]);
clear xform_jrgeco1aCorr_mouse_goodBlocks

baseline_FAD = mean(xform_FADCorr_mouse_goodBlocks(:,:,1:125),3);
xform_FADCorr_mouse_goodBlocks = xform_FADCorr_mouse_goodBlocks - repmat(baseline_FAD,1,1,750);
FAD = reshape(xform_FADCorr_mouse_goodBlocks,128*128,[]);
clear xform_FADCorr_mouse_goodBlocks

HbT = squeeze(xform_datahb_mouse_goodBlocks(:,:,1,:) + xform_datahb_mouse_goodBlocks(:,:,2,:));
clear xform_datahb_mouse_goodBlocks
baseline_HbT = mean(HbT(:,:,1:125),3);
HbT = HbT - repmat(baseline_HbT,1,1,750);
HbT = reshape(HbT,128*128,[]);
calcium = mean(calcium(iROI,:),1);
FAD = mean(FAD(iROI,:),1);
HbT = mean(HbT(iROI,:),1);
figure
yyaxis left
plot((1:750)/25,calcium*100,'m-')
hold on
plot((1:750)/25,FAD*100,'g-')
ylim([-5 5])
hold on

yyaxis right
plot((1:750)/25,HbT*1000000,'k-')
ylim([-6,6])


t90_calcium = interp1(calcium(125:129),(125:129)/25,calcium(129)*0.9)
t10_calcium = interp1(calcium(125:129),(125:129)/25,calcium(129)*0.1)

t90_FAD = interp1(FAD(125:135),(125:135)/25,FAD(135)*0.9)
t10_FAD = interp1(FAD(125:135),(125:135)/25,FAD(135)*0.1)


t90_HbT = interp1(HbT(125:160),(125:160)/25,HbT(160)*0.9)
t10_HbT = interp1(HbT(125:160),(125:160)/25,HbT(160)*0.1)

(3.5-1.8+2.8-1.5+2.7-1.4+2.8-1.8+2.9-2.0+3.0-2.2+7.2-2+2.7-1.8+2.7-1.8+2.6-1.8+2.5-1.8+2.5-1.6+2.4-1.8+2.5-1.8)/14


load('L:\RGECO\191028\191028-R6M1-awake-stim_processed.mat', 'xform_datahb_mouse_goodBlocks',...
    'xform_FADCorr_mouse_goodBlocks','xform_jrgeco1aCorr_mouse_goodBlocks')
iROI = reshape(ROI_NoGSR,1,[]);

baseline_calcium = mean(xform_jrgeco1aCorr_mouse_goodBlocks(:,:,1:125),3);
xform_jrgeco1aCorr_mouse_goodBlocks = xform_jrgeco1aCorr_mouse_goodBlocks - repmat(baseline_calcium,1,1,750);
calcium = reshape(xform_jrgeco1aCorr_mouse_goodBlocks,128*128,[]);
clear xform_jrgeco1aCorr_mouse_goodBlocks

baseline_FAD = mean(xform_FADCorr_mouse_goodBlocks(:,:,1:125),3);
xform_FADCorr_mouse_goodBlocks = xform_FADCorr_mouse_goodBlocks - repmat(baseline_FAD,1,1,750);
FAD = reshape(xform_FADCorr_mouse_goodBlocks,128*128,[]);
clear xform_FADCorr_mouse_goodBlocks

HbT = squeeze(xform_datahb_mouse_goodBlocks(:,:,1,:) + xform_datahb_mouse_goodBlocks(:,:,2,:));
clear xform_datahb_mouse_goodBlocks
baseline_HbT = mean(HbT(:,:,1:125),3);
HbT = HbT - repmat(baseline_HbT,1,1,750);
HbT = reshape(HbT,128*128,[]);
calcium = mean(calcium(iROI,:),1);
FAD = mean(FAD(iROI,:),1);
HbT = mean(HbT(iROI,:),1);
figure
yyaxis left
plot((1:750)/25,calcium*100,'m-')
hold on
plot((1:750)/25,FAD*100,'g-')
ylim([-5 5])
hold on

yyaxis right
plot((1:750)/25,HbT*1000000,'k-')
ylim([-8,8])


t90_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.9)
t10_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.1)

t90_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.9)
t10_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.1)


t90_HbT = interp1(HbT(125:166),(125:166)/25,HbT(166)*0.9)
t10_HbT = interp1(HbT(125:166),(125:166)/25,HbT(166)*0.1)
(4.6-2.7+3.7-2.1+3.5-2.2+3.8-2.6+4.1-2.8+4.2-2.7+4-2.8+3.8-2.7+3.9-2.5+3.7-2.6+3.7-2.5+3.8-2.4+3.7-2.5+3.6-2.4)/14



load('L:\RGECO\191030\191030-R6M2497-awake-stim_processed.mat', 'xform_datahb_mouse_goodBlocks',...
    'xform_FADCorr_mouse_goodBlocks','xform_jrgeco1aCorr_mouse_goodBlocks')
iROI = reshape(ROI_NoGSR,1,[]);

baseline_calcium = mean(xform_jrgeco1aCorr_mouse_goodBlocks(:,:,1:125),3);
xform_jrgeco1aCorr_mouse_goodBlocks = xform_jrgeco1aCorr_mouse_goodBlocks - repmat(baseline_calcium,1,1,750);
calcium = reshape(xform_jrgeco1aCorr_mouse_goodBlocks,128*128,[]);
clear xform_jrgeco1aCorr_mouse_goodBlocks

baseline_FAD = mean(xform_FADCorr_mouse_goodBlocks(:,:,1:125),3);
xform_FADCorr_mouse_goodBlocks = xform_FADCorr_mouse_goodBlocks - repmat(baseline_FAD,1,1,750);
FAD = reshape(xform_FADCorr_mouse_goodBlocks,128*128,[]);
clear xform_FADCorr_mouse_goodBlocks

HbT = squeeze(xform_datahb_mouse_goodBlocks(:,:,1,:) + xform_datahb_mouse_goodBlocks(:,:,2,:));
clear xform_datahb_mouse_goodBlocks
baseline_HbT = mean(HbT(:,:,1:125),3);
HbT = HbT - repmat(baseline_HbT,1,1,750);
HbT = reshape(HbT,128*128,[]);
calcium = mean(calcium(iROI,:),1);
FAD = mean(FAD(iROI,:),1);
HbT = mean(HbT(iROI,:),1);
figure
yyaxis left
plot((1:750)/25,calcium*100,'m-')
hold on
plot((1:750)/25,FAD*100,'g-')
ylim([-5 5])
hold on

yyaxis right
plot((1:750)/25,HbT*1000000,'k-')
ylim([-8,8])


t90_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.9)
t10_calcium = interp1(calcium(125:130),(125:130)/25,calcium(130)*0.1)

t90_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.9)
t10_FAD = interp1(FAD(125:147),(125:147)/25,FAD(147)*0.1)


t90_HbT = interp1(HbT(125:166),(125:166)/25,HbT(166)*0.9)
t10_HbT = interp1(HbT(125:166),(125:166)/25,HbT(166)*0.1)
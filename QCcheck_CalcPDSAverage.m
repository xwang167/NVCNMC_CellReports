function [hz, powerdata_averaged] = QCcheck_CalcPDSAverage(data,framerate,xform_isbrain)
nVy = size(data,1);
nVx = size(data,2);
load('noVasculatureMask.mat')
mask = logical(xform_isbrain.*(double(leftMask)+double(rightMask)));
ibi = find(mask ==1);
data(isnan(data)) = 0;
data(isinf(data)) = 0;
data2 = reshape(data,nVx*nVy,[]);
mdata = mean(data2(ibi,:),1);

[powerdata_averaged,hz] = pwelch(mdata,[],[],[],framerate);

function [hz, powerdata] = QCcheck_CalcPDS(data,framerate,xform_isbrain)
nVy = size(data,1);
nVx = size(data,2);
load('noVasculatureMask.mat')
mask = logical(xform_isbrain.*(double(leftMask)+double(rightMask)));
ibi = find(mask ==1);
data(isnan(data)) = 0;
data(isinf(data)) = 0;
data = transpose(reshape(data,nVx*nVy,[]));
[Pxx,hz] = pwelch(data,[],[],[],framerate);
Pxx = Pxx';

powerdata = mean(Pxx(ibi,:),1);
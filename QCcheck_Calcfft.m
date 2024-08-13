function fdata = QCcheck_Calcfft(data,xform_isbrain)
nVy = size(data,1);
nVx = size(data,2);

ibi = find(xform_isbrain ==1);
data(isnan(data)) = 0;
data = transpose(reshape(data,nVx*nVy,[]));
fdata = abs(fft(data));
fdata = fdata';
fdata = mean(fdata(ibi,:),1);

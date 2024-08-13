function powerMap = QCcheck_CalcPowerMap(data,framerate,xform_isbrain,freqRange)
nVy = size(data,1);
nVx = size(data,2);

ibi = find(xform_isbrain ==1);
data(isnan(data)) = 0;
data = transpose(reshape(data,nVx*nVy,[]));
[Pxx,hz] = pwelch(data,[],[],[],framerate);
Pxx = Pxx';
Pxx = reshape(Pxx,[],size(Pxx,3));
Pxx = reshape(Pxx,nVy,nVx,[]);
 [~,startLoc]=min(abs(hz-freqRange(1)));
 [~,endLoc]=min(abs(hz-freqRange(2)));
 powerMap = zeros
for kk = 1:nVy
    for ll=1:nVx
        powerMap(kk,ll) = (hz(2)-hz(1))*sum(Pxx(kk,ll,startLoc: endLoc))/(endLoc-startLoc);
    end
end


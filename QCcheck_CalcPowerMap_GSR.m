function powerMap = QCcheck_CalcPowerMap_GSR(data,framerate,freqRange)
nVy = size(data,1);
nVx = size(data,2);
data(isnan(data)) = 0;
load('D:\OIS_Process\noVasculatureMask.mat')
mask = leftMask+rightMask;
data = mouse.process.gsr(data,mask);
data = transpose(reshape(data,nVx*nVy,[]));
[Pxx,hz] = pwelch(data,[],[],[],framerate);
Pxx = Pxx';
Pxx = reshape(Pxx,[],size(Pxx,3));
Pxx = reshape(Pxx,nVy,nVx,[]);
 [~,startLoc]=min(abs(hz-freqRange(1)));
 [~,endLoc]=min(abs(hz-freqRange(2)));
 powerMap = zeros(nVy,nVx);
for kk = 1:nVy
    for ll=1:nVx
        powerMap(kk,ll) = (hz(2)-hz(1))*sum(Pxx(kk,ll,startLoc: endLoc))/(endLoc-startLoc);
    end
end

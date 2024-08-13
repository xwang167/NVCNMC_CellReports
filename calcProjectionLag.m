function [lagTime_projection,lagAmp_projection] = calcProjectionLag(data,minFreq,maxFreq,fs,edgeLen,validRange,corrThr)
load('noVasculatureMask.mat')

%% resize to half
data = imresize(data,0.5);
leftMask = imresize(leftMask,0.5);
rightMask = imresize(rightMask,0.5);
mask = leftMask+rightMask;
for ii = 1:length(data)
    data(:,:,ii) = data(:,:,ii).*double(mask);
end
data = mouse.freq.filterData(double(data),minFreq,maxFreq,fs);
if maxFreq == 4
    outFreq = 10;
else
    outFreq = 1;
end
data = resampledata(data,fs,outFreq,10^-5);
validRange = validRange*outFreq/fs;
mask = logical(mask);
nVx= size(mask,2);
nVy = size(mask,1);
mask = reshape(mask,[],1);
data = reshape(data,[],size(data,3));
lagTimeProjectionMatrix = zeros(size(data,1),size(data,1));
lagAmpProjectionMatrix = zeros(size(data,1),size(data,1));
for ii = 1:size(data,1)
    for jj = 1:size(data,1)
        if mask(ii)==1 && mask(jj)==1
            [lagTimeProjectionMatrix(ii,jj),lagAmpProjectionMatrix(ii,jj)] = mouse.conn.findLag(...
                data(ii,:),data(jj,:),true,true,validRange,edgeLen,corrThr);
            
        else
            lagTimeProjectionMatrix(ii,jj) = nan;
            lagAmpProjectionMatrix(ii,jj) = nan;
        end
    end
end
clear data
lagTime_projection = nanmean(lagTimeProjectionMatrix,2);
lagAmp_projection = nanmean(lagAmpProjectionMatrix,2);

lagTime_projection = reshape(lagTime_projection,nVy,nVx);
lagAmp_projection = reshape(lagAmp_projection,nVy,nVx);
lagTime_projection = lagTime_projection./outFreq;
end
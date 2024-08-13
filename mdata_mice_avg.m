close all;clear all;clc
import mouse.*
excelFile = "X:\RGECO\DataBase_Xiaodan_1.xlsx";
excelRows = [ 181 183 185 228 232 236 202 195 204 230 234 240];
runs =1:3;
%% percentage noise for each run

mdata_mice = [];
for excelRow = excelRows
    [~, ~, excelRaw]=xlsread(excelFile,1, ['A',num2str(excelRow),':V',num2str(excelRow)]);
    recDate = excelRaw{1}; recDate = string(recDate);
    mouseName = excelRaw{2}; mouseName = string(mouseName);
    saveDir = excelRaw{4}; saveDir = fullfile(string(saveDir),recDate);
    sessionType = excelRaw{6}; sessionType = sessionType(3:end-2);
    sessionInfo.darkFrameNum = excelRaw{15};
    sessionInfo.mouseType = excelRaw{17};
    systemType =excelRaw{5};
    for n = runs
        rawName = strcat(recDate,'-',mouseName,'-',sessionType,num2str(n),'.mat');
        disp('loading raw data')
        load(fullfile(saveDir,rawName),'mdata')
        mdata_mice = cat(2,mdata_mice,mean(mdata,2));
    end
end

mdata_mice = mean(mdata_mice,2);
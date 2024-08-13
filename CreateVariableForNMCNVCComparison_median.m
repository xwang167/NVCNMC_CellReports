saveName = "D:\XiaodanPaperData\cat\deconvolution_allRegions.mat";
load(saveName, 'HRF_mice_awake_allRegions', 'r_HRF_mice_awake_allRegions', 'MRF_mice_awake_allRegions', 'r_MRF_mice_awake_allRegions', 'HRF_mice_anes_allRegions', 'r_HRF_mice_anes_allRegions', 'MRF_mice_anes_allRegions', 'r_MRF_mice_anes_allRegions')
load(saveName, 'A_HRF_mice_awake_allRegions', 'T_HRF_mice_awake_allRegions', 'W_HRF_mice_awake_allRegions', 'A_MRF_mice_awake_allRegions', 'T_MRF_mice_awake_allRegions', 'W_MRF_mice_awake_allRegions', 'A_HRF_mice_anes_allRegions', 'T_HRF_mice_anes_allRegions', 'W_HRF_mice_anes_allRegions', 'A_MRF_mice_anes_allRegions', 'T_MRF_mice_anes_allRegions', 'W_MRF_mice_anes_allRegions')
% Exclude T W A that has T bigger than 0.2 for NMC under awake condition

numMice = eval(strcat('length(excelRows_',condition{1},');'));
for region = 1:50
    for mouseInd =1:numMice
        if T_MRF_mice_awake_allRegions(mouseInd,region)>0.2
            T_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            W_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            A_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
            r_MRF_mice_awake_allRegions(mouseInd,region) =NaN;
        end
    end
end


for condition = {'awake','anes'}
    for h = {'HRF','MRF'}
        for var = {'T','W','A','r'}
              eval(strcat(var{1},'_',h{1},'_mice_',condition{1},'_exclude = ',var{1},'_',h{1},'_mice_',condition{1},'_allRegions(:,[3,4,6:25,28,29,31:50]);'));
              eval(strcat('save(',char(39),saveName,char(39),',',...
                   char(39),var{1},'_',h{1},'_mice_',condition{1},'_exclude',char(39),',',...
                   char(39),'-append',char(39),')'))
        end
    end
end

ii = 1; 
for jj = [3,4,6:25,28,29,31:50]
    label_region{ii} = parcelnames{jj};
    ii = ii+1;
end
save(saveName,'label_region','-append')

%% Time to peak
T_HRF_mice_awake_exclude = T_HRF_mice_awake_exclude';
T_MRF_mice_awake_exclude = T_MRF_mice_awake_exclude';
T_HRF_mice_anes_exclude = T_HRF_mice_anes_exclude';
T_MRF_mice_anes_exclude = T_MRF_mice_anes_exclude';

% median
T_HRF_mice_awake_exclude_median = nanmedian(T_HRF_mice_awake_exclude,2);
T_MRF_mice_awake_exclude_median = nanmedian(T_MRF_mice_awake_exclude,2);

T_HRF_mice_anes_exclude_median  = nanmedian(T_HRF_mice_anes_exclude,2);
T_MRF_mice_anes_exclude_median  = nanmedian(T_MRF_mice_anes_exclude,2);

% sort
[T_HRF_mice_awake_exclude_median_sort,I_T_awake] = sort(T_HRF_mice_awake_exclude_median);
T_MRF_mice_awake_exclude_median_sort = T_MRF_mice_awake_exclude_median(I_T_awake);
label_region_T_awake = label_region(I_T_awake);
r_T_awake_median = corr(T_HRF_mice_awake_exclude_median_sort,T_MRF_mice_awake_exclude_median_sort);

[T_HRF_mice_anes_exclude_median_sort,I_T_anes] = sort(T_HRF_mice_anes_exclude_median);
T_MRF_mice_anes_exclude_median_sort = T_MRF_mice_anes_exclude_median(I_T_anes);
label_region_T_anes = label_region(I_T_anes);
r_T_anes_median = corr(T_HRF_mice_anes_exclude_median_sort,T_MRF_mice_anes_exclude_median_sort);

% scatter plot
% Time to Peak
figure('units','normalized','outerposition',[0 0 1 1])
subplot(211)
yyaxis left
scatter(1:44,T_HRF_mice_awake_exclude_median_sort,'filled')
ylabel('NVC T(s)')
hold on
yyaxis right
scatter(1:44,T_MRF_mice_awake_exclude_median_sort,'filled','d')
ylabel('NMC T(s)')
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_T_awake))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
title(['Awake, r = ',num2str(r_T_awake_median)])
subplot(212)
yyaxis left
scatter(1:44,T_HRF_mice_anes_exclude_median_sort,'filled')
ylabel('NVC T(s)')
hold on
yyaxis right
scatter(1:44,T_MRF_mice_anes_exclude_median_sort,'filled','d')
ylabel('NMC T(s)')
title(['Anesthetized, r = ',num2str(r_T_anes_median)])
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_T_anes))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)

sgtitle('Time to Peak Correlation between NVC and NMC')

%% Width
W_HRF_mice_awake_exclude = W_HRF_mice_awake_exclude';
W_MRF_mice_awake_exclude = W_MRF_mice_awake_exclude';
W_HRF_mice_anes_exclude = W_HRF_mice_anes_exclude';
W_MRF_mice_anes_exclude = W_MRF_mice_anes_exclude';

% median
W_HRF_mice_awake_exclude_median = nanmedian(W_HRF_mice_awake_exclude,2);
W_MRF_mice_awake_exclude_median = nanmedian(W_MRF_mice_awake_exclude,2);

W_HRF_mice_anes_exclude_median  = nanmedian(W_HRF_mice_anes_exclude,2);
W_MRF_mice_anes_exclude_median  = nanmedian(W_MRF_mice_anes_exclude,2);

% sort
[W_HRF_mice_awake_exclude_median_sort,I_W_awake] = sort(W_HRF_mice_awake_exclude_median);
W_MRF_mice_awake_exclude_median_sort = W_MRF_mice_awake_exclude_median(I_W_awake);
label_region_W_awake = label_region(I_W_awake);
r_W_awake_median = corr(W_HRF_mice_awake_exclude_median_sort,W_MRF_mice_awake_exclude_median_sort);

[W_HRF_mice_anes_exclude_median_sort,I_W_anes] = sort(W_HRF_mice_anes_exclude_median);
W_MRF_mice_anes_exclude_median_sort = W_MRF_mice_anes_exclude_median(I_W_anes);
label_region_W_anes = label_region(I_W_anes);
r_W_anes_median = corr(W_HRF_mice_anes_exclude_median_sort,W_MRF_mice_anes_exclude_median_sort);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(211)
yyaxis left
scatter(1:44,W_HRF_mice_awake_exclude_median_sort,'filled')
ylabel('NVC W(s)')
hold on
yyaxis right
scatter(1:44,W_MRF_mice_awake_exclude_median_sort,'filled','d')
ylabel('NMC W(s)')
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_W_awake))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
title(['Awake, r = ',num2str(r_W_awake_median)])

subplot(212)
yyaxis left
scatter(1:44,W_HRF_mice_anes_exclude_median_sort,'filled')
ylabel('NVC W(s)')
hold on
yyaxis right
scatter(1:44,W_MRF_mice_anes_exclude_median_sort,'filled','d')
ylabel('NMC W(s)')
title(['Anesthetized, r = ',num2str(r_W_anes_median)])
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_W_anes))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)

sgtitle('Width Correlation between NVC and NMC')

%% Amplitude
A_HRF_mice_awake_exclude = A_HRF_mice_awake_exclude';
A_MRF_mice_awake_exclude = A_MRF_mice_awake_exclude';
A_HRF_mice_anes_exclude = A_HRF_mice_anes_exclude';
A_MRF_mice_anes_exclude = A_MRF_mice_anes_exclude';

% median
A_HRF_mice_awake_exclude_median = nanmedian(A_HRF_mice_awake_exclude,2);
A_MRF_mice_awake_exclude_median = nanmedian(A_MRF_mice_awake_exclude,2);

A_HRF_mice_anes_exclude_median  = nanmedian(A_HRF_mice_anes_exclude,2);
A_MRF_mice_anes_exclude_median  = nanmedian(A_MRF_mice_anes_exclude,2);

% sort
[A_HRF_mice_awake_exclude_median_sort,I_A_awake] = sort(A_HRF_mice_awake_exclude_median);
A_MRF_mice_awake_exclude_median_sort = A_MRF_mice_awake_exclude_median(I_A_awake);
label_region_A_awake = label_region(I_A_awake);
r_A_awake_median = corr(A_HRF_mice_awake_exclude_median_sort,A_MRF_mice_awake_exclude_median_sort);

[A_HRF_mice_anes_exclude_median_sort,I_A_anes] = sort(A_HRF_mice_anes_exclude_median);
A_MRF_mice_anes_exclude_median_sort = A_MRF_mice_anes_exclude_median(I_A_anes);
label_region_A_anes = label_region(I_A_anes);
r_A_anes_median = corr(A_HRF_mice_anes_exclude_median_sort,A_MRF_mice_anes_exclude_median_sort);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(211)
yyaxis left
scatter(1:44,A_HRF_mice_awake_exclude_median_sort,'filled')
ylabel('NVC A')
hold on
yyaxis right
scatter(1:44,A_MRF_mice_awake_exclude_median_sort,'filled','d')
ylabel('NMC A')
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_A_awake))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
title(['Awake, r = ',num2str(r_A_awake_median)])

subplot(212)
yyaxis left
scatter(1:44,A_HRF_mice_anes_exclude_median_sort,'filled')
ylabel('NVC A')
hold on
yyaxis right
scatter(1:44,A_MRF_mice_anes_exclude_median_sort,'filled','d')
ylabel('NMC A')
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_A_anes))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
title(['Anesthetized, r = ',num2str(r_A_anes_median)])

sgtitle('Amplitude Correlation between NVC and NMC')

%% Correlation Coefficient
r_HRF_mice_awake_exclude = r_HRF_mice_awake_exclude';
r_MRF_mice_awake_exclude = r_MRF_mice_awake_exclude';
r_HRF_mice_anes_exclude = r_HRF_mice_anes_exclude';
r_MRF_mice_anes_exclude = r_MRF_mice_anes_exclude';

% median
r_HRF_mice_awake_exclude_median = nanmedian(r_HRF_mice_awake_exclude,2);
r_MRF_mice_awake_exclude_median = nanmedian(r_MRF_mice_awake_exclude,2);

r_HRF_mice_anes_exclude_median  = nanmedian(r_HRF_mice_anes_exclude,2);
r_MRF_mice_anes_exclude_median  = nanmedian(r_MRF_mice_anes_exclude,2);

% sort
[r_HRF_mice_awake_exclude_median_sort,I_r_awake] = sort(r_HRF_mice_awake_exclude_median);
r_MRF_mice_awake_exclude_median_sort = r_MRF_mice_awake_exclude_median(I_r_awake);
label_region_r_awake = label_region(I_r_awake);
r_r_awake_median = corr(r_HRF_mice_awake_exclude_median_sort,r_MRF_mice_awake_exclude_median_sort);

[r_HRF_mice_anes_exclude_median_sort,I_r_anes] = sort(r_HRF_mice_anes_exclude_median);
r_MRF_mice_anes_exclude_median_sort = r_MRF_mice_anes_exclude_median(I_r_anes);
label_region_r_anes = label_region(I_r_anes);
r_r_anes_median = corr(r_HRF_mice_anes_exclude_median_sort,r_MRF_mice_anes_exclude_median_sort);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(211)
yyaxis left
scatter(1:44,r_HRF_mice_awake_exclude_median_sort,'filled')
ylabel('NVC r')
hold on
yyaxis right
scatter(1:44,r_MRF_mice_awake_exclude_median_sort,'filled','d')
ylabel('NMC r')
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_r_awake))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
title(['Awake, r = ',num2str(r_r_awake_median)])

subplot(212)
yyaxis left
scatter(1:44,r_HRF_mice_anes_exclude_median_sort,'filled')
ylabel('NVC r')
hold on
yyaxis right
scatter(1:44,r_MRF_mice_anes_exclude_median_sort,'filled','d')
ylabel('NMC r')
xlabel('Region')
xticks([1:44])
xtickangle(0)
xticklabels(num2str(I_r_anes))
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
title(['Anesthetized, r = ',num2str(r_r_anes_median)])

sgtitle('Correlation Coefficient Correlation between NVC and NMC')
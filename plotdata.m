% plot confusion matrices from python code 
activities = {'Sit','Stairs Dw','Stairs Up','Stand','Walk'};
thres = 0.6; %for text color
%% Healthy 
%load cmats for 
load ./PyCode/cmatHealthy.mat

S1 = double(S1);
S2 = double(S2);
S5 = double(S5);
S6 = double(S6);
S8 = double(S8);
S11 = double(S11);
S14 = double(S14);
S15 = double(S15);
S16 = double(S16);
S19 = double(S19);

results = [];
results(1).cmat = S1;     
results(2).cmat = S2;
results(3).cmat = S5;     
results(4).cmat = S6;
results(5).cmat = S8;     
results(6).cmat = S11;
results(7).cmat = S14;     
results(8).cmat = S15;
results(9).cmat = S16;     
results(10).cmat = S19;


%plot confusion matrix (sum across all subjects)
cmat_all = zeros(5,5);
for s = 1:length(results)
    cmat_all = results(s).cmat + cmat_all;
end
correctones = sum(cmat_all,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat_all = cmat_all./correctones

figure, 
imagesc(cmat_all); 
colorbar
colormap(gray)
colormap(flipud(colormap))
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Healthy model','FontSize',14), hold on
%add text
for i = 1:length(activities)
    for j = 1:length(activities)
        if cmat_all(i,j) > thres
            col = [1 1 1];
        else
            col = [0 0 0];
        end
        text(i-0.2,j,sprintf('%.3f',cmat_all(j,i)),'FontSize',14,'FontWeight','bold','Color',col);
    end
end
saveas(gcf,'cmatHealthy.jpg')


%% Global Patients 
clear results
%load cmats
load ./PyCode/cmatISpec.mat

S1 = double(S1);
S2 = double(S2);
S5 = double(S5);
S6 = double(S6);
S8 = double(S8);
S11 = double(S11);
S14 = double(S14);
S15 = double(S15);
S16 = double(S16);
S19 = double(S19);

results = [];
results(1).cmat = S1;     
results(2).cmat = S2;
results(3).cmat = S5;     
results(4).cmat = S6;
results(5).cmat = S8;     
results(6).cmat = S11;
results(7).cmat = S14;     
results(8).cmat = S15;
results(9).cmat = S16;     
results(10).cmat = S19;


%plot confusion matrix (sum across all subjects)
cmat_all = zeros(5,5);
for s = 1:length(results)
    cmat_all = results(s).cmat + cmat_all;
end
correctones = sum(cmat_all,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat_all = cmat_all./correctones

figure, 
imagesc(cmat_all); 
colorbar
colormap(gray)
colormap(flipud(colormap))
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Impairment Specific model','FontSize',14), hold on
%add text
for i = 1:length(activities)
    for j = 1:length(activities)
        if cmat_all(i,j) > thres
            col = [1 1 1];
        else
            col = [0 0 0];
        end
        text(i-0.2,j,sprintf('%.3f',cmat_all(j,i)),'FontSize',14,'FontWeight','bold','Color',col);
    end
end
saveas(gcf,'cmatISpec.jpg')

%% Patient specific
clear results
%load cmats
load ./PyCode/cmatPSpec.mat

S1 = double(S1);
S2 = double(S2);
S5 = double(S5);
S6 = double(S6);
S8 = double(S8);
S11 = double(S11);
S14 = double(S14);
S15 = double(S15);
S16 = double(S16);
S19 = double(S19);

results = [];
results(1).cmat = S1;     
results(2).cmat = S2;
results(3).cmat = S5;     
results(4).cmat = S6;
results(5).cmat = S8;     
results(6).cmat = S11;
results(7).cmat = S14;     
results(8).cmat = S15;
results(9).cmat = S16;     
results(10).cmat = S19;


%plot confusion matrix (sum across all subjects)
cmat_all = zeros(5,5);
for s = 1:length(results)
    cmat_all = results(s).cmat + cmat_all;
end
correctones = sum(cmat_all,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat_all = cmat_all./correctones

figure, 
imagesc(cmat_all); 
colorbar
colormap(gray)
colormap(flipud(colormap))
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Patient Specific model','FontSize',14), hold on
%add text
for i = 1:length(activities)
    for j = 1:length(activities)
        if cmat_all(i,j) > thres
            col = [1 1 1];
        else
            col = [0 0 0];
        end
        text(i-0.2,j,sprintf('%.3f',cmat_all(j,i)),'FontSize',14,'FontWeight','bold','Color',col);
    end
end
saveas(gcf,'cmatPSpec.jpg')

%% Device Specific 
clear results
%load cmats
load ./PyCode/cmatDSpec.mat

S1 = double(S1);
S2 = double(S2);
S5 = double(S5);
S6 = double(S6);
S8 = double(S8);
S11 = double(S11);
S14 = double(S14);
S15 = double(S15);
S16 = double(S16);
S19 = double(S19);

results = [];
results(1).cmat = S1;     
results(2).cmat = S2;
results(3).cmat = S5;     
results(4).cmat = S6;
results(5).cmat = S8;     
results(6).cmat = S11;
results(7).cmat = S14;     
results(8).cmat = S15;
results(9).cmat = S16;     
results(10).cmat = S19;


%plot confusion matrix (sum across all subjects)
cmat_all = zeros(5,5);
for s = 1:length(results)
    cmat_all = results(s).cmat + cmat_all;
end
correctones = sum(cmat_all,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat_all = cmat_all./correctones

figure, 
imagesc(cmat_all); 
colorbar
colormap(gray)
colormap(flipud(colormap))
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Device Specific model','FontSize',14), hold on
%add text
for i = 1:length(activities)
    for j = 1:length(activities)
        if cmat_all(i,j) > thres
            col = [1 1 1];
        else
            col = [0 0 0];
        end
        text(i-0.2,j,sprintf('%.3f',cmat_all(j,i)),'FontSize',14,'FontWeight','bold','Color',col);
    end
end
saveas(gcf,'cmatDSpec.jpg')

%% Plot Global models simulations
figure
%Healthy
mat_BACC = csvread('./PyCode/results_GlobalH.csv');
%Plot results
hold on
N = size(mat_BACC,2); %number of patients
x = 1:N;
avg = mean(mat_BACC,1); %average
%sem = std(mat_BACC,[],1)./sqrt(size(mat_BACC,1)); %standard error of the mean
%stddev = std(mat_BACC,[],1); %standard error of the mean
%errorbar(1:N,avg,sem,'ko-','LineWidth',2,'markerfacecolor','k');
mu = zeros(1,size(mat_BACC,2)); %stores bootsrapped mean
CI_boot = zeros(2,size(mat_BACC,2)); %stores upper and lower CI bounds
CI_bars = zeros(2,size(mat_BACC,2)); %CI relative to the mean)
Nboot = 1000;
for b = 1:size(mat_BACC,2)
    bootstat1 = bootstrp(Nboot,@mean,mat_BACC(:,b));
    mu(b) = mean(bootstat1);
    CI_boot(:,b) = bootci(Nboot,{@mean,mat_BACC(:,b)},'alpha',0.05);
    CI_bars(:,b) = abs(CI_boot(:,b) - mu(b));
end
h1 = shadedErrorBar(1:N,mu,flipud(CI_bars),{'b-o','markerfacecolor','b'},1);

%Patients
mat_BACC = csvread('./PyCode/results_GlobalP.csv');
hold on
N = size(mat_BACC,2); %number of patients
x = 1:N;
avg = mean(mat_BACC,1); %average
%sem = std(mat_BACC,[],1)./sqrt(size(mat_BACC,1)); %standard error of the mean
%stddev = std(mat_BACC,[],1); %standard error of the mean
%errorbar(1:N,avg,sem,'ko-','LineWidth',2,'markerfacecolor','k');
mu = zeros(1,size(mat_BACC,2)); %stores bootsrapped mean
CI_boot = zeros(2,size(mat_BACC,2)); %stores upper and lower CI bounds
CI_bars = zeros(2,size(mat_BACC,2)); %CI relative to the mean)
Nboot = 1000;
for b = 1:size(mat_BACC,2)
    bootstat1 = bootstrp(Nboot,@mean,mat_BACC(:,b));
    mu(b) = mean(bootstat1);
    CI_boot(:,b) = bootci(Nboot,{@mean,mat_BACC(:,b)},'alpha',0.05);
    CI_bars(:,b) = abs(CI_boot(:,b) - mu(b));
end
h4 = shadedErrorBar(1:N,mu,flipud(CI_bars),{'-o','Color',[0 0.5 0],'MarkerFaceColor',[0 0.5 0]},1);
saveas(gcf,'globalmodelsims.jpg')

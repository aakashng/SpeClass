%plot distribution of error per class for each model
%could be modified by including the errors in each session
%% Healthy 
load('results_healthy.mat')
activities = {'Sit','Stairs Dw','Stairs Up','Stand','Walk'};

acc_model = nan(length(results_healthy),5);
for p = 1:length(results_healthy)
    acc_c = results_healthy(p).acc_c';
    if results_healthy(p).n_act == 5
        acc_model(p,:) = acc_c;
    else
        acc_model(p,[1 4 5]) = acc_c;
    end
end
    
acc_model    
figure, hold on, title('Healthy model','FontSize',14)
boxplot(acc_model)
set(gca,'Box','off','XTickLabel',{'Sit','Stairs Dw','Stairs Up','Stand','Walk'},'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold');
%Change box border to black
b = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(b,'tag');   % List the names of all the objects 
box1 = b(11:15);   %the boxes
set(box1, 'Color', 'k');   % Set the color of the first box
%Change box fill
h = findobj(gca,'Tag','Box');
for i = 1:length(h)
    patch(get(h(i),'XData'),get(h(i),'YData'),[1 0 0],'FaceAlpha',0.2);
end

%plot confusion matrix (sum across all subjects)
cmat = zeros(5,5);
for s = 1:length(results_healthy)
    cmat = results_healthy(s).cmat + cmat;
end
correctones = sum(cmat,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat = cmat./correctones

figure, 
imagesc(cmat); 
colorbar
colormap(gray)
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Healthy model','FontSize',14)

%plot average confusion matrix (mean across normalized cmat)
% cmat_all = zeros(5,5);
% for s = 1:length(results_healthy)
%     cmat = results_healthy(s).cmat;
%     correctones = sum(cmat,2);
%     correctones = repmat(correctones,[1 length(activities)]);
%     results_healthy(s).cmat = results_healthy(s).cmat./correctones;
%     cmat_all(:,:,s) = results_healthy(s).cmat;
% end
% 
% cmat = nanmean(cmat_all,3);
% figure
% imagesc(cmat); 
% colorbar
% colormap(gray)
% [cmin,cmax] = caxis;
% caxis([0,1]) %set colormap to 0 1
% ax = gca;
% ax.XTick = 1:size(activities,2);
% ax.YTick = 1:size(activities,2);
% set(gca,'XTickLabel',activities)
% set(gca,'YTickLabel',activities)
% ax.XTickLabelRotation = 45;
% axis square


%create table with precision and recall for each class and subject
precision = []; recall = [];
for s = 1:length(results_healthy)
    precision(s,:) = results_healthy(s).precision
    recall(s,:) = results_healthy(s).recall
end 
% %boxplot
% n = length(results_healthy);
% T = zeros(n,10);
% T(:,1:2:n) = precision;
% T(:,2:2:n) = recall;
% figure
% boxplot(T)

%export table with mean precision and recall
Precision_mean(1,:) = nanmean(precision)
Recall_mean(1,:) = nanmean(recall)

%% Global Patients
load('results_patients.mat')
acc_model = nan(length(results_patients),5);
for p = 1:length(results_patients)
    acc_c = results_patients(p).acc_c';
    if results_patients(p).n_act == 5
        acc_model(p,:) = acc_c;
    else
        acc_model(p,[1 4 5]) = acc_c;
    end
end
    
acc_model    
figure, hold on, title('Impairment Specific model','FontSize',14)
boxplot(acc_model)
set(gca,'Box','off','XTickLabel',{'Sit','Stairs Dw','Stairs Up','Stand','Walk'},'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold');
%Change box border to black
b = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(b,'tag');   % List the names of all the objects 
box1 = b(11:15);   %the boxes
set(box1, 'Color', 'k');   % Set the color of the first box
%Change box fill
h = findobj(gca,'Tag','Box');
for i = 1:length(h)
    patch(get(h(i),'XData'),get(h(i),'YData'),[0.8 0.81 0.17],'FaceAlpha',0.2);
end

%plot confusion matrix (sum across all subjects)
cmat = zeros(5,5);
for s = 1:length(results_patients)
    cmat = results_patients(s).cmat + cmat;
end
correctones = sum(cmat,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat = cmat./correctones

figure, 
imagesc(cmat); 
colorbar
colormap(gray)
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Impairment Specific model','FontSize',14)

%create table with precision and recall for each class and subject
for s = 1:length(results_patients)
    precision(s,:) = results_patients(s).precision;
    recall(s,:) = results_patients(s).recall;
end 

%export table with mean precision and recall
Precision_mean(2,:) = nanmean(precision);
Recall_mean(2,:) = nanmean(recall);

%% Patient specific
load('results_personalSCO.mat')
acc_model = nan(length(results_personalSCO),5);
for p = 1:length(results_personalSCO)
    acc_c = results_personalSCO(p).acc_c';
    if results_personalSCO(p).n_act == 5
        acc_model(p,:) = acc_c;
    else
        acc_model(p,[1 4 5]) = acc_c;
    end
end
    
acc_model    
figure, hold on, title('Patient Specific model','FontSize',14)
boxplot(acc_model)
set(gca,'Box','off','XTickLabel',{'Sit','Stairs Dw','Stairs Up','Stand','Walk'},'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold');
%Change box border to black
b = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(b,'tag');   % List the names of all the objects 
box1 = b(11:15);   %the boxes
set(box1, 'Color', 'k');   % Set the color of the first box
%Change box fill
h = findobj(gca,'Tag','Box');
for i = 1:length(h)
    patch(get(h(i),'XData'),get(h(i),'YData'),[0 0 1],'FaceAlpha',0.35);
end

%plot confusion matrix (sum across all subjects)
cmat = zeros(5,5);
for s = 1:length(results_personalSCO)
    cmat = results_personalSCO(s).cmat + cmat;
end
correctones = sum(cmat,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat = cmat./correctones

figure, 
imagesc(cmat); 
colorbar
colormap(gray)
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Patient Specific model','FontSize',14)

%create table with precision and recall for each class and subject
for s = 1:length(results_personalSCO)
    precision(s,:) = results_personalSCO(s).precision;
    recall(s,:) = results_personalSCO(s).recall;
end 

%export table with mean precision and recall
Precision_mean(3,:) = nanmean(precision);
Recall_mean(3,:) = nanmean(recall);


%% Device specific
load('results_personalCBR.mat')
acc_model = nan(length(results_personalCBR),5);
for p = 1:length(results_personalCBR)
    acc_c = results_personalCBR(p).acc_c';
    if results_personalCBR(p).n_act == 5
        acc_model(p,:) = acc_c;
    else
        acc_model(p,[1 4 5]) = acc_c;
    end
end
    
acc_model    
figure, hold on, title('Device Specific model','FontSize',14)
boxplot(acc_model)
set(gca,'Box','off','XTickLabel',{'Sit','Stairs Dw','Stairs Up','Stand','Walk'},'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold');
%Change box border to black
b = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(b,'tag');   % List the names of all the objects 
box1 = b(11:15);   %the boxes
set(box1, 'Color', 'k');   % Set the color of the first box
%Change box fill
h = findobj(gca,'Tag','Box');
for i = 1:length(h)
    patch(get(h(i),'XData'),get(h(i),'YData'),[0 1 0],'FaceAlpha',0.2);
end

%plot confusion matrix (sum across all subjects)
cmat = zeros(5,5);
for s = 1:length(results_personalCBR)
    cmat = results_personalCBR(s).cmat + cmat;
end
correctones = sum(cmat,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat = cmat./correctones

figure, 
imagesc(cmat); 
colorbar
colormap(gray)
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Patient and Device Specific model','FontSize',14)

%create table with precision and recall for each class and subject
for s = 1:length(results_personalCBR)
    precision(s,:) = results_personalCBR(s).precision;
    recall(s,:) = results_personalCBR(s).recall;
end 

%export table with mean precision and recall
Precision_mean(4,:) = nanmean(precision)
Recall_mean(4,:) = nanmean(recall)

    
    
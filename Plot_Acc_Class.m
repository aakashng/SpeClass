%plot distribution of error per class for each model
%could be modified by including the errors in each session
%% Healthy 
load('results_healthy.mat')
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



    
    
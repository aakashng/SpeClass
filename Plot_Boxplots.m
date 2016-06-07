%Plots results of simulation for global healthy and patient models
%Aakash Gupta (5/27/16)

%% DIRECTORIES
cd(fileparts(which('Plot_Boxplots.m')))
currentDir = pwd;
slashdir = '/';
addpath([pwd slashdir 'sub']); %create path to helper scripts

max_subjects = 10;

%% LOAD ALL DATA
data = zeros(max_subjects,4);

for ii = 1:max_subjects
    load results_healthy.mat
    data(ii,1) = results_healthy(ii).BACC;
    load results_patients.mat
    data(ii,2) = results_patients(ii).BACC;
    load results_personalSCO.mat
    data(ii,3) = results_personalSCO(ii).BACC;
    load results_personalCBR.mat
    data(ii,4) = results_personalCBR(ii).BACC;
end

%% PLOT RESULTS
figure;
bp = boxplot(data);
set(bp,'linewidth',2);
ylim([0.3 1])
ylabel('Balanced Accuracy','FontSize',16)
set(gca,'Box','off','XTick',[1:4],'XTickLabel',{'Healthy','Impairment-Specific','Patient-Specific','Device-Specific'},'YTick',[0.1:0.1:1],'TickDir','out','LineWidth',2,'FontSize',16,'FontWeight','bold');

%Change box border to black
b = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(b,'tag');   % List the names of all the objects 
box1 = b(9:12);   %The 7th object is the first box
set(box1, 'Color', 'k');   % Set the color of the first box

%Change box fill
h = findobj(gca,'Tag','Box');
patch(get(h(1),'XData'),get(h(1),'YData'),[0 1 0],'FaceAlpha',0.2);
patch(get(h(2),'XData'),get(h(2),'YData'),[0 0 1],'FaceAlpha',0.35);
patch(get(h(3),'XData'),get(h(3),'YData'),[0.8 0.81 0.17],'FaceAlpha',0.2);
patch(get(h(4),'XData'),get(h(4),'YData'),[1 0 0],'FaceAlpha',0.2);

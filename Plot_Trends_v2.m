%Plots results of simulation for global healthy and patient models
%Aakash Gupta (5/27/16)

%% DIRECTORIES
cd(fileparts(which('Plot_Trends.m')))
currentDir = pwd;
slashdir = '/';
addpath([pwd slashdir 'sub']); %create path to helper scripts

figure;
max_subjects = 11;

%% LOAD AND PLOT HEALTHY MODEL RESULTS
load results_healthy_trend.mat

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

%Prep exponential fit (a*exp(-b*x)+c)
a = -0.06552;
b = 0.2434;
c = 0.5324;
r2 = 0.9397;
x_fit = [0:0.0001:N];
y_fit = (a*exp(-b*x_fit)+c);
h2 = plot(x_fit,y_fit,'r-','LineWidth',2');

%Saturation Point
h3 = line([0 max_subjects],[c c],'LineWidth',2','LineStyle','--');
legend([h1.mainLine h2 h3],'Data','Exponential Fit','Predicted Max','Location','southeast')
%legend('Data','Fit','Predicted Max','Location','southeast')
title('Healthy Model Simulation','FontSize',18)
hold off

%% LOAD AND PLOT PATIENT MODEL RESULTS
load results_patients_trend.mat

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
h4 = shadedErrorBar(1:N,mu,flipud(CI_bars),{'-o','Color',[0 0.5 0],'MarkerFaceColor',[0 0.5 0]},1);

%Exponential fit (a*exp(-b*x)+c)
a = -0.1661;
b = 0.3959;
c = 0.6746;
r2 = 0.962;
x_fit = [0:0.0001:N];
y_fit = (a*exp(-b*x_fit)+c);
h5 = plot(x_fit,y_fit,'r-','LineWidth',2');

%Saturation Point
h6 = line([0 max_subjects],[c c],'LineWidth',2','LineStyle','--');
hold off

%% GENERAL FIGURE PROPERTIES
xlabel('Number of subjects trained on','FontSize',16);
ylabel('Balanced Accuracy','FontSize',16);
title('Global Model Simulations','FontSize',18)
xlim([1 11])
ylim([0.45 0.7])
%legend([h1.mainLine h2 h3 h4.mainLine h5 h6],'HM Bootstrapped Mean','HM Exponential Fit','HM Predicted Max','ISM Bootstrapped Mean','ISM Exponential Fit','ISM Predicted Max','Location','southeast')
legend([h1.mainLine h4.mainLine],'Healthy Model Bootstrapped Mean','Impairment-Specific Model Bootstrapped Mean','Location','southeast')
set(gca,'Box','off','XTick',[1:max_subjects],'YTick',[0.1:0.05:1],'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold','XGrid','off');
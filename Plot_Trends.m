%Plots results of simulation for global healthy and patient models
%Aakash Gupta (5/27/16)

%% DIRECTORIES
cd(fileparts(which('Plot_Trends.m')))
currentDir = pwd;
slashdir = '/';

figure;

%% LOAD AND PLOT HEALTHY MODEL RESULTS
load results_healthy_trend.mat

%Plot results
subplot(1,2,1)
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
h1 = shadedErrorBar(1:N,mu,flipud(CI_bars),{'k-o','markerfacecolor','k'},1);
xlabel('Number of subjects trained on','FontSize',16);
ylabel('Balanced Accuracy','FontSize',16);
xlim([1 N])
ylim([0.45 0.55])
set(gca,'Box','off','XTick',[1:N],'YTick',[0.1:0.025:1],'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold','XGrid','off');

%Prep exponential fit (a*exp(-b*x)+c)
a = -0.06552;
b = 0.2434;
c = 0.5324;
r2 = 0.9397;
x_fit = [0:0.0001:N];
y_fit = (a*exp(-b*x_fit)+c);
h2 = plot(x_fit,y_fit,'r-','LineWidth',2');

%Saturation Point
h3 = line([0 N+1],[c c],'LineWidth',2','LineStyle','--');
legend([h1.mainLine h2 h3],'Data','Exponential Fit','Predicted Max','Location','southeast')
%legend('Data','Fit','Predicted Max','Location','southeast')
title('Healthy Model Simulation','FontSize',18)
hold off

%% LOAD AND PLOT PATIENT MODEL RESULTS
load results_patients_trend.mat

%Plot results
subplot(1,2,2)
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
h1 = shadedErrorBar(1:N,mu,flipud(CI_bars),{'k-o','markerfacecolor','k'},1);
xlabel('Number of subjects trained on','FontSize',16);
ylabel('Balanced Accuracy','FontSize',16);
xlim([1 N])
ylim([0.5 0.7])
set(gca,'Box','off','XTick',[1:N],'YTick',[0.1:0.025:1],'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold','XGrid','off');

%Exponential fit (a*exp(-b*x)+c)
a = -0.1661;
b = 0.3959;
c = 0.6746;
r2 = 0.962;
x_fit = [0:0.0001:N+1];
y_fit = (a*exp(-b*x_fit)+c);
h2 = plot(x_fit,y_fit,'r-','LineWidth',2');

%Saturation Point
h3 = line([0 N+1],[c c],'LineWidth',2','LineStyle','--');
legend([h1.mainLine h2 h3],'Data','Exponential Fit','Predicted Max','Location','southeast')
%legend('Data','Fit','Predicted Max','Location','southeast')
title('Impairment-Specific Model Simulation','FontSize',18)
hold off
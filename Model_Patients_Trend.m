%% Plots Balanced Accuracy Against Number of Patients Trained On
%Aakash Gupta

%% LOAD DATA AND INITIALIZE PARAMETERS
clear all, close all;

iterations = 1000;
patient_stairs = [8 11 12 14 15 19];
disp(patient_stairs);

p = gcp('nocreate');
if isempty(p)
    parpool('local')
end

cd(fileparts(which('Model_Patients_Trend.m')))
currentDir = pwd;
slashdir = '/';
addpath([pwd slashdir 'sub']); %create path to helper scripts
addpath(genpath([slashdir 'Traindata'])); %add path for train data

OOBVarImp = 'off';   %enable variable importance measurement

%% LOAD PATIENT DATA TO ANALYZE
proceed = 1;
while proceed > 0
    population = input('Are you analyzing healthy or patient? ','s');
    if strcmpi(population,'patient')
        proceed = 0;
    elseif strcmpi(population,'healthy')
        proceed = 0;
    else
        disp('Please type healthy or patient.');
        proceed = 1;
    end
end

filename = ['trainData_' population '.mat'];
load(filename)

%% User Input for Which Subject to Analyze
tt = num2str(unique(trainingClassifierData.subjectID)');
fprintf('\n')
fprintf('Subject IDs present for analysis: %s',tt)
fprintf('\n')
fprintf('Available files to analyze: ')
fprintf('\n')
disp(unique(trainingClassifierData.subject))
fprintf('\n')

all_subjectID = trainingClassifierData.subjectID;
disp('Please enter subject IDs to analyze one at a time.')
disp('When you are done type 0.')
fprintf('\n')
pause(1)

user_subjects = [];
subject_indices = [];
proceed = 1;
while proceed > 0
    subject_analyze = input('Subject ID to analyze (ex. 5): ');
    
    if (subject_analyze == 0)
        proceed = 0;
    else
        %Check if subjectID is in mat file
        if ~any(subject_analyze == all_subjectID)
            disp('-------------------------------------------------------------')
            disp('Subject ID not in trainingClassifierData.mat file. Try again.')
            disp('-------------------------------------------------------------')
        else
            subject_indices = [subject_indices; find(subject_analyze==all_subjectID)];
            user_subjects = [user_subjects subject_analyze];
        end
    end
end

for zz = 1:length(trainingClassifierData.subject)
    temp = char(trainingClassifierData.subject(zz));
    trainingClassifierData.subjectBrace(zz) = {temp(7:9)};
end
cData_temp = trainingClassifierData;

proceed = 1;
while proceed > 0
    fprintf('\n')
    disp('Please enter the max number of sessions to analyze.');
    disp('Or type 0 to analyze all sessions available.')
    min_sessions = input('Min session ID: ');
    max_sessions = input('Max session ID: ');
    proceed = 0;
end

if max_sessions == 0
    cData = cData_temp;
else
    cData = isolateSession(cData_temp,max_sessions,min_sessions);
end

fprintf('\n')

%% CYCLE THROUGH EACH PATIENT
states = {'Sitting';'Stairs Dw';'Stairs Up';'Standing';'Walking'};
IDs = user_subjects;
mat_accRF = zeros(iterations,length(IDs)-1);
mat_BACC = zeros(iterations,length(IDs)-1);
subjects_train = cell(iterations,length(IDs)-1);
subjects_test = cell(iterations,length(IDs)-1);

ntrees = 50;
opts_ag = statset('UseParallel',1);

%Cycle through each patient
for n = 1:(length(IDs)-1) %number of people to train on
    parfor m = 1:iterations %number of times to run the simulation
        %% DISPLAY PROGRESS
        disp(['Train on ' num2str(n) ' subjects. Iteration: ' num2str(m)])
        
        %% DETERMINE TRAIN/TESTING
        %Randomly shuffle IDs + select training patients
        IDs_rand = IDs(randperm(length(IDs)));
        IDs_train = unique(IDs_rand(1:n)); %number of IDs to train on changes in each iteration of n

        %Randomly shuffle IDs + select training patients
        IDs_rand = IDs(randperm(length(IDs))); %reshuffle
        IDs_test = unique(IDs_rand(1)); %use the next ID as the testing
        
        %% TRAIN RF
        %Isolate training patients SCO data
        global_p_temp = isolateBrace(cData,'SCO'); %isolate SCO data
        ind = find(ismember(global_p_temp.subjectID,IDs_train)); %indices for global patients
        global_p = isolateSubject(global_p_temp,ind);
        
        %Extract data
        features_p     = global_p.features; %features for classifier
        subjects_p     = global_p.subject;  %subject number
        uniqSubjects_p = unique(subjects_p); %list of subjects
        statesTrue_p = global_p.activity;     %all the classifier data
        subjectID_p = global_p.subjectID;
        sessionID_p = global_p.sessionID;
        
        %Remove stairs data from specific patients
        stairs_remove = [];
        for h = 1:length(patient_stairs)
            a1 = find(subjectID_p == patient_stairs(h));
            a2 = strmatch('Stairs Up',statesTrue_p,'exact');
            a = intersect(a1,a2);
            
            b1 = find(subjectID_p == patient_stairs(h));
            b2 = strmatch('Stairs Dw',statesTrue_p,'exact');
            b = intersect(b1,b2);
            
            stairs_remove = [stairs_remove; a; b];
        end
        features_p(stairs_remove,:) = [];
        subjects_p(stairs_remove) = [];
        statesTrue_p(stairs_remove) = [];
        subjectID_p(stairs_remove) = [];
        sessionID_p(stairs_remove) = [];
        uniqStates_p  = unique(statesTrue_p);
        
        %Generate codesTrue
        codesTrue_p = zeros(1,length(statesTrue_p));
        for i = 1:length(statesTrue_p)
            codesTrue_p(i) = find(strcmp(statesTrue_p{i},states));
        end
        
        %Train Random Forest
        RFmodel_p = TreeBagger(ntrees,features_p,codesTrue_p','OOBVarImp',OOBVarImp,'Options',opts_ag);
        
        %% TEST RF
        %Isolate testing patient's CBR data
        patient_temp = isolateBrace(cData,'Cbr');
        ind = find(ismember(global_p_temp.subjectID,IDs_test)); %indices for global patients
        patient = isolateSubject(patient_temp,ind);
        
        %Extract data
        features     = patient.features; %features for classifier
        subjects     = patient.subject;  %subject number
        uniqSubjects = unique(subjects); %list of subjects
        statesTrue = patient.activity;     %all the classifier data
        subjectID = patient.subjectID;
        sessionID = patient.sessionID;
        
        %Remove stairs data from specific patients
        if ismember(IDs_test,patient_stairs)
            a = strmatch('Stairs Up',statesTrue,'exact');
            b = strmatch('Stairs Dw',statesTrue,'exact');
            stairs_remove = [a; b];
            features(stairs_remove,:) = [];
            subjects(stairs_remove) = [];
            statesTrue(stairs_remove) = [];
            subjectID(stairs_remove) = [];
            sessionID(stairs_remove) = [];
            uniqStates = unique(statesTrue);
        else
            uniqStates = unique(statesTrue);
        end
        
        %Generate codesTrue
        codesTrue = zeros(1,length(statesTrue));
        for i = 1:length(statesTrue)
            codesTrue(i)  = find(strcmp(statesTrue{i},states));
        end
        
        %Test Random Forest
        [codesRF,P_RF] = predict(RFmodel_p,features);
        codesRF = str2num(cell2mat(codesRF));
        
        %Accuracy
        [matRF, accRF] = confusionMatrix_5(codesTrue,codesRF);
        disp(matRF)
        disp(accRF)
        
        %BER (Balanced Error Rate)
        if length(uniqStates) == 3 %no stairs
            ind = [1 4 5];
        elseif length(uniqStates) == 5 %stairs
            ind = [1:5];
        else
            error('Weird number of classes present in testing set')
        end
        correct = sum(matRF,2);
        diagonal = diag(matRF);
        BER = (1/length(ind)).*sum((correct(ind)-diagonal(ind))./(correct(ind)));
        BACC = 1-BER;
        disp(BACC);
        
        %Save data
        mat_accRF(m,n) = accRF;
        mat_BACC(m,n) = BACC;
        subjects_train{m,n} = IDs_train;
        subjects_test{m,n} = IDs_test;
    end
    fprintf('\n')
end

%% PLOT DATA
%Mean +/- SEM
figure;
hold on
N = size(mat_BACC,2); %number of patients
x = 1:N;
avg = mean(mat_BACC,1); %average
sem = std(mat_BACC,[],1)./sqrt(size(mat_BACC,1)); %standard error of the mean
stddev = std(mat_BACC,[],1); %standard error of the mean
errorbar(1:N,avg,sem,'ko-','LineWidth',2,'markerfacecolor','k');
%h1 = shadedErrorBar(1:N-1,avg,sem,{'k-o','markerfacecolor','k'},1);
xlabel('Number of subjects trained on','FontSize',16);
ylabel('Balanced Accuracy','FontSize',16);
xlim([0.5 (N+0.5)])
ylim([0.5 0.7])
set(gca,'Box','off','XTick',[1:N],'YTick',[0.1:0.025:1],'TickDir','out','LineWidth',2,'FontSize',14,'FontWeight','bold','XGrid','off');

%Exponential fit (a*exp(-b*x)+c)
a = -0.1664;
b = 0.3984;
c = 0.6745;
r2 = 0.9615;
x_fit = [0:0.0001:N+1];
y_fit = (a*exp(-b*x_fit)+c);
h2 = plot(x_fit,y_fit,'r-','LineWidth',2');

%Saturation Point
line([0 N+1],[c c],'LineWidth',2','LineStyle','--')
%legend([h1.mainLine h2],'Data','Fit')
legend('Data','Fit','Predicted Max','Location','southeast')
hold off

%% SAVE DATA
save('results_patients_trend.mat','mat_accRF','mat_BACC','subjects_train','subjects_test')
fprintf('\n')
disp('Results saved (results_patient_trend.mat).')
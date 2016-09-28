%% RF for Training on Healthy and Testing on CBR
%Aakash Gupta

%% LOAD DATA AND INITIALIZE PARAMETERS
clear all, close all;

patient_stairs = [8 11 12 14 15 19];
disp(patient_stairs);

p = gcp('nocreate');
if isempty(p)
    parpool('local')
end

cd(fileparts(which('Model_Healthy.m')))
currentDir = pwd;
slashdir = '/';
addpath([pwd slashdir 'sub']); %create path to helper scripts
addpath(genpath([slashdir 'Traindata'])); %add path for train data

OOBVarImp = 'off';   %enable variable importance measurement

%% LOAD HEALTHY DATA + TRAIN CLASSIFIER
filename = ['trainData_healthy.mat'];
load(filename)

features_h = trainingClassifierData.features;
activity_h = trainingClassifierData.activity;
uniqStates  = unique(activity_h);

codesTrue_h = zeros(1,length(activity_h));
for i = 1:length(activity_h)
    codesTrue_h(i) = find(strcmp(activity_h{i},uniqStates));
end

%Train RF
n_h = length(unique(trainingClassifierData.subjectID));
disp(['Training classifier on ' num2str(n_h) ' healthy subjects...'])
ntrees = 50;
opts_ag = statset('UseParallel',1);
RFmodel_h = TreeBagger(ntrees,features_h,codesTrue_h','OOBVarImp',OOBVarImp,'Options',opts_ag);
disp('Classifier trained.')

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
default_subjects = [1, 2, 5, 6, 8, 11, 14, 15, 16, 19]; %all patients with 4 sessions in CBR (as in paper)
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
    subject_analyze = input('Subject ID to analyze (ex. 5); -1 to select default subset: ');

    if (subject_analyze == 0)
        proceed = 0;
        
     elseif subject_analyze == -1
        subject_analyze = default_subjects;
        for sa = 1:length(subject_analyze)
            subject_indices = [subject_indices; find(subject_analyze(sa)==all_subjectID)];
            user_subjects = [user_subjects subject_analyze];
        end
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

cData_temp2 = isolateSubject(trainingClassifierData,subject_indices);

if strcmpi(population,'patient')
    for zz = 1:length(cData_temp2.subject)
        temp = char(cData_temp2.subject(zz));
        cData_temp2.subjectBrace(zz) = {temp(7:9)};
    end

    proceed = 1;
    while proceed > 0
        fprintf('\n')
        brace_analyze = input('Brace to analyze (SCO, CBR, both): ','s');

        %Check if brace entered is SCO or CBR or both
        if ~(strcmpi(brace_analyze,'SCO') || strcmpi(brace_analyze,'CBR') || strcmpi(brace_analyze,'BOTH'))
            disp('---------------------------------------------------------------')
            disp('Please correctly select a brace (SCO, CBR, or both). Try again.');
            disp('---------------------------------------------------------------')
        else
            %Check if SCO or CBR are in mat file
            if (strcmpi(brace_analyze,'both'))
                brace_analyze = 'both';

                if isempty(strmatch('Cbr',cData_temp2.subjectBrace)) || isempty(strmatch('SCO',cData_temp2.subjectBrace))
                    disp('--------------------------------------------------------')
                    disp('Brace not in trainingClassifierData.mat file. Try again.')
                    disp('--------------------------------------------------------')
                else
                    proceed = 0;
                end
            elseif (strcmpi(brace_analyze,'CBR'))
                brace_analyze = 'Cbr';

                if isempty(strmatch('Cbr',cData_temp2.subjectBrace))
                    disp('------------------------------------------------------')
                    disp('CBR not in trainingClassifierData.mat file. Try again.')
                    disp('------------------------------------------------------')
                else
                    proceed = 0;
                end
            elseif (strcmpi(brace_analyze,'SCO'))
                brace_analyze = 'SCO';

                if isempty(strmatch('SCO',cData_temp2.subjectBrace))
                    disp('------------------------------------------------------')
                    disp('SCO not in trainingClassifierData.mat file. Try again.')
                    disp('------------------------------------------------------')
                else
                    proceed = 0;
                end
            end
        end
    end

    cData_temp = isolateBrace(cData_temp2,brace_analyze);
else
    cData_temp = cData_temp2;
end

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
disp('These are the subjects that will be analyzed: ')
disp(unique(cData.subject))
fprintf('\n')

%% CYCLE THROUGH EACH PATIENT + RF TEST
states = {'Sitting';'Stairs Dw';'Stairs Up';'Standing';'Walking'};
IDs = unique(cData.subjectID);
results_healthy = []; %store all the results

%Cycle through each patient
for y = 1:length(IDs)
    
    %Isolate  subject
    subject_indices = find(IDs(y)==cData.subjectID);
    patient = isolateSubject(cData,subject_indices);
    
    %Extract data
    features_p     = patient.features; %features for classifier
    subjects_p     = patient.subject;  %subject number
    uniqSubjects_p = unique(subjects_p); %list of subjects
    statesTrue_p = patient.activity;     %all the classifier data
    subjectID_p = patient.subjectID;
    sessionID_p = patient.sessionID;
    
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
        codesTrue_p(i)  = find(strcmp(statesTrue_p{i},states));
    end
    
    %Train Random Forest on Global Patient
    disp(['RF Test - Patient '  num2str(IDs(y)) '  #Samples Test = ' num2str(size(features_p,1))]);
    
    %Test Random Forest
    [codesRF,P_RF] = predict(RFmodel_h,features_p);
    codesRF = str2num(cell2mat(codesRF));
    
    %Accuracy
    [matRF, accRF] = confusionMatrix_5(codesTrue_p,codesRF);
    disp(matRF)
    disp(accRF)
    
    %Precision, Recall, and F1
    precision = zeros(length(states),1);
    recall = zeros(length(states),1);
    F1 = zeros(length(states),1);
    for c = 1:length(states)
        precision(c) = matRF(c,c)/sum(matRF(:,c)); %precision
        recall(c) = matRF(c,c)/sum(matRF(c,:)); %recall
        F1(c) = 2*((precision(c)*recall(c))/(precision(c)+recall(c)));
        
        %In case of NaN, set to zero
        if isnan(precision(c))
            precision(c) = 0;
        end
        if isnan(recall(c))
            recall(c) = 0;
        end
    end
       
    %BER (Balanced Error Rate)
    if length(uniqStates_p) == 3 %no stairs
        ind = [1 4 5];
        %set precision and recall to nan for patients with no stairs
        precision([2 3]) = nan;
        recall([2 3]) = nan;
    elseif length(uniqStates_p) == 5 %stairs
        ind = [1:5];
    end
    correct = sum(matRF,2);
    diagonal = diag(matRF);
    acc_c = 1-((correct(ind)-diagonal(ind))./(correct(ind)));    %accuracy per class
    BER = mean(1-acc_c);
            
    %Save data
    results_healthy(y).ID = IDs(y);
    results_healthy(y).accRF = accRF;
    results_healthy(y).n_act = length(uniqStates_p);
    results_healthy(y).n_train = size(features_p,1);
    results_healthy(y).cmat = matRF;
    results_healthy(y).precision = precision;
    results_healthy(y).recall = recall;
    results_healthy(y).F1 = F1;
    results_healthy(y).BER = BER;
    results_healthy(y).BACC = 1-BER;
    results_healthy(y).acc_c = acc_c;
end

%% SAVE DATA
save('results_healthy.mat','results_healthy')
fprintf('\n')
disp('Results saved (results_healthy.mat).')
open results_healthy
%% RF for Session-Wise Cross Validation on Personal CBR Data
%Aakash Gupta

%% LOAD DATA AND INITIALIZE PARAMETERS
clear all, close all;

patient_stairs = [8 11 12 14 15 19];
disp(patient_stairs);

p = gcp('nocreate');
if isempty(p)
    parpool('local')
end

cd(fileparts(which('Model_PersonalCBR.m')))
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
cData_temp = isolateBrace(trainingClassifierData,'Cbr');

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
results_personalCBR = []; %store all the results

%Cycle through each patient
for y = 1:length(IDs)
    %% ISOLATE PERSONAL DATA
    ind = find(cData.subjectID==IDs(y));
    data = isolateSubject(cData,ind);
            
    %Extract data
    features_p     = data.features; %features for classifier
    subjects_p     = data.subject;  %subject number
    uniqSubjects_p = unique(subjects_p); %list of subjects
    statesTrue_p = data.activity;     %all the classifier data
    subjectID_p = data.subjectID;
    sessionID_p = data.sessionID;
    
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
    
    %% Session-wise Cross-Validation
    ntrees = 50;
    disp(['RF Train - Patient '  num2str(IDs(y)) '  #Samples Train = ' num2str(size(features_p,1))]);
    opts_ag = statset('UseParallel',1);
    codesRF = zeros(size(codesTrue_p));
    for k = 1:max(sessionID_p)
        disp(['Testing on Session ' num2str(k)])
        
        test_ind = find(sessionID_p == k);
        train_ind = 1:length(features_p);
        train_ind(test_ind) = [];
        
        %Train RF
        RFmodel_p = TreeBagger(ntrees,features_p(train_ind,:),codesTrue_p(train_ind)','OOBVarImp',OOBVarImp,'Options',opts_ag);

        %Test RF
        [codes_temp,~] = predict(RFmodel_p,features_p(test_ind,:));
        codesRF(test_ind) = str2num(cell2mat(codes_temp));
        
    end 
    
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
    elseif length(uniqStates_p) == 5 %stairs
        ind = [1:5];
    else
        error('Weird number of classes present in testing set')
    end
    correct = sum(matRF,2);
    diagonal = diag(matRF);
    BER = (1/length(ind)).*sum((correct(ind)-diagonal(ind))./(correct(ind)));
    
    %Save data
    results_personalCBR(y).ID = IDs(y);
    results_personalCBR(y).accRF = accRF;
    results_personalCBR(y).n_act = length(uniqStates_p);
    results_personalCBR(y).n_train = size(features_p,1);
    results_personalCBR(y).cmat = matRF;
    results_personalCBR(y).precision = precision;
    results_personalCBR(y).recall = recall;
    results_personalCBR(y).F1 = F1;
    results_personalCBR(y).BER = BER;
    results_personalCBR(y).BACC = 1-BER;
end

%% SAVE DATA
save('results_personalCBR.mat','results_personalCBR')
fprintf('\n')
disp('Results saved (results_personalCBR.mat).')
open results_personalCBR
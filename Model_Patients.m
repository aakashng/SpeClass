%% RF for Training on Global SCO and Testing on CBR
%Aakash Gupta

%% LOAD DATA AND INITIALIZE PARAMETERS
clear all, close all;

patient_stairs = [8 11 12 14 15 19];
disp(patient_stairs);
    
p = gcp('nocreate');
if isempty(p)
    parpool('local')
end

cd(fileparts(which('Model_Patients.m')))
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
        disp(['Subjects ID analyzed: ',num2str(default_subjects)])
        subject_analyze = default_subjects;
        for sa = 1:length(subject_analyze)
            subject_indices = [subject_indices; find(subject_analyze(sa)==all_subjectID)];
        end
        user_subjects = subject_analyze;
        
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
results_patients = []; %store all the results


%Cycle through each patient
for y = 1:length(IDs)
    %% CLEAR VARIABLES
    clear global_p_temp global_p patient_temp patient
    
    %% TRAIN RF
    %Isolate global patients SCO data
    global_p_temp = isolateBrace(cData,'SCO'); %isolate SCO data
    IDs_temp = IDs;
    IDs_temp(y) = []; %remove current patient
    ind = find(ismember(global_p_temp.subjectID,IDs_temp)); %indices for global patients
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
    ntrees = 50;
    disp(['RF Train - Patient ' num2str(IDs(y)) ' | #Samples Train = ' num2str(size(features_p,1))]);
    opts_ag = statset('UseParallel',1);
    RFmodel_p = TreeBagger(ntrees,features_p,codesTrue_p','OOBVarImp',OOBVarImp,'Options',opts_ag);
    
    %% TEST RF
    %Isolate patient's CBR data
    patient_temp = isolateBrace(cData,'Cbr');
%     ind = find(global_p_temp.subjectID == IDs(y)); %indices for global patients
    ind = find(patient_temp.subjectID == IDs(y)); %indices for global patients
    patient = isolateSubject(patient_temp,ind);
    
    %Extract data
    features     = patient.features; %features for classifier
    subjects     = patient.subject;  %subject number
    uniqSubjects = unique(subjects); %list of subjects
    statesTrue = patient.activity;     %all the classifier data
    subjectID = patient.subjectID;
    sessionID = patient.sessionID;
    
    %Remove stairs data from specific patients
    if ismember(IDs(y),patient_stairs)
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
    if length(uniqStates) == 3 %no stairs
        ind = [1 4 5];
        %set precision and recall to nan for patients with no stairs
        precision([2 3]) = nan;
        recall([2 3]) = nan;
    elseif length(uniqStates) == 5 %stairs
        ind = [1:5];
    else
        error('Weird number of classes present in testing set')
    end
    correct = sum(matRF,2);
    diagonal = diag(matRF);
    acc_c = 1-((correct(ind)-diagonal(ind))./(correct(ind)));    %accuracy per class
    BER = mean(1-acc_c);
   
    %Save data
    results_patients(y).ID = IDs(y);
    results_patients(y).accRF = accRF;
    results_patients(y).n_act = length(uniqStates);
    results_patients(y).n_train = size(features_p,1);
    results_patients(y).cmat = matRF;
    results_patients(y).precision = precision;
    results_patients(y).recall = recall;
    results_patients(y).F1 = F1;
    results_patients(y).BER = BER;
    results_patients(y).BACC = 1-BER;
    results_patients(y).acc_c = acc_c;

end

%% SAVE DATA
save('results_patients.mat','results_patients')
fprintf('\n')
disp('Results saved (results_patient.mat).')
open results_patients
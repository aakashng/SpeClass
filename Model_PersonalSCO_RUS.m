%% RF for Training on Personal SCO Data and Testing on Personal CBR Data
%Aakash Gupta

%% LOAD DATA AND INITIALIZE PARAMETERS
clear all, close all;

patient_stairs = [8 11 12 14 15 19];
disp(patient_stairs);

p = gcp('nocreate');
if isempty(p)
    parpool('local')
end

cd(fileparts(which('Model_PersonalSCO.m')))
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
results_personalSCO = []; %store all the results

%Cycle through each patient
for y = 1:length(IDs)
    %% CLEAR VARIABLES
    %clear global_p_temp global_p patient_temp patient
    
    %% ISOLATE PERSONAL DATA
    ind = find(cData.subjectID==IDs(y));
    cData_personal = isolateSubject(cData,ind);
    
    %% TRAIN RF
    %Isolate patient's SCO data
    data_SCO = isolateBrace(cData_personal,'SCO'); %isolate SCO data
    
    %Extract data
    features_p     = data_SCO.features; %features for classifier
    subjects_p     = data_SCO.subject;  %subject number
    uniqSubjects_p = unique(subjects_p); %list of subjects
    statesTrue_p = data_SCO.activity;     %all the classifier data
    subjectID_p = data_SCO.subjectID;
    sessionID_p = data_SCO.sessionID;
    
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
    
    %Train RUS Boost
    ntrees = 500;
%     t = templateTree('MaxNumSplits',4); %shallow trees
    t = templateTree('MinLeafSize',5); %deep trees
%     t = templateTree('MaxNumSplits',20); %deep trees
    RFmodel_p = fitensemble(features_p,codesTrue_p','RUSBoost',ntrees,t,'LearnRate',0.1,'nprint',100);
    disp('Classifier trained.')

    %% TEST RF
    %Isolate patient's CBR data
    data_CBR = isolateBrace(cData_personal,'Cbr');
    
    %Extract data
    features     = data_CBR.features; %features for classifier
    subjects     = data_CBR.subject;  %subject number
    uniqSubjects = unique(subjects); %list of subjects
    statesTrue = data_CBR.activity;     %all the classifier data
    subjectID = data_CBR.subjectID;
    sessionID = data_CBR.sessionID;
    
    %Remove stairs data from specific patients
    stairs_remove = [];
    for h = 1:length(patient_stairs)
        a1 = find(subjectID == patient_stairs(h));
        a2 = strmatch('Stairs Up',statesTrue,'exact');
        a = intersect(a1,a2);
        
        b1 = find(subjectID == patient_stairs(h));
        b2 = strmatch('Stairs Dw',statesTrue,'exact');
        b = intersect(b1,b2);
        
        stairs_remove = [stairs_remove; a; b];
    end
    features(stairs_remove,:) = [];
    subjects(stairs_remove) = [];
    statesTrue(stairs_remove) = [];
    subjectID(stairs_remove) = [];
    sessionID(stairs_remove) = [];
    uniqStates = unique(statesTrue);
    
    %Generate codesTrue
    codesTrue = zeros(1,length(statesTrue));
    for i = 1:length(statesTrue)
        codesTrue(i)  = find(strcmp(statesTrue{i},states));
    end
        
    %Test Random Forest
    [codesRF,~] = predict(RFmodel_p,features);
%     codesRF = str2num(cell2mat(codesRF));
    
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
    elseif length(uniqStates) == 5 %stairs
        ind = [1:5];
    else
        error('Weird number of classes present in testing set')
    end
    correct = sum(matRF,2);
    diagonal = diag(matRF);
    BER = (1/length(ind)).*sum((correct(ind)-diagonal(ind))./(correct(ind)));
    
    %Save data
    results_personalSCO(y).ID = IDs(y);
    results_personalSCO(y).accRF = accRF;
    results_personalSCO(y).n_act = length(uniqStates);
    results_personalSCO(y).n_train = size(features_p,1);
    results_personalSCO(y).cmat = matRF;
    results_personalSCO(y).precision = precision;
    results_personalSCO(y).recall = recall;
    results_personalSCO(y).F1 = F1;
    results_personalSCO(y).BER = BER;
    results_personalSCO(y).BACC = 1-BER;
    
    %save loss
    l(y,:) = loss(RFmodel_p,features,codesTrue,'mode','cumulative');
    figure
    plot(l(y,:));
    xlabel('Number of trees');
    ylabel('Test classification error');
    title(['Patient: ',num2str(IDs(y))])
end

%% SAVE DATA
figure
plot(mean(l,1))
% errorbar(mean(l),std(l))
xlabel('Number of trees');
ylabel('Test classification error');
save('results_personalSCO_RUS.mat','results_personalSCO')
fprintf('\n')
disp('Results saved (results_personalSCO_RUS.mat).')
% open results_personalSCO_RUS
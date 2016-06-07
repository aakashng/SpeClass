%% RF for Session-Wise Cross Validation on Personal CBR Data
%Aakash Gupta

%% LOAD DATA AND INITIALIZE PARAMETERS
clear all, close all;

iterations = 1;
sessions = 1:4;

patient_stairs = [8 11 12 14 15 19];
disp(patient_stairs);

p = gcp('nocreate');
if isempty(p)
    parpool('local')
end

cd(fileparts(which('Model_Stacked_LOSO.m')))
currentDir = pwd;
slashdir = '/';
addpath([pwd slashdir 'sub']); %create path to helper scripts
addpath(genpath([slashdir 'Traindata'])); %add path for train data

OOBVarImp = 'off';   %enable variable importance measurement

%% LOAD PATIENT DATA TO ANALYZE
population = 'patient';
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

cData = trainingClassifierData;
fprintf('\n')

%% EXTRACT BRACE DATA
cData_CBR = isolateBrace(cData,'Cbr');
cData_SCO = isolateBrace(cData,'SCO');

%% TRAIN PERSONAL FORESTS ON SCO DATA
states = {'Sitting';'Stairs Dw';'Stairs Up';'Standing';'Walking'};
IDs = user_subjects;
ntrees1 = 100;
ntrees2 = 100;
opts_ag = statset('UseParallel',1);
models(length(IDs)).IDs = [];
models(length(IDs)).SCO = []; %struct that will contain all the forests

results_stacked = zeros(length(IDs),length(sessions),iterations); %store BACC results

for w = 1:iterations
    fprintf('\n')
    disp('-------------')
    disp(['ITERATION: ' num2str(w)])
    disp('-------------')
    
    disp('Layer 1: Training models...')
    parfor k = 1:length(IDs)
        %% EXTRACT EACH PATIENT'S DATA
        models(k).IDs = IDs(k);
        patient_ind = find(cData_SCO.subjectID == IDs(k));
        patient_SCO = isolateSubject(cData_SCO,patient_ind);
        
        %Extract data
        features_SCO     = patient_SCO.features; %features for classifier
        subjects_SCO     = patient_SCO.subject;  %subject number
        uniqSubjects_SCO = unique(subjects_SCO); %list of subjects
        statesTrue_SCO = patient_SCO.activity;     %all the classifier data
        subjectID_SCO = patient_SCO.subjectID;
        sessionID_SCO = patient_SCO.sessionID;
        
        %Remove stairs data from specific patient
        if ismember(IDs(k),patient_stairs)
            a = strmatch('Stairs Up',statesTrue_SCO,'exact');
            b = strmatch('Stairs Dw',statesTrue_SCO,'exact');
            stairs_remove = [a; b];
            features_SCO(stairs_remove,:) = [];
            subjects_SCO(stairs_remove) = [];
            statesTrue_SCO(stairs_remove) = [];
            subjectID_SCO(stairs_remove) = [];
            sessionID_SCO(stairs_remove) = [];
            uniqStates_SCO = unique(statesTrue_SCO);
        else
            uniqStates_SCO = unique(statesTrue_SCO);
        end
        
        %Generate codesTrue
        codesTrue_SCO = zeros(1,length(statesTrue_SCO));
        for i = 1:length(statesTrue_SCO)
            codesTrue_SCO(i) = find(strcmp(statesTrue_SCO{i},states));
        end
        
        %% TRAIN INDIVIDUAL RFs (Layer 1)
        models(k).SCO = TreeBagger(ntrees1,features_SCO,codesTrue_SCO','OOBVarImp',OOBVarImp,'Options',opts_ag);
        disp(['   Model trained on Patient ' num2str(IDs(k)) ' SCO data.'])
    end
    disp('Layer 1: Training complete')
    fprintf('\n')
    
    %% CYCLE THROUGH EACH PATIENT
    for q = 1:length(sessions)
        new_session = sessions(q);
        main_sessions = sessions;
        main_sessions(q) = [];
        
        disp(['TARGET SESSION: Session ' num2str(sessions(q))])
        
        for y = 1:length(IDs)
            %% DISPLAY INFORMATION
            disp(['   PATIENT ' num2str(IDs(y)) ':'])
            
            %% ISOLATE PERSONAL "MAIN" SESSIONS (Sessions 1-3)
            subject_indices = find(IDs(y)==cData_CBR.subjectID);
            personal = isolateSubject(cData_CBR,subject_indices);
            personal_main = isolateSession2(personal,main_sessions);
            
            %Extract data
            features_main     = personal_main.features; %features for classifier
            subjects_main     = personal_main.subject;  %subject number
            uniqSubjects_main = unique(subjects_main); %list of subjects
            statesTrue_main = personal_main.activity;     %all the classifier data
            subjectID_main = personal_main.subjectID;
            sessionID_main = personal_main.sessionID;
                        
            %Remove stairs data from specific patient
            if ismember(IDs(y),patient_stairs)
                a = strmatch('Stairs Up',statesTrue_main,'exact');
                b = strmatch('Stairs Dw',statesTrue_main,'exact');
                stairs_remove = [a; b];
                features_main(stairs_remove,:) = [];
                subjects_main(stairs_remove) = [];
                statesTrue_main(stairs_remove) = [];
                subjectID_main(stairs_remove) = [];
                sessionID_main(stairs_remove) = [];
                uniqStates_main = unique(statesTrue_main);
            else
                uniqStates_main = unique(statesTrue_main);
            end
            
            %Generate codesTrue
            codesTrue_main = zeros(1,length(statesTrue_main));
            for i = 1:length(statesTrue_main)
                codesTrue_main(i) = find(strcmp(statesTrue_main{i},states));
            end
            
            %% ISOLATE PERSONAL "NEW" SESSION (Session 4)
            personal_new = isolateSession2(personal,new_session);
            
            %Extract data
            features_new     = personal_new.features; %features for classifier
            subjects_new     = personal_new.subject;  %subject number
            uniqSubjects_new = unique(subjects_new); %list of subjects
            statesTrue_new = personal_new.activity;     %all the classifier data
            subjectID_new = personal_new.subjectID;
            sessionID_new = personal_new.sessionID;
            
            %Remove stairs data from specific patient
            if ismember(IDs(y),patient_stairs)
                a = strmatch('Stairs Up',statesTrue_new,'exact');
                b = strmatch('Stairs Dw',statesTrue_new,'exact');
                stairs_remove = [a; b];
                features_new(stairs_remove,:) = [];
                subjects_new(stairs_remove) = [];
                statesTrue_new(stairs_remove) = [];
                subjectID_new(stairs_remove) = [];
                sessionID_new(stairs_remove) = [];
                uniqStates_new = unique(statesTrue_new);
            else
                uniqStates_new = unique(statesTrue_new);
            end
            
            %Generate codesTrue
            codesTrue_new = zeros(1,length(statesTrue_new));
            for i = 1:length(statesTrue_new)
                codesTrue_new(i) = find(strcmp(statesTrue_new{i},states));
            end
                        
            %% LAYER 1
            disp('      Initiating Layer 1...');
            posteriors_main = [];
            posteriors_new = [];
            
            temp = 1:length(IDs);
            temp(y) = []; %exclude current patient from the list of IDs
            
            for k = temp
                %% TEST INDIVIDUAL RFs (Layer 1)
                %Test on main sessions
                disp(['         Predicting with Patient: ' num2str(IDs(k))])
                
                [codesRF_main,P_RF_main] = predict(models(k).SCO,features_main);
                codesRF_main = str2num(cell2mat(codesRF_main));
                
                %Test on new sessions
                [codesRF_new,P_RF_new] = predict(models(k).SCO,features_new);
                codesRF_new = str2num(cell2mat(codesRF_new));
                
                %Collect posteriors
                posteriors_main = [posteriors_main P_RF_main];
                posteriors_new = [posteriors_new P_RF_new];
            end
            
            %% ADDITIONAL FEATURES
            featuresTR_main = getFeaturesTR(posteriors_main);
            featuresTR_new = getFeaturesTR(posteriors_new);
            
            %% LAYER 2: Train
            disp('      Initiating Layer 2...');
            
            %Random Forest (RF)
            RFmodel = TreeBagger(ntrees2,featuresTR_new,codesTrue_new,'OOBVarImp',OOBVarImp,'Options',opts_ag);
            
            %% LAYER 2: Test
            [codesRF_FINAL,P_RF_FINAL] = predict(RFmodel,featuresTR_main);
            codesRF_FINAL = str2num(cell2mat(codesRF_FINAL));
            [matRF, accRF] = confusionMatrix_5(codesTrue_main,codesRF_FINAL);
            
            %     %Linear Support Vector Machine (SVM)
            %     disp('Linear Support Vector Machine (SVM):')
            %     options = statset('UseParallel',1);
            %     template = templateSVM('KernelFunction', 'linear', 'PolynomialOrder', [], 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', 1);
            %     trainedClassifier = fitcecoc(featuresTR_new, codesTrue_new, 'Learners', template, 'FitPosterior', 1, 'Coding', 'onevsone', 'ResponseName', 'outcome','Options',options);
            %     [codesSVM_FINAL, ~, ~, ~] = predict(trainedClassifier,featuresTR_main);
            %     [matRF,accRF,~] = createConfusionMatrix(codesTrue_main,codesSVM_FINAL);
            %     disp(matRF)
            %     disp(accRF)
            
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
            if length(uniqStates_main) == 3 %no stairs
                ind = [1 4 5];
            elseif length(uniqStates_main) == 5 %stairs
                ind = [1:5];
            else
                error('Weird number of classes present in testing set')
            end
            correct = sum(matRF,2);
            diagonal = diag(matRF);
            BER = (1/length(ind)).*sum((correct(ind)-diagonal(ind))./(correct(ind)));
            BACC = 1-BER;
            
            %% COLLECT RESULTS
            results_stacked(y,q,w) = BACC;
        end
    end
end

%% PLOT DATA

%% SAVE DATA
save('results_stacked_optimize.mat','results_stacked')
fprintf('\n')
disp('Results saved (results_stacked_optimize.mat).')
open results_stacked
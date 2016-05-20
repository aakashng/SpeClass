%% Script patches the trainData_patient.mat file with desired changes
% Aakash Gupta (May 2016)

%% IMPORT trainData_Patient.mat FILE
clear
filename = ['trainData_patient.mat'];
load(filename)
disp('trainData_Patient.mat file imported.')

%% MODIFY CBR06 DATA (for transfer learning)
%Take CBR session on 1/20/16 and make it the 4th session
%1/20/16 only has stairs up data
%Adds stairs down data from one of the other sessions that has excess of
%stairs dw
disp('Patching CBR06-CBR data...')

%Get brace information
cData = trainingClassifierData; %temp copy
for zz = 1:length(trainingClassifierData.subject)
    temp = char(trainingClassifierData.subject(zz));
    cData.subjectBrace(zz) = {temp(7:9)};
end

%Locate Data
temp1 = strmatch('Cbr',cData.subjectBrace,'exact'); %brace indices
temp2 = find(cData.subjectID == 6); %subject indices
temp3 = find(cData.sessionID == 3); %session indices
temp4 = strmatch('Stairs Up',cData.activity,'exact'); %activity indices
ind = intersect(intersect(intersect(temp1,temp2),temp3),temp4); %find common indicides from four sets
if isempty(ind)
    error('Data not located.')
end

%Modify Data
ind_modify = ind(1:ceil(length(ind)/2)); %take first half of stairs up
trainingClassifierData.sessionID(ind_modify) = 1;
disp('trainData_Patient.mat file patched.')

%% EXPORT PATCHED trainData_Patient.mat FILE (overwrites)
save('trainData_patient.mat','trainingClassifierData','clipID')
disp('trainData_Patient.mat file exported and existing file overwritten.')
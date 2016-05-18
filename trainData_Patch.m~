%% Script patches the trainData_patient.mat file with desired changes
% Aakash Gupta (May 2016)

%% IMPORT trainData_Patient.mat FILE

disp('trainData_Patient.mat file imported.')

%% MODIFY CBR06 DATA (for transfer learning)
%Take CBR session on 1/20/16 and make it the 4th session
%1/20/16 only has stairs up data
%Adds stairs down data from one of the other sessions that has excess of
%stairs dw
disp('Patching CBR06-CBR data.')

for zz = 1:length(trainingClassifierData.subject)
    temp = char(trainingClassifierData.subject(zz));
    trainingClassifierData.subjectBrace(zz) = {temp(7:9)};
end

temp1 = strmatch('Cbr',trainingClassifierData.subjectBrace,'exact');
temp2 = find(trainingClassifierData.subjectID == 6);
cbr06_cbr = intersect(temp1,temp2);
if ~ismember(4,trainingClassifierData.sessionID(cbr06_ind))
    error('Fourth session for CBR06-CBR not found.')
end

disp('trainData_Patient.mat file patched.')

%% EXPORT PATCHED trainData_Patient.mat FILE (overwrites)

disp('trainData_Patient.mat file exported and existing file overwritten.')
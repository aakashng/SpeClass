function classifierData = isolateSession2(classifierData,sessions)

%sessions is a vector of the session ID numbers to isolate

    unique_sessions = unique(classifierData.sessionID);
    N = length(unique_sessions);

    ind_temp = ismember(classifierData.sessionID,sessions);
    ind = find(~logical(ind_temp));

    classifierData.activity(ind) = [];
    classifierData.wearing(ind) = [];
    classifierData.identifier(ind) = [];
    classifierData.subject(ind) = [];
    classifierData.features(ind,:) = [];
    classifierData.activityFrac(ind) = [];
    classifierData.subjectID(ind) = [];
    classifierData.sessionID(ind) = [];
    classifierData.states(ind) = [];

    try
        classifierData.subjectBrace(ind) = [];
    catch
    end
end

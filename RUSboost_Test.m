HealthyData = readtable('../Datasets/Cbrace/HealthyData.csv');
CBRData = readtable('../Datasets/Cbrace/CBRData3Sess.csv');
SCOData = readtable('../Datasets/Cbrace/SCOData3Sess.csv');
activities = {'Sit','Stairs Dw','Stairs Up','Stand','Walk'};

%% Train RUS boost on healthy and test on CBR data
rng(100)
Xtrain = table2array(HealthyData(:,3:end-1));
ytrain = table2array(HealthyData(:,end));

ntrees = 100;
t = templateTree('MinLeafSize',5); %deep trees
%     t = templateTree('MaxNumSplits',20); %deep trees
%     t = templateTree('MaxNumSplits',4); %shallow trees
RUS_H = fitensemble(Xtrain,ytrain,'RUSBoost',ntrees,t,'RatioToSmallest',[1 1 1 1 1],...
    'LearnRate',0.1,'nprint',10);

%test on each CBR patient
Npatients = length(unique(CBRData.SubjID));
PatientCodes = unique(CBRData.SubjID);
BACC_H = [];
for s = 1:Npatients
    data = CBRData(CBRData.SubjID==PatientCodes(s),:);
    disp(['Test on Patient ',num2str(PatientCodes(s))])
 
    Xtest = table2array(data(:,3:end-1)); ytrue = table2array(data(:,end));
    [ypred,~] = predict(RUS_H,Xtest); 
%     figure, plot(loss(RUS_H,Xtest,ytrue,'mode','cumulative'))

    %Accuracy
    cmat = confusionmat(ytrue,ypred,'order',[0 1 2 3 4])
    %BACC
    acc_c = 0;
    classes = unique(ytrue); Nclasses = length(classes);
    for c = 1:Nclasses
        i = ytrue == classes(c); %indices for class(c)
        correct = ypred(i) == ytrue(i);
        acc_c  = acc_c + sum(correct)/length(correct);
    end
    BACC = acc_c/Nclasses;
    BACC_H(s) = BACC
    
    results(s).ID = data.SubjID;
    results(s).n_act = Nclasses;
    results(s).n_train = size(Xtrain,1);
    results(s).cmat = cmat;
    results(s).BACC = BACC;

    
end
figure
boxplot(BACC_H)
disp(median(BACC_H))

%% plot confusion matrix (sum across all subjects)
thres = 0.6; %for text color

cmat_all = zeros(5,5);
for s = 1:length(results)
    cmat_all = results(s).cmat + cmat_all;
end
correctones = sum(cmat_all,2);
correctones = repmat(correctones,[1 length(activities)]);
cmat_all = cmat_all./correctones

figure, 
imagesc(cmat_all); 
colormap(gray)
colormap(flipud(colormap))
[cmin,cmax] = caxis;
caxis([0,1]) %set colormap to 0 1
ax = gca;
ax.XTick = 1:size(activities,2);
ax.YTick = 1:size(activities,2);
set(gca,'XTickLabel',activities)%'FontSize',14)
set(gca,'YTickLabel',activities)%'FontSize',14)
ax.XTickLabelRotation = 45;
axis square
title('Healthy model','FontSize',14), hold on
%add text
for i = 1:length(activities)
    for j = 1:length(activities)
        if cmat_all(i,j) > thres
            col = [1 1 1];
        else
            col = [0 0 0];
        end
        text(i-0.2,j,sprintf('%.3f',cmat_all(j,i)),'FontSize',14,'FontWeight','bold','Color',col);
    end
end

%% Global SCO
%train on all but 1 SCO patients

%test on each CBR patient
Npatients = length(unique(CBRData.SubjID));
PatientCodes = unique(CBRData.SubjID);
BACC_IS = [];
for s = 1:Npatients
    data = CBRData(CBRData.SubjID==PatientCodes(s),:);
    disp(['Test on Patient ',num2str(PatientCodes(s))])
 
    Xtest = table2array(data(:,3:end-1)); ytrue = table2array(data(:,end));
    [ypred,~] = predict(RUS_H,Xtest); 
%     figure, plot(loss(RUS_H,Xtest,ytrue,'mode','cumulative'))

    %Accuracy
    cmat = confusionmat(ytrue,ypred,'order',[0 1 2 3 4])
    %BACC
    acc_c = 0;
    classes = unique(ytrue); Nclasses = length(classes);
    for c = 1:Nclasses
        i = ytrue == classes(c); %indices for class(c)
        correct = ypred(i) == ytrue(i);
        acc_c  = acc_c + sum(correct)/length(correct);
    end
    BACC = acc_c/Nclasses;
    BACC_IS(s) = BACC
    
    results(s).ID = data.SubjID;
    results(s).n_act = Nclasses;
    results(s).n_train = size(Xtrain,1);
    results(s).cmat = cmat;
    results(s).BACC = BACC;

    
end
figure
boxplot(BACC_H)
disp(median(BACC_H))
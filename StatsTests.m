%Run stats tests on 5 models
results = csvread('./PyCode/results.csv')

[h,p]=ttest(results(:,1),results(:,2),'Tail','left')
[h,p]=ttest(results(:,2),results(:,3),'Tail','left')
[h,p]=ttest(results(:,3),results(:,4),'Tail','left')
[h,p]=ttest(results(:,4),results(:,5),'Tail','left')

[h,p]=signrank(results(:,1),results(:,2),'Tail','left')
[h,p]=signrank(results(:,2),results(:,3),'Tail','left')
[h,p]=signrank(results(:,3),results(:,4),'Tail','left')
[h,p]=signrank(results(:,4),results(:,5),'Tail','left')
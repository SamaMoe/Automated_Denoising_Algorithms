function [z] = CVSASS(y,lambdas,K,type)
% denoising using SASS with method of Cross-Validation for lambda tuning 
% Input
% y : noisy signal
% lambdas : set of regularization parameters
% K : number of cross-validation folds
% Output 
% z : denoised signal

x=linspace(1,length(y),length(y))';
dataframe=[x y];

% SASS fixed hyperparameters 
d = 2;          % d : filter order parameter (d = 1, 2, or 3)
fc = 0.05;     % fc : cut-off frequency (cycles/sample) (0 < fc < 0.5);
D = 2;          % K : order of sparse derivative

% Cross-validation
conf_scores = zeros([2, length(lambdas)]);
for i = 1:length(lambdas)
lam = lambdas(i);
% shuffle
shuffledData = shuffle(dataframe);
% split
folds = split(shuffledData,K);
% split data into train and test set
scores = zeros([1, K]);
for k = 1:K
[train_data,test_data]=splitdata(folds,k);

% predict signal value for test set
sorttrainData = sortrows(train_data,1);
ytrain = sorttrainData(:,2);
    
[ztrain, ~] = sass_L1(ytrain, d, fc, D, lam);
    
ztest = interp1(sorttrainData(:,1),ztrain,test_data(:,1),"pchip",'extrap');
    
augdata = [[sort(train_data(:,1)) ztrain];[test_data(:,1) ztest]]; 
sortedaugdata = sortrows(augdata,1);
zaug = sortedaugdata(:,2); 

% evaluate method on test data
score = evaluate(ztest,test_data(:,2),type);
scores(k) = score;
end
scores_mean = mean(scores);
scores_std = std(scores);
conf_scores(1,i) = scores_mean;
conf_scores(2,i) = scores_std;
end

% find best lambda
[min_CVerr,ind] = min(conf_scores(1,:));
opt_lam = lambdas(ind); % lam : regularization parameter

% compute optimal signal
[z, ~, ~, ~, ~, ~] = sass_L1(y, d, fc, D, opt_lam);

end
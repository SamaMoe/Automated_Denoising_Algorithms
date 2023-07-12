function [z] = VcurveSASS(y,lambdas)
% denoising using SASS with L- and V- curve for lambda tuning 
% Input
% y : noisy signal
% lambdas : set of regularization parameters
% Output z : denoised signal
d = 2;          % d : filter order parameter (d = 1, 2, or 3)
fc = 0.05;      % fc : cut-off frequency (cycles/sample) (0 < fc < 0.5);
K = 2;          % K : order of sparse derivative
 
Ps = zeros([1 length(lambdas)]); % store penalties for each lam
Rs = zeros([1 length(lambdas)]); % store residuals for each lam
xs = zeros([length(y) length(lambdas)]); % store estimated for each lam 

% L-curve
for i = 1:length(lambdas)
    lam = lambdas(i);
    [x, ~, ~, ~, P, R] = sass_L1(y, d, fc, K, lam);
    Ps(i) = P;
    Rs(i) = R;
    xs(:,i) = x;
end

% V-Curve
% Implementation follows "L- and V-curves for optimal smoothing"
%by Gianluca Frasso and Paul HC Eilers
 d3Mat = [log10(Rs) ; log10(Ps) ; lambdas]';
 d3MatB = sortrows(d3Mat,1);

% Compute V curve 
distance = zeros([1 length(lambdas)-1]);
lam = zeros([1 length(lambdas)-1]);
for i = 1:length(lambdas)-1
    distance(i) = sqrt((d3MatB(i+1,2)-d3MatB(i,2))^2 + (d3MatB(i+1,1)-d3MatB(i,1))^2);
    lam(i) = (d3MatB(i+1,3) + d3MatB(i,3))/2;
end 

% Find minimum distance
[M1,I] = min(distance);

% run SASS with optimal lambda
[z, ~, ~, ~, ~, ~] = sass_L1(y, d, fc, K, lam(I));

end
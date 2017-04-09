function [model] = pLDA(data, labels, thr)
% [model] = PCAnLDA(data, labels, thr)
%
% Input:
%   data
%   labels
%   thr
%
% Output:
%   model
%       P
%       X
%       W
%       thr
%       d
%       dOrder
%       thrX
%       thrW

% Written by Kelly Chang - October 7, 2016

%% Input Control

if size(data,1) ~= length(labels)
    error('Number of rows in data must match number of labels');
end

if ~exist('thr', 'var')
    thr = [];
end

if length(unique(labels)) > 2 && ~isempty(thr)
    error('Unable to implement d'' thresholding for categorizing more than 2 groups');
end

%% Training Model

model.P = PAQ(data');
model.X = (data * model.P)';
T = createLabels(labels);
model.W = (T * pinv(model.X))';

if ~isempty(thr)
    model.thr = thr;
    indx = (createLabels(labels,true) == 1);
    nDim = size(model.W,1);
    d = zeros(1, nDim);
    for i = 1:nDim
       [~,tmp] = max(model.X(i,:)' * model.W(i,:), [], 2);
       hit = sum(tmp(indx) == 1) / sum(indx);
       falseAlarm = sum(tmp(~indx) == 1) / sum(~indx);
       d(i) = dPrimeCorrected(hit, falseAlarm, indx);
    end
    
    [model.d,model.dOrder] = sort(d, 'descend');
    nDim = sum(model.d > thr);
    if nDim > 0
        model.thrX = model.X(model.dOrder(1:nDim),:);
        model.thrW = (T * pinv(model.thrX))';
    end 
end

end

function [P,a,Q] = PAQ(X)
    % Singular value decomposition of the I by J matrix X
    % X is a I*J matrix
    % P are the eigenvectors of X*X'
    % Q are the eigenvectors of  X'*X
    % a is the vector of the SINGULAR values
    % The eigenvectors and singular-values are ordered in decreasing order

    [Q,a] = eigen(X'*X); 
    k = min([size(X) max(size(a))]);
    Q = Q(:,1:k);
    a = sqrt(a(1:k));
    P = X * Q * inv(diag(a));
end

function [U,l] = eigen(X)
    % Compute the Eigenvalues and Eigenvectors of a semi positive definite 
    % matrix X.
    % U is the matrix of the eigenvectors.
    % l is the vector of the eigenvalues.
    % Eigenvectors & eigenvalues are sorted in decreasing order.
    % The eigenvectors are normalized: U'* U = I.
    % Eigenvalues smaller than epsilon = 0.000001 and
    % negative eigenvalues (due to rounding errors) are set to zero.
    % Herve' Abdi, September 1990.

    epsilon = 0.000001; % tolerance to be considered 0 for an eigenvalue
    [U,D] = eig(X);
    l = sort(diag(D), 'descend');
    U = U(:,end:-1:1); 
    % only keep non-zero eigen values (tolerance = epsilon)
    posIndx = l > epsilon;
    l = l(posIndx);
    U = U(:,posIndx);
    U = U ./ (ones(size(U,1),1) * sqrt(sum(U.^2))); % normalize U
end

function [d] = dPrimeCorrected(hit, falseAlarm, indx)
    hit = MacmillCreelman(hit, sum(indx));
    falseAlarm = MacmillCreelman(falseAlarm, sum(~indx));
    d = invGauss(hit) - invGauss(falseAlarm);
end

function [out] = MacmillCreelman(hitOrFalseAlarm, n)
    % Macmillan Creelman correction for perfect hit or false alarm 
    % before d'

    if hitOrFalseAlarm == 1 % 100%
        out = 1-(1/(2*n));
    elseif hitOrFalseAlarm == 0 % 0%
        out = 1/(2*n);
    else
        out = hitOrFalseAlarm;
    end
end

function [y] = invGauss(x)
    % Gives the inverse function of Gauss
    % invGauss(gauss(y)) = y
    % x should be 0 < x < 1
    % for valid results
    % answer for 0 is -Inf
    % answer for 1 is +Inf
    % Cf. Gauss
    % HA July 1993
    y = (erfinv((2*x-1)) * sqrt(2));
end
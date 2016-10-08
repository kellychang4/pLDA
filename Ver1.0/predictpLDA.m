function [predicted] = predictpLDA(model, data)
% [predicted] = predictPCAnLDA(model, data)
%
% Input:
%   model
%   data
%
% Output:
%   predicted

% Written by Kelly Chang - October 7, 2016

flds = {'', 'thr'};
thr = false;
if isfield(model, 'thr') && isfield(model, 'thrW')
    thr = true;
end

%% Predicting on Testing Set

xTest = (data * model.P)';

if thr
    xTest = xTest(model.dOrder(1:sum(model.d > model.thr)),:);
end

estTest = xTest' * model.(sprintf('%sW', flds{thr+1}));
[~,predicted] = max(estTest, [], 2);
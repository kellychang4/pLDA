function [X] = normrow(X)
% [X] = normrow(X)
%
% Normalizes each row of the given matrix X given by:
%                    X = X / norm(X)
%
% Input: 
%   X           A [i j] matrix to be normalized by row
%
% Output:
%   X           The given X matrix normalized by row

% Written by Kelly Chang - October 6, 2016

X = cell2mat(cellfun(@(x) x/norm(x), num2cell(X,2), 'UniformOutput', false));
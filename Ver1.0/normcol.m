function [X] = normcol(X)
% [X] = normcol(X)
%
% Normalizes each column of the given matrix X given by:
%                    X = X / norm(X)
%
% Input: 
%   X           A [i j] matrix to be normalized by column
%
% Output:
%   X           The given X matrix normalized by column

% Written by Kelly Chang - October 6, 2016

X = cell2mat(cellfun(@(x) x/norm(x), num2cell(X,1), 'UniformOutput', false));
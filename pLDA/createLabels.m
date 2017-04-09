function [T] = createLabels(labels, index)

if ~exist('index', 'var')
    index = false;
end

groups = unique(labels);
T = zeros(length(groups), length(labels));
for i = 1:length(groups)
    T(i,strcmp(labels,groups{i})) = 1;
end

if index
    [~,T] = max(T);
end
function result = local_function()
% This function can be executed locally on the End-Users computer. The
% function multiplies each element in the matrix A = [2 4 6; 8 10 16; 14 16 18] 
% individually.
%
% To use execute the function locally, use command:
%
% result = local_function()

% Copyright 2010-2013 Techila Technologies Ltd.

A = [2 4 6; 8 10 16; 14 16 18]; % Create matrix A
Imax=size(A,1); % Number of rows
Jmax=size(A,2); % Number of columns

for i = 1:Imax
    for j = 1:Jmax
        result(i,j) = A(i,j)*2; % Multiply each element individually
    end
end

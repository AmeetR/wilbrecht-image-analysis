function result = run_nested_loop()
% This file contains the Local Control Code and is used to distribute 
% computations to the Techila environment with peach.
%
% To create the computational project, use command:
%
% result = run_nested_loop() 

% Copyright 2010-2013 Techila Technologies Ltd.

A = [2 4 6; 8 10 16; 14 16 18]; % Create matrix A 
siz=size(A); % Get the size of the matrix 
jobs=siz(1)*siz(2); % Set number of jobs equal to the amount of elements 

result=peach('nested_dist',{'<param>',siz,A}, 1:jobs); % Create the project

result=reshape(cell2mat(result),siz); %Reshape to a 2-D matrix
end

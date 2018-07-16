function result = run_data_files() 
% This file contains the Local Control Code and is used to distribute 
% computations to the Techila environment with peach. A file named
% "datafile.mat" will be transferred with each Job. The datafile.mat file 
% contains a 10x10 matrix and each Job will calculate the mean value of one 
% column in this matrix.
%
% To create the computatational Project, use command: 
%
% result = run_data_files()

% Copyright 2010-2013 Techila Technologies Ltd.

jobs=10; % Set the number of jobs to 10, which is equal to the number of 
         % columns in the "datafile" matrix

result=peach('data_dist',{'<param>'},{'datafile.mat'},1:jobs); % Create the Project. 
result = cell2mat(result); % Convert cell array to a vector.
end

function result = run_snapshot(jobs, loops)
% This function contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% The m-file named "snapshot_dist.m" will be compiled and distributed to Workers.
% The "loops" parameter will be transferred to all Jobs with the params array. 
% The peachvector will be used to control the number of Jobs in the Project.
%
% Snapshotting will be implemented with the default values, as the Local Control Code
% does not specify otherwise.
%
% To create the Project, use command:
%
% result = run_snapshot(jobs, loops)
%
% jobs = number of jobs
% loops = number of iterations performed in each Job

% Copyright 2010-2013 Techila Technologies Ltd.

result = peach('snapshot_dist', {loops}, 1:jobs); % Create the computational Project
 
result = sum(cell2mat(result))* 4 / (loops * jobs);

end

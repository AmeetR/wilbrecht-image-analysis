function result = run_mcpi(jobs, loops) 
% This function contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% The m-file named "mcpi_dist.m" will be compiled and distributed to Workers.
% The "loops" parameter will be transferred to all Jobs with the params array. 
% The peachvector will be used to control the number of Jobs in the Project.
% The "result" variable will contain all the individual Job results as
% elements of a cell array.
%
% To create the Project, use command:
%
% result = run_mcpi(jobs, loops) 
%
% jobs = number of jobs
% loops = number of iterations performed in each Job

% Copyright 2010-2013 Techila Technologies Ltd.

result = peach('mcpi_dist', {loops}, 1:jobs);  

% Elements of the vector are summed and scaled according to the number of Jobs and
% number of loops in each Job.
result = sum(cell2mat(result))* 4 / (loops * jobs);  
 
end



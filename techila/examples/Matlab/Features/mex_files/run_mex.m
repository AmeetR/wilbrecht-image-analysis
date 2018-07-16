function result = run_mex(jobs,loops)
% This function contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% The m-file named "mcpi_wrapper.m" will be compiled and distributed to Workers.
% The "loops" parameter will be transferred to all Jobs with the params array. 
% The peachvector will be used to control the number of Jobs in the Project.
% THe MEX file named "mcpi.c" will be compiled and transferred with each Job.
% This MEX function will be called from the Worker Code.
%
% To create the Project, use command:
%
% result = run_mex(jobs,loops)
%
% jobs = number of jobs
% loops = number of iterations performed in each Job

% Copyright 2010-2013 Techila Technologies Ltd.

result = peach('mcpi_wrapper',{loops,'<param>'},1:jobs,...
'MexFiles',{'mcpi.c'});

result = sum(cell2mat(result));
result = 4 * result / (jobs * loops);
end


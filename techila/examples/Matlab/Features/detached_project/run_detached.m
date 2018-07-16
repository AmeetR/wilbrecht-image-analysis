function projectid = run_detached(jobs,loops)
% This file contains the Local Control Code, 
% which will be used to distribute computations to the Techila environment.
%
% The m-file named "mcpi_dist.m" will be compiled and distributed to Workers.
% The "loops" parameter will be transferred to all Jobs with the params array. 
% The peachvector will be used to control the number of Jobs in the Project.
% The peach function will return immediately after the computational data has
% been transferred to the server. The function will return the Project ID of the Project
% that was created.
%
% To create the Project, use command:
%
% projectid = run_detached(jobs,loops)
%
% jobs = number of jobs
% loops = number of iterations performed in each Job

% Copyright 2010-2013 Techila Technologies Ltd.

projectid = peach('mcpi_dist', {loops}, 1:jobs, ...
    'DoNotwait', 'true');
 
end
 



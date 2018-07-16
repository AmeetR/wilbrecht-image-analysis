%CLOUDOP   Executes given operation across all the jobs 
%
%[result]=cloudop(@op, data, target,[group])
%
% The method executes the given operation across all the jobs and returns
% the result to all jobs, or the target job.
%
% The parameters for cloudop are:
%
% op                       = Operation to be executed across all the jobs
% data                     = Matlab data to be used in the operation.
% target                   = The id of the target job for the result. 
%                            If not defined, the result is broadcasted to
%                            all jobs.
% group                    = The subset of jobs as a named group. If not
%                            defined, all the jobs in the project are
%                            included.
% Copyright 2015 Techila Technologies Ltd.

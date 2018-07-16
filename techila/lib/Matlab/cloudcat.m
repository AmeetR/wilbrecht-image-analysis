%CLOUDCAT   Concatenates the data across all the jobs.
%
%[result]=cloudcat(data, dim, target, [group])
%
% The method concatenates the data across all the jobs and returns
% the result to all jobs, or the target job.
%
% The parameters for cloudcat are:
%
% data                     = Matlab data to be used in the operation.
% dim                      = the dimension to be used for the concatenation
% target                   = The id of the target job for the result. 
%                            If not defined, the result is broadcasted to
%                            all jobs.
% group                    = The subset of jobs as a named group. If not
%                            defined, all the jobs in the project are
%                            included.
% Copyright 2015 Techila Technologies Ltd.

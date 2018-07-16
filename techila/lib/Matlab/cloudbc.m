%CLOUDBC   Broadcasts data from one job to all the other jobs
%
%[result]=cloudbc(data, srcid, [group])
%
% The method sends data from source job to all the other jobs in the
% project.
%
% The parameters for cloudbc are:
%
% data                     = Matlab data to be sent to the other jobs.
%                            Needs to be defined only in the source job.
% srcid                    = The id of the source job for the data. If not
%                            defined, the first job is used.
% group                    = The subset of jobs as a named group. If not
%                            defined, all the jobs in the project are
%                            included.
%
% Copyright 2015 Techila Technologies Ltd.

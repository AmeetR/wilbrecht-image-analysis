%SENDDATATOJOB   Sends data to other job
%
%sendDataToJob(jobid, data, doSerialize, [group])
%
% The parameters for sendDataToJob are:
%
% jobid                    = The id of the destination job
% data                     = The data to send to the destination job 
% doSerialize              = Data is serialized by default in
%                            sendDataToJob.
%                            If data is already serialized or not needed to
%                            be serialized, set this to false.
% group                    = The subset of jobs as a named group. If not
%                            defined, all the jobs in the project are
%                            included.
% Copyright 2015 Techila Technologies Ltd.

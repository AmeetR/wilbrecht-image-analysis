%RECVDATAFROMJOB   Receives data from other job
%
%[data, source]=recvDataFromJob(jobid, doDeserialize, [group])
%
% The method returns data and source jobid of the data.
%
% The parameters for recvDataFromJob are:
%
% jobid                    = The id of the source job
% doDeserialize            = Data is deserialized by default in
%                            recvDataFromJob. If data is not serialized or
%                            not needed to be deserialized, set this to
%                            false.
% group                    = The subset of jobs as a named group. If not
%                            defined, all the jobs in the project are
%                            included.
% Copyright 2015 Techila Technologies Ltd.

%COMMTECHILA   Communication between computational jobs in Techila
%
%[data, source]=commTechila(mode, jobid, data, doSerialize, doDeserialize, [group])
%
% The method returns data and source jobid of the data if mode is 'receive'
%
% The parameters for commTechila are:
%
% mode                     = 0 - receive data, 1 - send data, 2 -
%                            initialize, 3 - wait for other jobs, 
%                            -1 - uninitialize
% jobid                    = The id of the source job (mode=receive) or 
%                            the destination job (mode=send)
% data                     = The data to send to the destination job 
%                            (mode=send), or the length of the timeout
%                            in milliseconds (mode=initialize)
% doSerialize              = Data is serialized by default in commTechila.
%                            If data is already serialized or not needed to
%                            be serialized, set this to false.
% doDeserialize            = Data is deserialized by default in
%                            commTechila. If data is not serialized or not
%                            needed to be deserialized, set this to false.
% group                    = The subset of jobs as a named group. If not
%                            defined, all the jobs in the project are
%                            included.
% Copyright 2015 Techila Technologies Ltd.

%GETJOBID      Returns the id of the Techila job.
%
%jobid=getJobCount([group])
%
% group                    = The subset of jobs as a named group. If not
%                            defined, all the jobs in the project are
%                            included.
%
% Copyright 2015 Techila Technologies Ltd.
function jobid=getJobId(varargin)
try
    if nargin>0
        group = varargin{1};
    else
        group = [];
    end
    if ~isempty(group)
        jobid = techilaSendRequest(hex2dec('0203'), 2, 1, uint8(length(group)), group, 'uint32');
    else
        jobid = techilaSendRequest(hex2dec('0002'), 0, 1, 'uint32');
    end
catch
jobid=getenv('TECHILA_JOBID_IN_PROJECT');
end
end

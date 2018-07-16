%GETJOBCOUNT      Returns the number of Techila jobs in the project.
%
%jobs=getJobCount()
%
% Copyright 2015 Techila Technologies Ltd.
function jobs=getJobCount(varargin)
try
    if nargin>0
        group = varargin{1};
        jobs = techilaSendRequest(hex2dec('0204'), 2, 1, uint8(length(group)), group, 'uint32');
    else
        jobs = techilaSendRequest(hex2dec('0003'), 0, 1, 'uint32');
    end
catch
jobs=getenv('TECHILA_JOBCOUNT');
end
end

% printStatistics prints project statistics

% Copyright 2010-2012 Techila Technologies Ltd.

function printStatistics(handle, varargin)

Statistics = true;
for i=1:2:length(varargin)
    if strcmpi(varargin{i},'statistics')
        Statistics = getLogicalValue(varargin{i+1});
    end
end

global TECHILA_PROJECTS;
if Statistics
    stats=char(TECHILA_PROJECTS.getStatisticsString(handle));
    fprintf('%s', stats);
end

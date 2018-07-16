%createJob creates a job into project
%handle = techila handle
%params = job parameters

% Copyright 2010-2012 Techila Technologies Ltd.

function retval = createJob(handle, params, varargin)
global TECHILA_PROJECTS;

%% Initialize control parameters
Messages = true;
CacheJobs = true;

%% Parse optional control parameters
for i=1:2:length(varargin)
    if strcmpi(varargin{i},'messages')
        Messages = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i}, 'cachejobs')
        CacheJobs = getLogicalValue(varargin{i+1});
    end
end

%% Check parameters
if ((~iscell(params) && ~strcmp(params,'')))
    %    throw(MException('TECHILA:error', 'Error in createJob: parameters has to be in cells'));
    error('Error in createJob: parameters has to be in cells');
end

%% Converts project parameters to Java Hashtable
ht = java.util.Hashtable();
for i = 1:length(params)
    name = params{i}{1};
    value = params{i}{2};
    if isnumeric(value)
        if (length(value)>1)
            ht.put(java.lang.String(name), java.lang.String(mat2str(value)));
        else
            if round(value)==value
                ht.put(java.lang.String(name), java.lang.Integer.toString(value));
            else
                ht.put(java.lang.String(name), java.lang.Double.toString(value));
            end
        end
    else
        ht.put(java.lang.String(name), java.lang.String(value));
    end
end

%% Creates a job
if CacheJobs
    retval = TECHILA_PROJECTS.createCachedJob(handle, ht);
else
    retval = TECHILA_PROJECTS.createJob(handle, ht);
end

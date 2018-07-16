%setProjectParams set control parameters for the project
%handle = Techila handle
%params = control parameters

% Copyright 2010-2012 Techila Technologies Ltd.

function retval = setProjectParams(handle, params, varargin)
global TECHILA_PROJECTS;

%% Check parameters
if ((~iscell(params) && ~strcmp(params,'')))
    error('Error in setProjectParams: parameters has to be in cells');
end

%% Converts project parameters to Java Hashtable
ht = java.util.Hashtable();
for i = 1:length(params)
    name = params{i}{1};
    value = params{i}{2};
    if isnumeric(value)
        if (length(value)>1)
            cpht.put(java.lang.String(name), java.lang.String(mat2str(value)));
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

%% Set project parameters
retval = TECHILA_PROJECTS.setProjectParams(handle, ht);
end

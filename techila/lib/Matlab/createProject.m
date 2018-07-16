%createProject creates a project with given parameters
%handle      = techila handle
%priority    = project priority
%description = project description
%params      = project parameters

% Copyright 2010-2012 Techila Technologies Ltd.

function retval = createProject(handle, priority, description, params)
global TECHILA_PROJECTS;

%% Check parameters
if ((~iscell(params) && ~strcmp(params,'')))
    %    throw(MException('TECHILA:error', 'Error in createProject: parameters has to be in cells'));
    error('Error in createProject: parameters has to be in cells');
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

%% Create project
retval = TECHILA_PROJECTS.createProject(handle, priority, description, ht);
end

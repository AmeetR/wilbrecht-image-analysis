% createProjectJobs creates jobs into project
% handle       = techila handle
% commonparams = generic parameters for all the jobs (and control)
% jobparams    = job specific parameters

% Copyright 2010-2012 Techila Technologies Ltd.

function retval = createProjectJobs(handle, commonparams, jobparams)
global TECHILA_PROJECTS;
if ((~iscell(commonparams) && ~strcmp(commonparams,'')) || (~iscell(jobparams) && ~strcmp(jobparams,'')))
    %    throw(MException('TECHILA:error', 'Error in createProjectJobs: parameters has to be in cells'));
    error('Error in createProjectJobs: parameters has to be in cells');
end

%% Converts common parameters to Java Hashtable
cpht = java.util.Hashtable();
for i = 1:length(commonparams)
    name = commonparams{i}{1};
    value = commonparams{i}{2};
    if isnumeric(value)
        if (length(value)>1)
            cpht.put(java.lang.String(name), java.lang.String(mat2str(value)));
        else
            if round(value)==value
                cpht.put(java.lang.String(name), java.lang.Integer.toString(value));
            else
                cpht.put(java.lang.String(name), java.lang.Double.toString(value));
            end
        end
    else
        cpht.put(java.lang.String(name), java.lang.String(value));
    end
end

%% Converts project parameters to Java Hashtable
v = java.util.Vector();
for j = 1:length(jobparams)
    ht = java.util.Hashtable();
    params = jobparams{j};
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
    v.add(ht);
end

%% Create jobs
retval = TECHILA_PROJECTS.createProjectJobs(handle, cpht, v);

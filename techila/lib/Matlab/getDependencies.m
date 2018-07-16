%getDependencies list the dependencies of the function

% Copyright 2010-2014 Techila Technologies Ltd.

function [deplist, olddeps, toolboxes] = getDependencies(fun, olddeps, toolboxes, mode)
warning('off', 'MATLAB:DEPFUN:DeprecatedAPI')
deplist={};
if nargin==1
    olddeps={};
    toolboxes={};
    mode=0;
end
if exist(fun, 'file')==7
    deplist={fun};
    return;
end
if mode==0
    w=warning('off', 'MATLAB:mir_warning_maybe_uninitialized_temporary');
    warning('off', 'MATLAB:DEPFUN:DeprecatedAPI');
    if exist('depfun', 'file')
        try
            depfun('depfun', '-quiet');
            mode=2;
        catch ME
            % not found
        end
    end
    warning(w);
    if mode~=2
        a=which('matlab.codetools.requiredFilesAndProducts');
        if ~isempty(a)
            [deplist,pretb]=matlab.codetools.requiredFilesAndProducts(strrep(fun, '/', filesep));
            if nargout > 1
            toolboxes=[toolboxes findToolboxNames({pretb.Name})];
            end
            mode=1;
        end
    end
end
    
if mode==2
    funs={};
    try
        w=warning('off', 'MATLAB:mir_warning_maybe_uninitialized_temporary');
        warning('off', 'MATLAB:DEPFUN:DeprecatedAPI');
        funs=depfun(fun, '-quiet', '-toponly');
        warning(w);
    catch ME
        warning('PEACH:DepError', ['Error in checking dependencies: ' ME.message])
        deplist={};
        return;
    end
    i = 1;
    while i <= length(funs)
        if i>length(funs)
            break
        end
%        if ~(isempty(strfind(funs{i}, [matlabroot filesep 'toolbox'])) && isempty(strfind(funs{i}, 'cloudfor.m')) ...
%                && isempty(strfind(funs{i}, 'cloudfor.p')) && isempty(strfind(funs{i}, 'cloudend.m')) ...
%                && isempty(strfind(funs{i}, 'cloudend.p')) && (isempty(strcmp(funs{i}, olddeps)) || max(strcmp(funs{i}, olddeps)) == 0))
        if ~(isempty(strfind(funs{i}, [matlabroot filesep 'toolbox'])) && (isempty(strcmp(funs{i}, olddeps)) || max(strcmp(funs{i}, olddeps)) == 0))
            if ~(isempty(strfind(funs{i}, [matlabroot filesep 'toolbox'])))
                tb=strrep(funs{i},[matlabroot filesep 'toolbox' filesep],'');
                sep=strfind(tb, filesep);
                if ~isempty(sep)
                    tb=tb(1:sep-1);
                    if ~strcmp(tb,'matlab') && ~strcmp(tb,'shared') && isempty(intersect(toolboxes, tb))
                        toolboxes=unique([toolboxes {tb}]);
                    end
                end
            end
            funs(i)=[];
        else
            i = i + 1;
        end
    end
    deplist={};
    for i=2:length(funs)
        if (isempty(strcmp(funs{i}, olddeps)) || max(strcmp(funs{i}, olddeps)) == 0)
            [newdeplist, olddeps, toolboxes]=getDependencies(funs{i}, unique([funs{1:i-1}, deplist, olddeps]), toolboxes, mode);
            deplist = [deplist newdeplist];
        end
    end
    if ~isempty(funs)
    deplist=[funs(1) unique(deplist)];
    else
        deplist={fun};
    end
elseif mode==0
    deplist={fun};
end
for i=1:length(deplist)
    filename = deplist{i};
    filesuffix = [];
    extind = find(filename == '.', 1, 'last');
    if ~isempty(extind)
        filesuffix = filename(extind:end);
end
    if ~exist(filename, 'file')
        if isempty(filesuffix)
            newfilename=[filename '.m'];
            if exist(newfilename, 'file')
                deplist{i}=newfilename;
            else
                newfilename=[filename '.p'];
                if exist(newfilename, 'file')
                    deplist{i}=newfilename;
                end
            end
        end
    elseif isempty(regexpi(filesuffix, '\.mex.*|\.m$|\.p$'))
        deplist{i}=[];
    end
end
deplist = deplist(~cellfun(@isempty, deplist));
if nargin==1
    if sum(~cellfun(@isempty, [...
            regexp(deplist, '.*techilaSemaphoreRelease.*') ...
            regexp(deplist, '.*techilaSemaphoreReserve.*') ...            
            ])) > 0
        deplist=[deplist {which('techilaSemaphore')}];
    end    
    if sum(~cellfun(@isempty, [ ...
            regexp(deplist, '.*cloudbc.*') ...
            regexp(deplist, '.*cloudcat.*') ...
            regexp(deplist, '.*cloudop.*') ...
            ])) > 0
        deplist=[deplist {which('sendDataToJob')} {which('recvDataFromJob')}];
    end
    if sum(~cellfun(@isempty, [ ...
            regexp(deplist, '.*initIC.*') ...
            regexp(deplist, '.*sendDataToJob.*') ...
            regexp(deplist, '.*recvDataFromJob.*') ...
            regexp(deplist, '.*waitForOthers.*') ...
            ])) > 0
        deplist=[deplist {which('commTechila')} {which('hlp_serialize')} {which('hlp_deserialize')}];
    end
    if sum(~cellfun(@isempty, [ ...
            regexp(deplist, '.*getProjectJobCounts.*') ...
            regexp(deplist, '.*getProjectParameter.*') ...
            regexp(deplist, '.*getActiveProjects.*') ...
            regexp(deplist, '.*getActiveJobs.*') ...
            regexp(deplist, '.*getProjectParameter.*') ...
            regexp(deplist, '.*setProjectParameter.*') ...
            regexp(deplist, '.*getUserData.*') ...
            regexp(deplist, '.*setUserData.*') ...
            regexp(deplist, '.*storeUserFile.*') ...
            regexp(deplist, '.*restoreUserFile.*') ...
            regexp(deplist, '.*removeUserFile.*') ...
            regexp(deplist, '.*uploadToURL.*') ...
            regexp(deplist, '.*downloadFromURL.*') ...
            ])) > 0
        deplist=[deplist {which('techilaSendRequest')}];
    end
    deplist=unique(deplist);
end
end

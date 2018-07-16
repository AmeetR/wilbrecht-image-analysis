% Get the sum of the crcsums of the function and it's non-toolbox
% dependencies.

% Copyright 2010-2016 Techila Technologies Ltd.

function crcs = getFuncTreeCRCSum(fun, varargin)
if nargin==1
deps = getDependencies(fun);
else
    deps = varargin{1};
end
crcs=0;
for i=1:length(deps)
    if isdir(deps{i})
        crcs=getDirCRCSum(deps{i}, 0);
    elseif ~isempty(deps{i}) && isempty(regexp(deps{i}, '\.mex'))
        crcs=crcs+crcsum(deps{i});
    end
end
end

function crcs=getDirCRCSum(directory, crcs)
files=dir(directory);
for fi=1:length(files)
    file=files(fi);
    if strcmp(file.name, '.') || strcmp(file.name, '..')
        continue;
    end
    if file.isdir
        crcs=crcs+getDirCRCSum([directory '/' file.name], crcs);
    else
            crcs=crcs+crcsum([directory '/' file.name]);
    end
end
end

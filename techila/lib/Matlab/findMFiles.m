% Finds m and p files.

% Copyright 2010-2014 Techila Technologies Ltd.

function [mfiles,mdirs]=findMFiles(root)
files=dir(root);
mfiles=[];
mdirs=[];
dirs={files([files.isdir]==1).name};
for ind=1:size(dirs,2)
    if strcmp(dirs{ind},'.') || strcmp(dirs{ind},'..')
        continue
    end
    [newmfiles, newmdirs]=findMFiles([root '/' dirs{ind}]);
    mdirs=[mdirs, {[root '/' dirs{ind}]}];
    mdirs=[mdirs, newmdirs];
        mfiles=[mfiles, newmfiles];
end
for ind=1:size(files,1)
        if ~files(ind).isdir && ~isempty(regexp(files(ind).name, '\.[pm]$'))
            mfiles=[mfiles, {[root '/' files(ind).name]}];
    end
end
end

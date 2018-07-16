% Helper to prevent errors when MCC does not exist

% Copyright 2010-2012 Techila Technologies Ltd.

function [mcrmajor, mcrminor] = wrapmcrversion(varargin)
mcrmajor=0;
mcrminor=0;
mcrpreversion={};
for i=1:2:length(varargin)
    varname=varargin{i};
    varvalue=varargin{i+1};
    if (strcmpi(varname, 'mcrversion'))
        mcrpreversion=varvalue;
    end
end
if isempty(mcrpreversion)
    try
        if exist('mcrversion', 'file')
            [mcrmajor,mcrminor,point]=mcrversion();
            if point > 0
                mcrminor = [num2str(mcrminor) '.' num2str(point)];
            end
        end
    catch
    end
else
    splitted=regexp(mcrpreversion, '\.', 'split');
    if length(splitted) == 2
        mcrmajor=splitted{1};
        mcrminor=splitted{2};
    elseif length(splitted) == 3
        mcrmajor=splitted{1};
        mcrminor=[splitted{2} '.' splitted{3}];
    else
        error(['Invalid Matlab version specified ' mcrpreversion]);
    end
end
end

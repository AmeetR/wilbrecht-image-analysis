% installsdk - add Techila SDK toolbox to Matlab search path automatically

% Copyright 2010-2012 Techila Technologies Ltd.

function installsdk

pathstr = fileparts(mfilename('fullpath'));
addpath(pathstr);
savepath;
fprintf('Following path added to matlabpath: %s\n',pathstr);
end


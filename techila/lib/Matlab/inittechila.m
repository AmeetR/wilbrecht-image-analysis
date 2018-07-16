% inittechila    Initializes Techila functionality
%
% inittechila(SDKROOT, PATHTOINIT) Initializes Techila functionality with
% optional parameters SDKROOT and PATHTOINIT.
%
% SDKROOT tells the location of the Techila SDK. The default
%         value is ../../../
% PATHTOINIT tells the location of the Techila settings file. The default
%            value is <sdkRoot>/techila_settings.ini

% Copyright 2010-2012 Techila Technologies Ltd.

function statuscode = inittechila(sdkRoot, pathToInit)

init = '../../../techila_settings.ini';
libPath = '../../../lib';
if nargin>0
    libPath = [ sdkRoot '/lib/' ];
    init = [ sdkRoot '/techila_settings.ini' ];
    if nargin>1
        init = pathToInit;
    end
else
    sdkRoot='../../..';
    libPath = [ sdkRoot '/lib/' ];
    init = [ sdkRoot '/techila_settings.ini' ];
end

statuscode = techilainit('InitFile', init, 'LibPath', libPath, 'sdkRoot', sdkRoot);

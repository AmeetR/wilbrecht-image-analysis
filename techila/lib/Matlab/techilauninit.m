% techilauninit   Uninitializes Techila functionality (and frees resources)

% Copyright 2010-2012 Techila Technologies Ltd.

function techilauninit(varargin)
global TECHILA
if ~isempty(TECHILA)
    if TECHILA.isInitialized
        TECHILA.unload(true);
    end
    TECHILA=[];
end
end


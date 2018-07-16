%checkResultsRequired check that the required amount of results has been
%received

% Copyright 2010-2012 Techila Technologies Ltd.

function ok=checkResultsRequired(handle, ResultsRequired)
ok = false;
global TECHILA;
global TECHILA_PROJECTS;
if isnumeric(ResultsRequired)
    h = TECHILA.getHandle(handle);
    ready = h.getReady();
    if ready >= ResultsRequired
        ok = true;
    end
else
    ready = TECHILA_PROJECTS.ready(handle);
    req = str2num(strrep(ResultsRequired,'%',''));
    if ~isnumeric(req)
        error('Unable to parse ResultsRequired');
    end
    if req > 100
        req = 100;
    end
    if ready >= req
        ok = true;
    end
end
end

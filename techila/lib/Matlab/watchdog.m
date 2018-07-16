%watchdog Helper function for stopping the project in error cases

% Copyright 2010-2012 Techila Technologies Ltd.

function watchdog(obj, event, handle, TECHILA)
global TECHILA_WATCHDOG_OK
global TECHILA_WATCHDOG_TIMER
% If everything is ok, the global variable has been set to true, otherwise
% the variable stays false as set on the last line of this code
if length(TECHILA_WATCHDOG_OK) > handle && ~isempty(TECHILA_WATCHDOG_OK{handle+1}) && TECHILA_WATCHDOG_OK{handle+1} == false
    TECHILA_PROJECTS=TECHILA.projectManager;
    pid = TECHILA_PROJECTS.getProjectId(handle);
    if pid > 0
        warning(['Watchdog timed out, stopping project ' num2str(pid) '.']);
        TECHILA_PROJECTS.stopProject(handle);
        TECHILA.close(handle);
    end
    % Remove the watchdog timer
    timer = TECHILA_WATCHDOG_TIMER{handle+1};
    if isa(timer, 'timer')
        stop(timer);
        delete(timer);
    end
    TECHILA_WATCHDOG_TIMER{handle+1}=[];
    TECHILA_WATCHDOG_OK{handle+1}=[];
else
    TECHILA_WATCHDOG_OK{handle+1} = false;
end

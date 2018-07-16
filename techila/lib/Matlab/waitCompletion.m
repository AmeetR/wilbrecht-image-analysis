% waitCompletion waits for the project completion
% handle = project handle

% Copyright 2010-2012 Techila Technologies Ltd.

function waitCompletion(handle, varargin)
WaitStarted = tic();

%% Initialize control parameters
Messages = true;
TimeLimit = 0;
ResultsRequired = 1;

%% Parse optional control parameters
for i=1:2:length(varargin)
    if strcmpi(varargin{i},'messages')
        Messages = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i}, 'timelimit')
        TimeLimit=varargin{i+1};
    elseif strcmpi(varargin{i}, 'resultsrequired')
        ResultsRequired=varargin{i+1};
    end
end

%% Techila methods
global TECHILA;
global TECHILA_PROJECTS;

%% Starts a new background thread for supervising the project completion.
checkStatusCode(TECHILA_PROJECTS.waitCompletionBG(handle));
strlen = 0;

%% Watchdog
% Global variables to support watchdog: if the value is false when the
% watchdog function is executed, the project will be stopped and the Techila
% unloaded
global TECHILA_WATCHDOG_OK TECHILA_WATCHDOG_TIMER;
cleanupObj = onCleanup(@() watchDogCleanupFun(handle));
TECHILA_WATCHDOG_OK{handle+1} = true;
% Timer to stop the project if the execution has been interrupted
% (ctrl-c)
if length(TECHILA_WATCHDOG_TIMER) <= handle || isempty(TECHILA_WATCHDOG_TIMER{handle+1})
    TECHILA_WATCHDOG_TIMER{handle+1} = timer('TimerFcn', {@watchdog, handle, TECHILA}, 'Period', 15, 'ExecutionMode', 'FixedRate');
    start(TECHILA_WATCHDOG_TIMER{handle+1});
end
if Messages
    fprintf('Completed: ');
end

%% Wait for completion
while (TECHILA_PROJECTS.isCompleted(handle) ~= true)
    % Returns the completion level of the project in whole percents.
    ready = TECHILA_PROJECTS.ready(handle);
    if ready < 0
        break;
    end
    if Messages
        for bs = 1:strlen
            fprintf('\b');
        end
        strlen = fprintf('%i%%', ready);
    end
    if TimeLimit > 0 && checkResultsRequired(handle, ResultsRequired) && toc(WaitStarted) >= TimeLimit
        TECHILA_PROJECTS.stopProject(handle);
        break;
    end
    % Waits for any changes in the project status, or maximum 1 second.
    if TECHILA_PROJECTS.isCompleted(handle) ~= true
        TECHILA_PROJECTS.actionWait(1000);
    end
    % Set the watchdog variable true (everything is ok)
    TECHILA_WATCHDOG_OK{handle+1} = true;
end

%% Cleanup watchdog
% Remove the watchdog timer (the project has been completed or failed)
timerobj = TECHILA_WATCHDOG_TIMER{handle+1};
if isa(timerobj, 'timer')
    stop(timerobj);
    delete(timerobj);
end
TECHILA_WATCHDOG_TIMER{handle+1}=[];
if Messages
    for bs = 1:strlen
        fprintf('\b');
    end
end

%% Handle errors
if  (TECHILA_PROJECTS.isFailed(handle))
    if Messages
        fprintf('failed\n');
    end
    throw(MException('TECHILA:projectfailed', 'Fatal error(s) in the project: execution of the jobs has failed.'));
else
    if Messages
        fprintf('100%%\n');
    end
end
end

function watchDogCleanupFun(handle)
global TECHILA_WATCHDOG_OK TECHILA_WATCHDOG_TIMER TECHILA;
if length(TECHILA_WATCHDOG_OK) > handle && ~isempty(TECHILA_WATCHDOG_OK{handle+1})
    timerobj = TECHILA_WATCHDOG_TIMER{handle+1};
    if isa(timerobj, 'timer')
        stop(timerobj);
        delete(timerobj);
        TECHILA_WATCHDOG_TIMER{handle+1}=[];
        TECHILA_WATCHDOG_OK{handle+1}=[];
        TECHILA_PROJECTS=TECHILA.projectManager;
        pid = TECHILA_PROJECTS.getProjectId(handle);
        if pid > 0
            resp = input(['\nInterrupted. Project ' num2str(pid) ' is still running, do you want to interrupt it (y/n)? '], 's');
            if ~isempty(resp) && strncmpi(resp, 'y', 1)
                TECHILA_PROJECTS.stopProject(handle);
                TECHILA.close(handle);
            end
        end
    end
end
end

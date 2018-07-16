%waitAndRetrieveResults waits and downloads the project results

% Copyright 2010-2012 Techila Technologies Ltd.

function resultfiles=waitAndRetrieveResults(handle)
global TECHILA_PROJECTS;
global TECHILA_RESULTS;
%% Starts a new background thread for supervising the project completion.
checkStatusCode(TECHILA_PROJECTS.waitCompletionBG(handle));
strlen = 0;
fprintf('Completed: ');
while (TECHILA_PROJECTS.isCompleted(handle) ~= true)
    % Returns the completion level of the project in whole percents.
    ready = TECHILA_PROJECTS.ready(handle);
    for bs = 1:strlen
        fprintf('\b');
    end
    strlen = fprintf('%i%%', ready);
    % Waits for any changes in the project status, or maximum 60 seconds.
    TECHILA_PROJECTS.actionWait(60000);
end
for bs = 1:strlen
    fprintf('\b');
end
fprintf('100%%\n');
if (TECHILA_PROJECTS.isFailed(handle))
    checkStatusCode(TECHILA_PROJECTS.getLastError(handle));
end
%% Downloads the compressed result file of the project.
checkStatusCode(TECHILA_RESULTS.downloadResult(handle));

%% Extracts the compressed result file to the partial result files.
checkStatusCode(TECHILA_RESULTS.unzip(handle));

%% Lists the partial result files to the variable.
resultfiles = TECHILA_RESULTS.getResultFiles(handle);
end

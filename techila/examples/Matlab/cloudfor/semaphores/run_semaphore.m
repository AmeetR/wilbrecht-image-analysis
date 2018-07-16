function result = run_semaphore()
% This function contains the cloudfor-loop, which will be used to distribute
% computations to the Techila environment.
%
% During the computational Project, semaphores will be used to limit the number
% of simultaneous operations in the Project.
%
% Syntax:
%
% result = run_semaphore()

% Copyright 2015 Techila Technologies Ltd.

% Set the number of jobs to 4
jobs = 4;

% Container for the results
result = cell(jobs,1);

% The keywords 'cloudfor' and 'cloudend' have been used to mark the
% beginning and end of the block of code that will be executed on Workers.
% ------------------------------------------------------------------------
% The %cloudfor(key,value) parameters used in this example are explained below:
% ------------------------------------------------------------------------
% ('stepsperjob',1)             Sets the amount of iterations performed in
%                               each Job to one (1)
% ('outputparam',result)        Define that only variable 'result' will be 
%                               returned from the Job.
%
% ------------------------------------------------------------------------
% The %peach(key,value) parameters used in this example are explained below:
% ------------------------------------------------------------------------
% ('Semaphore', {'examplesema', 2})  Creates a Project-specific semaphore 
%                                    named 'examplesema', which will have 
%                                    two semaphore tokens.
cloudfor x=1:jobs
%cloudfor('stepsperworker', 1)
%peach('Semaphore', {'examplesema', 2})
%cloudfor('outputparam',result)
if isdeployed % Code inside this block will only be executed on Workers
    
    % Get current timestamp. This marks the start of the Job.
    jobStart = clock;
    
    % Reserve one token from the Project-specific semaphore 'examplesema'
    techilaSemaphoreReserve('examplesema');
    
    % Get current timestamp
    start = clock;
    
    % Generate CPU load for 30 seconds
    genload(30);
    
    % Calculate when the CPU load was generated relative to the start of the Job.
    twindowstart = etime(start, jobStart);
    twindowend = etime(clock, jobStart);
    
    % Store the time window in the result cell array.
    result{x}.pstatus = ['Project-specific semaphore reserved '...
        'for the following time window: '...
        num2str(twindowstart) '-'  num2str(twindowend)];
    
    % Release the 'examplesema' semaphore token
    techilaSemaphoreRelease('examplesema');
        
    % Attempt to reserve a token from the global semaphore 'globalsema'
    reservedok = techilaSemaphoreReserve('globalsema', true, 200, true);
    if reservedok % This block will be executed if the semaphore was reserved ok.
        start2 = clock;
        genload(5);
        twindowstart = etime(start2, jobStart);
        twindowend = etime(clock, jobStart);
        % Release the global semaphore token
        techilaSemaphoreRelease('globalsema', true);
        result{x}.gstatus = ['Global semaphore reserved '...
        'for the following time window: '  num2str(twindowstart)...
        '-'  num2str(twindowend)];
    elseif ~reservedok % This block will be executed a semaphore token could not be reserved
        result{x}.gstatus = 'Error when using global semaphore.';
    end
end
cloudend

% Print the results.
for x=1:jobs
    fprintf('Results from Job #%s\n',num2str(x))
    disp(result{x}.pstatus)
    disp(result{x}.gstatus)
end
end

function genload(duration)
% Simple function for generating CPU load for X seconds.
a=tic;
while (toc(a) < duration)
    rand;
end
end


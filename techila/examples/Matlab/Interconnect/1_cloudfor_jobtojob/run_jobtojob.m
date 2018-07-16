function jobres = run_jobtojob()
% This function contains the cloudfor-loop, which will be used to distribute
% computations to the Techila environment.
%
% This code will create a Project, which will have 2 Jobs. Each Job will send
% a short string to the other Job in the Project by using the Techila
% interconnect feature.
%
% To create the Project, use command:
%
% jobres = run_jobtojob()

% Copyright 2015 Techila Technologies Ltd.
steps=2; % Set total number of iterations to 2
cloudfor x=1:steps
%cloudfor('stepsperjob',1)
%%peach('ProjectParameters',{{'techila_worker_group','IC Group 1'}})
if isdeployed % Code inside this 'if' block will only be executed on Workers.
    if x == 1 % Job #1 will execute this block
        sendDataToJob(2,'Hi from Job 1'); % Send message to Job #2
        jobres{x} = recvDataFromJob(2);   % Receive message from Job #2
    end
    if x == 2 % Job #2 will execute this block
        jobres{x} = recvDataFromJob(1); % Receive message from Job #1
        sendDataToJob(1,'Hi from Job 2'); % Send message to Job #1
    end
    % Wait until all Jobs have reached this point before continuing
    waitForOthers()
end
cloudend
end
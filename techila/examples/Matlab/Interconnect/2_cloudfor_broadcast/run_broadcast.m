function jobres = run_broadcast(sourcejob,jobcount)
% This function contains the cloudfor-loop, which will be used to distribute
% computations to the Techila environment.
%
% During the computational Project, data will be broadcasted from one Job
% to all other Jobs in the Project. The broadcasted data will be returned
% from all Jobs.
%
% Syntax:
%
% jobres = run_broadcast(sourcejob,jobcount)
%
% sourcejob = Defines which Job will broadcast the data.
% jobcount = Defines the number of Jobs in the Project.
% 
% Example syntax (Job #2 broadcasts, 4 Jobs in total):
%
% jobres = run_broadcast(2,4)
%

% Copyright 2015 Techila Technologies Ltd.

cloudfor x=1:jobcount
%cloudfor('stepsperjob',1)
%%peach('ProjectParameters',{{'techila_worker_group','IC Group 1'}})
if isdeployed
    datatotransfer=['Hi from Job ' num2str(x)]; % Build the string that will be broadcasted
    jobres{x} = cloudbc(datatotransfer,sourcejob); % Broadcast the string to all other Jobs from 'sourcejob'
    waitForOthers() % Wait until all Jobs have reached this point before continuing
end
cloudend
end
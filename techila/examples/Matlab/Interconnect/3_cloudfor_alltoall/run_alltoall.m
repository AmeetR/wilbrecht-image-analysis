function dataall = run_alltoall()
% This function contains the cloudfor-loop, which will be used to distribute
% computations to the Techila environment.
%
% This code will create a Project, which will have 4 Jobs. Each Job will send
% a short string to all other Jobs in the Project by using the Techila
% interconnect feature.
%
% To create the Project, use command:
%
% dataall = run_alltoall()

% Copyright 2015 Techila Technologies Ltd.
cloudfor jobidx=1:4
%cloudfor('stepsperjob',1)
%%peach('ProjectParameters',{{'techila_worker_group','IC Group 1'}})
if isdeployed
    dataall=cell(1,4);
    jobcount=str2num(getenv('TECHILA_JOBCOUNT')); % Get the number of Jobs in the Project
    jobidx=str2num(getenv('TECHILA_JOBID_IN_PROJECT')); % Get the jobidx of the Job, values between 1-4.
    
    switch jobidx % Decide which string will be transferred from the Job
    case 1 
         msg='Hello from Job #1';
    case 2
         msg='Hello from Job #2';
    case 3
         msg='Hello from Job #3';
    case 4
         msg='Hello from Job #4';
    end
                
    % For loops for sending the data to all other Jobs.
    for src = 1:jobcount
        for dst = 1:jobcount
            if src == jobidx && dst  ~= jobidx
                sendDataToJob(dst,msg);
            elseif src ~= jobidx && dst == jobidx
                data = recvDataFromJob(src);
                dataall{jobidx} = [dataall{jobidx} data ', '];
            else
                disp('Do nothing')
            end
        end
    end
    dataall{jobidx} = dataall{jobidx}(1:end-2);  % Trim the output
    % Wait until all Jobs have reached this point before continuing
    waitForOthers()
end
cloudend
end
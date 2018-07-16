function result=run_cloudop()
% This function contains the cloudfor-loop, which will be used to distribute
% computations to the Techila environment.
%
% This code will create a Project, which will have 4 Jobs. Each Job will
% start by generating a random number locally. The 'cloudop' function will
% then be used to find the minimum value from these local variables.
% To create the Project, use command:
%
% result=run_cloudop()

% Copyright 2015 Techila Technologies Ltd.

result=zeros(1,4);
cloudfor x=1:4
%cloudfor('stepsperjob',1)
%%peach('ProjectParameters',{{'techila_worker_group','IC Group 1'}})
if isdeployed
    inputdata=rand(1); % Generate a locally defined random number
    result(x)=cloudop(@min, inputdata) % Search and return the smallest number using 'min'.
    waitForOthers() % Wait until all Jobs have reached this point before continuing
end
cloudend
disp(result) % Display the result
end
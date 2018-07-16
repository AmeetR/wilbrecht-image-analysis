function result = run_intermediate()
% This function will create a Project consisting of 2 Jobs. Each Job will
% use intermediate data helper functions to update the value of a variable.
%
% To run, use command: 
%
% result = run_intermediate()
%
% Copyright 2017 Techila Technologies Ltd.

jobs = 2; % Number of Jobs
result = zeros(1,jobs);

% The cloudfor 'imcallback' parameter defines that function 'myfunction'
% will be called each time new intermediate data has been received.
% TECHILA_FOR_IMRESULT keyword will be automatically replaced with a
% structure containing the intermediate data that was received.
cloudfor x = 1:jobs
%cloudfor('imcallback','myfunction(TECHILA_FOR_IMRESULT);')
if isdeployed
 a = 10 + x; % Set an arbitrary value to 'a' based on the loop index
 saveIMData('a'); % Send variable 'a' to the End-User as intermediate data
 loadIMData; % Wait until intermediate data has been received from End-User
 result(x) = a; % Return the updated value of 'a' as the result.
end
cloudend
end

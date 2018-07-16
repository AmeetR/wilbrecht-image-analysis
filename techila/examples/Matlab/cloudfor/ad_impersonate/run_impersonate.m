function run_impersonate()
% This function contains the cloudfor-loop, which will be used to distribute
% computations to the Techila environment.
%
% During the computational Project, Active Directory impersonation will be 
% used to run the Job under the End-User's own AD user account.
%
% Syntax:
%
% run_impersonate()

% Copyright 2015 Techila Technologies Ltd.

% Check which user account is used locally
[s,local_username]=dos('whoami');

% The keywords 'cloudfor' and 'cloudend' have been used to mark the
% beginning and end of the block of code that will be executed on Workers.
%
% AD impersonation has been enabled by setting the value of the 
% 'techila_ad_impersonate' Project parameter to true.
cloudfor x=1:1
    %peach('ProjectParameters',{{'techila_ad_impersonate','true'}})
    
    % Check which user account is used to run the computational Job.
    [s,worker_username]=dos('whoami');
cloudend

% Print the user account information
fprintf('Username on local computer: %s\n',local_username);
fprintf('Username on Worker computer: %s\n',worker_username);
end

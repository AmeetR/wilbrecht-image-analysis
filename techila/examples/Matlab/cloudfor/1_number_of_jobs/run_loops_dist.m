function result=run_loops_dist(loops)
% This function contains the 'cloudfor' version of the locally executable
% program. Calling this function will create a computational Project, where
% the multiplication operations will be executed on the Workers. Each Job will
% calculate two iterations of the loop structure.
%
% To use: result=run_loops_dist(loops)
%
% loops = The number of loops performed. The number of Jobs in the Project
%         will be loops/2.
%
% Example: result=run_loops_dist(10)
%
% The example shown above would create a Project consisting of five Jobs.

% Copyright 2011-2015 Techila Technologies Ltd.

result=zeros(1,loops); % Create an empty vector for the result values

% The keywords 'cloudfor' and 'cloudend' have been used to mark the
% beginning and end of the block of code that will be executed on Workers.
% ------------------------------------------------------------------------
% The %cloudfor(key,value) parameters used in this example are explained below:
% ------------------------------------------------------------------------
% ('stepsperjob',2)       Sets the number of iterations performed in each Job to
%                         two (2)
% ------------------------------------------------------------------------
cloudfor counter=1:loops % Beginning of the cloudfor-block
%cloudfor('stepsperjob',2)
    result(counter)=counter*counter;
cloudend % End of the cloudfor-block

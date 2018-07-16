function result=local_loops(loops)
% This function is executed locally on your computer and does not
% communicate with the Techila environment. This function contains a single
% 'for'-loop structure, where the iteration number 'counter' is squared
% each iteration.
%
% To use: result=local_loops(loops)
%
% loops = the number of loops performed
%
% Example: result=local_loops(10)

% Copyright 2011-2013 Techila Technologies Ltd.

result=zeros(1,loops); % Create an empty vector for the result values

% The locally executable for-loop structure.
for counter=1:loops                  % Set the number of iterations 
    result(counter)=counter*counter; 
end

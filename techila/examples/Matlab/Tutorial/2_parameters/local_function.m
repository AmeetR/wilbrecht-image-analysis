function result = local_function(multip,loops)
% This function can be executed locally on the End-Users computer. The
% function consists of a loop structure, where the value of the loop
% counter is multiplied with a fixed value.
%
% To use: result = local_function(multip,loops)
%
% multip = value of the multiplicator
% loops  = number of iterations

% Copyright 2010-2013 Techila Technologies Ltd.

for i = 1:loops
    result(i) = multip * i;
end


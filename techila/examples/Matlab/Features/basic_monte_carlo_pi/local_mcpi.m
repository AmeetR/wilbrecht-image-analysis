function result = local_mcpi(loops)
% This function can be executed locally on the End-Users computer. The function
% implements a Monte Carlo routine, which approximates the value of Pi. To
% execute the function locally, use command:
%
% result = local_mcpi(loops)
%
% loops = number of iterations performed in the Monte Carlo routine.

% Copyright 2010-2013 Techila Technologies Ltd.

count = 0; % Initialize the counter to zero as no points have been generated.
for i = 1:loops
    if ((sqrt(rand() ^ 2 + rand() ^ 2)) < 1) % Calculate the distance of the random point
        count = count + 1; % Increase counter if the distance is less than one.
    end
end
 
result = 4 * count/loops;  % Calculate the value of Pi based on the random number sampling.
                         
end

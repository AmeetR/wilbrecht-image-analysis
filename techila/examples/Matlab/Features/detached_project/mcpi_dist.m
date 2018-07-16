function result = mcpi_dist(loops) 
% This m-file contains the Worker Code, which will be compiled and distributed
% to the Workers. The values of the input parameters will be received from the
% parameters defined in the Local Control Code.

% Copyright 2010-2013 Techila Technologies Ltd.

result = 0; %No random points generated yet, init to 0.

for i = 1:loops %Monte Carlo loop from 1 to loops
    if ((sqrt(rand() ^ 2 + rand() ^ 2)) < 1) % Point within the circle?
        result = result + 1; % Increment if the point is within the circle.
    end
end
result = [result loops]; % Save result and value of the loops variable for post-processing.
end 

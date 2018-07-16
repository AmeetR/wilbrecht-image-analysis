function result = inputfiles_dist()
% This m-file contains the Worker Code, which will be compiled and distributed
% to the Workers. The Jobs will access their Job-specific input files with the
% name "quadrant.png", which is defined in the Local Control Code

% Copyright 2010-2013 Techila Technologies Ltd.

    inputdata = imread('quadrant.png'); % Load the Job-specific input file to memory
    result = length(find(inputdata==0));% Calculate the amount of black pixels
 
end

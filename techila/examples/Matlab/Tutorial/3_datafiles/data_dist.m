function result=data_dist(jobidx) 
% This m-file contains the Worker Code, which will be compiled and distributed
% to the Workers. The value of the jobidx parameter will be received from the
% peachvector, which is defined in the Local Control Code. Each job
% consists of calculating the mean value of one column in the datafile
% matrix.

% Copyright 2010-2013 Techila Technologies Ltd.

load('datafile.mat') % Load the contents of the datafile.mat file to the workspace
result=mean(datafile(:,jobidx)); % Calculate the mean value of a column.
end

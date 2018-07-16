function result = local_function()
% This function can be executed locally on the End-Users computer. The
% function calculates the mean value of each column in the datafile matrix.
%
%To execute the function locally, use command:
%
%result = local_function()

% Copyright 2010-2013 Techila Technologies Ltd.

load datafile.mat
for i=1:10
    result(i)=mean(datafile(:,i));
end

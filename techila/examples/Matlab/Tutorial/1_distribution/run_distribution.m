function result = run_distribution(jobs)
% This file contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% Note! Before running the example, please ensure that the path 
% techila\lib\Matlab is included in the matlabpath. The path can be added by 
% executing the installsdk function from the techila\lib\Matlab directory.
% Instructions for this are provided in the document Techila with
% MATLAB
%
% To use: result = run_distribution(jobs)
%
% jobs = the number of Jobs
% The computational Project is created with PEACH. The PEACH parameters are
% explained below:
% 'distribution_dist' =   The name of the m-file (no suffix) that will be 
%                         compiled and distributed to Workers. 
%                         In this example, the code in the m-file named
%                         "distribution_dist.m" will be compiled and
%                         distributed.
% {} =     The parameters array. Parameters inside the cell array will be transferred
%          to Jobs and can be used as input parameters by the Worker Code. In
%          this example, the cell array is empty, which indicates that no
%          parameters are transferred to Jobs.
% 1:jobs = The peachvector. The length of the peachvector will determine the
%          number of Jobs in the Project. When applicable, elements of the 
%          peachvector will be transferred to Jobs, each Job receiving a different
%          element. In this example, the peachvector is only used to
%          determine the number of jobs, no parameters are transferred.
% result = PEACH result vector. Results of individual jobs are stored in an
%          cell array, each cell element storing the result of one (1) Job.

% Copyright 2010-2013 Techila Technologies Ltd.

result = peach('distribution_dist',{},1:jobs);  % Create the computational project

result = cell2mat(result);  % Convert cell array to a single vector
end

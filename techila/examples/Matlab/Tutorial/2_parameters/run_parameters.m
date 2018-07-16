function result = run_parameters(multip,jobs)
% This function contains the Local Control Code and is used to distribute
% computations to the Techila environment with peach.
%
% To use: result = run_parameters(multip,jobs)
%
% multip = a static parameter, which is the same for all jobs
% jobs = the number of Jobs. Also defines the elements of the peachvector
%         which are transferred to the Jobs as input parameters with the
%         '<param>' notation.

% Copyright 2010-2013 Techila Technologies Ltd.

result = peach('parameter_dist',{multip,'<param>'},1:jobs);  % Create the Project.
result = cell2mat(result); % Convert cell array to a vector.
end

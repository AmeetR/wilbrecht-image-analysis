function result = run_inputfiles()
% This function contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% The m-file named "inputfiles_dist" will be compiled and distributed to Workers.
% Job specific input files will be transferred with each Job, each Job receiving
% one input file.
%
% To create the Project, use command:
%
% result = run_inputfiles()
%
% Note: The number of Jobs in the Project will be automatically set to four.

% Copyright 2010-2013 Techila Technologies Ltd.

jobs = 4;
result=peach('inputfiles_dist',{},1:jobs,...
    'JobInputFiles', {{'input1.png'},{'input2.png'},{'input3.png'},{'input4.png'}},...
    'JobInputFileNames',{'quadrant.png'});

result = 4*(sum(cell2mat(result))/1e6);
 
end

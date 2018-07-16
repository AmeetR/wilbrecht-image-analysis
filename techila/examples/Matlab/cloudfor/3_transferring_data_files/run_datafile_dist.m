function result = run_datafile_dist()
% This function contains the 'cloudfor' version of the locally executable
% program. Calling this function will create a computational Project, where
% the input files are transferred to Workers and output files returned to
% your computer. Each Job will calculate one iteration of the loop structure.
%
% To use: result = run_datafile_dist()

% Copyright 2011-2015 Techila Technologies Ltd.

result=cell(1,3);     % Empty cell array for results
loops=length(result); % Set the number of loops to 3.

% The keywords 'cloudfor' and 'cloudend' have been used to mark the
% beginning and end of the block of code that will be executed on Workers.
% ------------------------------------------------------------------------
% The %cloudfor(key,value) parameters used in this example are explained below:
% ------------------------------------------------------------------------
% ('stepsperjob',1)              Sets the amount of iterations performed in
%                                each Job to one (1)
% ('resultfilevar',filelist)     Stores the names of the output files to the
%                               'fileslist' variable
%
% ('donotimport','true')         Only add result files to the file list, 
%                                do not load result files.
%
% ('datafile',input_1.mat,...
%                input_2.mat)    Transfers files 'input_1.mat' 
%                                and to Workers 'input_2.mat' to Workers
% ('datafile',input_3.mat        Transfers file 'input_3.mat' to Workers
%
% ('stream','false')             Disable result streaming
% ------------------------------------------------------------------------
% The %peach(key,value) parameters used in this example are explained below:
% ------------------------------------------------------------------------
% ('OutputFiles','output_dist.*;...
%  regex=true')                 Defines that all files beginning with
%                               'output_dist' should be transferred back to
%                               your computer
% ------------------------------------------------------------------------

cloudfor k=1:loops
    %cloudfor('stream','false')
    %cloudfor('stepsperjob',1)
    %cloudfor('resultfilevar',filelist)
    %cloudfor('donotimport','true')
    %peach('OutputFiles','output_dist.*;regex=true')
    %cloudfor('datafile',input_1.mat,input_2.mat)
    %cloudfor('datafile',input_3.mat)


    load(['input_' num2str(k) '.mat']);          % Load variables from the file
    result1=conv2(x,y,'same');                   % Perform conv2 operation with 'x' and 'y'
    result2=filter2(x,y);                        % Perform filter2 operation with 'x' and 'y'
    filename=['output_dist' num2str(k) '.data'];% Filename depends on the iteration number
    save(filename,'result1','result2');          % Save variables to the file
cloudend

% The second loop will load the output files and store the variables to the
% result vector. An additional line has been added that will unzip the
% result files to the current working directory.
for j=1:loops          % Loop structure for reading the result files
    unzip(filelist{j}) % Unzip the result file to the current working directory
    result{j}=load(['output_dist' num2str(j) '.data'],'-mat'); % Store the result in to the variable
end

end

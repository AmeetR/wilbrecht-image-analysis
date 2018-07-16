function result=local_datafile()
% This function is executed locally on your computer and does not
% communicate with the Techila environment. The function contains two
% 'for'-loops. One 'for' loop will load input files and create output files,
% the second 'for' loop will load the output files and store variables to 
% the output values. 
%
% To use: result=local_datafile()

% Copyright 2011-2013 Techila Technologies Ltd.

result=cell(1,3); % Empty cell array for results 
loops=length(result); % Set the number of loops to 3.

% In the first for-loop, data is loaded from the input files 
% and results stored in output files. The name of the input file and output
% file will depend on the iteration number
for k=1:loops
    load(['input_' num2str(k) '.mat']);          % Load variables from the file
    result1=conv2(x,y,'same');                   % Perform conv2 operation with 'x' and 'y'
    result2=filter2(x,y);                        % Perform filter2 operation with 'x' and 'y'
    filename=['output_local' num2str(k) '.data'];% Filename depends on the iteration number
    save(filename,'result1','result2');          % Save variables to the file
end

% The second loop will load the output files and store the variables to the
% result vector.
for j=1:loops % Loop structure for reading the result files
    result{j}=load(['output_local' num2str(j) '.data'],'-mat'); % Store the result in to a variable
end

end

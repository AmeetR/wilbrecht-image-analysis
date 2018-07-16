function result = run_binary(jobs,loops)
% This function contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% The executable binary named "mcpi.exe" will be distributed to Windows Workers
% and the "mcpi" binary to Linux workers. The binary will be executed with the 
% parameters defined in the Local Control Code. Both binaries are 64-bit, meaning
% only Workers that have a 64-bit operating system will be used.
%
% To create the Project, use command:
%
% result = run_binary(jobs,loops)
%
% jobs = number of jobs
% loops = number of iterations performed in each Job

% Copyright 2010-2015 Techila Technologies Ltd.

result=peach('Precompiled Binary', {['%P(jobidx) %P(loops) %O(output1)']}, 1:jobs,... 
    'Binaries', {{'mcpi.exe', 'Windows','amd64'},{'mcpi','Linux','amd64'}},...
    'Executable','true',... % Specify that the funcname refers to a precompiled binary.
    'MatlabRequired','false',... % MATLAB runtime libraries not required with the binary.
    'CallbackMethod', @getdata,... % The name of the callback function
    'ProjectParameters',{{'loops',loops}},... % Define the input parameters used by the binary
    'OutputFiles',{'data'}); % Define the name of the output file which will be transferred from the Workers
 
 result=4 * sum(cell2mat(result)) / (loops * jobs); % Calculate the value of Pi based on the downloaded results
 
end
  
function result = getdata(f) % The callback function, input parameter will contain the location of the result file
  
  result = load(char(f)); % Load the contents of the result file to memory
  result = result(1);   % Use the number first value in the result variable. 
 			% This value will be stored as an element in the peach result vector.
  
end

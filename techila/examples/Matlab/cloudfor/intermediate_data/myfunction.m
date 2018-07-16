function myfunction(imdata)
% Intermediate callback function. Called each time new intermediate data
% has been received.
%
% Copyright 2017 Techila Technologies Ltd.

jobidx = imdata.TechilaJobId; % The source Job Id 
disp(['Received intermediate data from Job #' num2str(jobidx)])
a = imdata.a; % Get value of variable 'a' that was received from the Job
disp(['Received variable "a" from Job. Value of variable is: ' num2str(a)])
a = a + 2;  % Increase value so we know the data has been modified by this function
disp(['Increased value of "a" to: ' num2str(a)])
disp(['Sending variable updated value of "a" as intermediate data to Job #' num2str(jobidx)])
sendIMData(jobidx, 'a'); % Send the updated value of 'a' back to the same Job
disp(['Finished sending intermediate data to Job #' num2str(jobidx)])
end
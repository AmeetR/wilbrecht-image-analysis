function run_pi_iteration()
% This function contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% The m-file named "mcpi_dist" will be compiled and distributed to Workers.
% Several consecutive Projects will be created, during which the value of Pi will
% be calculated using the Monte Carlo method. Results of the Projects will be used
% to improve the accuracy of the approximation. Projects will be created until
% the amount of error in the approximation is below the threshold value.
%
% To create the Projects, use command:
%
% run_pi_iteration()
%
% Note: The number of Jobs in the Project will be automatically set to 20.

% Copyright 2010-2013 Techila Technologies Ltd.

threshold = 2e-4;   % Maximum allowed error
n = 20;             % Number of Jobs
loops = 1e7;        % Number of iterations performed in each Job
total_result = 0;   % Initial result when no approximations have been performed.
iteration = 1;      % Project counter, first Project will 
current_error = pi; % Initial error, no approximations have been performed

if exist('restorepoint.mat')    % Is the computations are being resumed?
   load restorepoint            % Load intermediate results
end

techilainit(); % Initialize the Techila environment once

while abs(current_error) >= threshold
    result = sum(cell2mat(peach('mcpi_dist', {'<param>',iteration,loops}, 1:n,...
        'Messages','false',...      % Turn off messages
        'DoNotInit','true',...      % Do not initilize the Techila environment
        'DoNotUninit','true')));    % Do not uninitalize the Techila environment
    
    total_result = total_result + result;   % Add results of the current project to total results
    approximated_pi = total_result * 4 / (loops * n * iteration); % Calculate the approximated value of Pi
    current_error = approximated_pi - pi; % Calculate the current error 
    fprintf(1,'Amount of error in the approximation = %.16f\n',current_error); % Print the value of the current error
    iteration=iteration+1;                 
    save restorepoint iteration total_result % Save current computational results to a mat-file.
end
techilauninit(); % Uninitialize the Techila environment
fprintf('Error below threshold value, no more Projects required.\n')
fprintf('Approximated value of Pi = %g\n',approximated_pi) % Print the approximated value of Pi
delete('restorepoint.mat')
end


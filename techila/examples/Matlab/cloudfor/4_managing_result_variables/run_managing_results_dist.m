function [pi_value, primes]=run_managing_results_dist()
% This function contains the 'cloudfor' version of the locally executable
% program. Calling this function will create a computational Project, where
% the output values will be managed similarly as in the locally executable
% program.
%
% To use: [pi_value, primes]=run_managing_results_dist();

% Copyright 2011-2015 Techila Technologies Ltd.

iter_count=4e5; % Set the number of iterations
pi_counter=0; % Init to contain the value of the Pi approximation
primes=[]; % 0x0 matrix for the concatenated results

% The keywords 'cloudfor' and 'cloudend' have been used to mark the
% beginning and end of the block of code that will be executed on Workers.
% ------------------------------------------------------------------------
% The %cloudfor(key,value) parameters used in this example are explained below:
% ------------------------------------------------------------------------
% ('stepsperjob',1e4)           Sets the amount of iterations performed in
%                               each Job to one (1e4). Means the Project
%                               will contain 40 Jobs (4e5/1e4)
% ('cat',primes)                Concatenates the return values stored in
%                               'primes'.
% ('sum',pi_counter)            Sum the return values stored in 'pi_counter'
% ('stream','false')            Disable streaming, because concatenated
%                               results need to be in correct order
% ------------------------------------------------------------------------
cloudfor i_index = 1:iter_count
    %cloudfor('stepsperjob',1e4)
    %cloudfor('cat',primes)
    %cloudfor('stream','false')
    %cloudfor('sum',pi_counter)
    pi_counter = pi_counter+mcpi;
    if isprime(i_index) % Check if the i_index is a prime number
         % Increasing vector length makes this a slow method, used to
         % highlight the concatenation of results.
         primes=[primes i_index];   % Add the prime number as the last element.
    end
cloudend
% Calculate the approximated value of Pi.
pi_value=4*pi_counter/iter_count;

% Print the results based on the operations performed
fprintf('\nThe approximate value of Pi is: %g\n\n',pi_value)
fprintf('Searched the interval from 1 to %s\n',num2str(iter_count))
fprintf('Last 10 prime numbers found: %s\n',num2str(primes(end-9:end)))
end

function res = mcpi()
% This function is used to generate a random point and to see if it is
% located within an unitary circle. This function is automatically included
% in the compilation and can be executed on Workers.
    res=0;
    dist = sqrt(rand()^2+rand()^2);
    if dist <= 1
        res=1;
    end
end

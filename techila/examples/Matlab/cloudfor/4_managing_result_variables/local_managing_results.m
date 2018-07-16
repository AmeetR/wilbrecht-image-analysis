function [pi_value, primes]=local_managing_results()
% This function is executed locally on your computer and does not
% communicate with the Techila environment. This function contains one
% 'for'-loop, which will create random points to approximate the value of
% Pi and for searching prime numbers.
%
% To use: [pi_value, primes]=local_managing_results();
%
% pi_value = Contains the approximate value of Pi
% primes   = Contains a list of prime numbers found. 

% Copyright 2011-2013 Techila Technologies Ltd.

iter_count=4e5; % Set the number of iterations
pi_counter=0; % Init to contain the value of the Pi approximation
primes=[]; % 0x0 matrix for the concatenated results

% Locally executable for loop
for i_index = 1:iter_count
    pi_counter = pi_counter+mcpi; % Increase pi_counter if 'mcpi' returns 1.
    if isprime(i_index) % Check if the i_index is a prime number
         % Increasing vector length makes this a slow method, used to
         % highlight the concatenation of results.
         primes=[primes i_index];   % Add the prime number as the last element.
    end  
end

% Calculate the approximated value of Pi.
pi_value=4*pi_counter/iter_count;

% Print the results based on the operations performed
fprintf('\nThe approximate value of Pi is: %g\n\n',pi_value)
fprintf('Searched the interval from 1 to %s\n',num2str(iter_count))
fprintf('Last 10 prime numbers found: %s\n',num2str(primes(end-9:end)))
end

function res = mcpi()
% This function is used to generate a random point and to see if it is
% located within an unitary circle. Called once for each iteration.
    res=0;
    dist = sqrt(rand()^2+rand()^2);
    if dist <= 1
        res=1;
    end
end

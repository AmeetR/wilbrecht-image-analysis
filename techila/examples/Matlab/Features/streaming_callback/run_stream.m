function result = run_stream(jobs,loops)
% This function contains the Local Control Code, which will be used to distribute 
% computations to the Techila environment.
%
% The m-file named "mcpi_dist.m" will be compiled and distributed to Workers.
% The "loops" parameter will be transferred to all Jobs with the params array. 
% The peachvector will be used to control the number of Jobs in the Project.
%
% Results will be streamed from the Workers in the order they will be completed.
% Results will be visualized by plotting them on a graph.
%
%
% To create the Project, use command:
%
% result = run_stream(jobs,loops)
%
% jobs = number of jobs
% loops = number of iterations performed in each Job 

% Copyright 2010-2013 Techila Technologies Ltd.

global total;global rj;global data;global fig; % Create global variables to be used in the callback function
 
data = inf(1,jobs); 
total = 0;
rj = 0;
 
figure(1);
fig=plot(data, 'YDataSource', 'data');
title('Amount of error in the Pi approximation');
ylabel('Amount of error');
xlabel('Number of Job result files processed');
drawnow;
 
result = peach('mcpi_dist', {loops}, 1:jobs, ...
    'StreamResults', 'true', ... % Enable streaming
    'CallbackMethod', @summc, ... % Name of the Callback function
    'CallbackParams', {loops, '<result>'}); % Parameters for the CB function
 
end
 
function result = summc(loops, val) % The Callback function
 
  global data; global fig; global rj; global total; 
  
  rj = rj + 1; 		% One more result file received
  total = total + val;  % Add new results to old results
  pivalue = total * 4 / (rj * loops); % New approximate value of Pi
  error = pivalue - pi; % Calculate the error 
  result = error;
  data(rj) = abs(result);
  if (mod(rj,10) == 0)   % Update figure when 10 more results are available
    refreshdata(fig, 'caller');
    drawnow;
  end
end

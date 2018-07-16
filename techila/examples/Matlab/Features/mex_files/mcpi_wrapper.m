function result = mcpi_wrapper(loops,jobidx)
% This m-file contains the Worker Code, which will be compiled and distributed
% to the Workers. The values of the input parameters will be received from the
% parameters defined in the Local Control Code.

% Copyright 2010-2013 Techila Technologies Ltd.

result=mcpi(loops,jobidx); % Call the MEX function using the parameters received from the Local Control Code.
end

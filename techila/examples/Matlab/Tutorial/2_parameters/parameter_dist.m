function result =  parameter_dist(multip,jobidx)
% This m-file contains the Worker Code, which will be compiled and distributed
% to the Workers. The value of the jobidx parameter is received from the
% peachvector, which was defined in the Local Control Code. The value of the 
% multip paramater is the same for each Job

% Copyright 2010-2013 Techila Technologies Ltd.

result = multip * jobidx;
end

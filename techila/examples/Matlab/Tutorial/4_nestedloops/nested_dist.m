function result = nested_dist(jobidx,siz,A)
% This m-file contains the Worker Code, which will be compiled and distributed
% to Workers. The value of the jobidx parameter will be replaced by an
% element of the peachvector, which is defined in the Local Control Code. Other
% parameters include the size of the matrix (siz) and the matrix A (A).

% Copyright 2010-2013 Techila Technologies Ltd.

%Convert the jobidx value to column and row coordinates
[i,j] = ind2sub(siz, jobidx); 
 
% Multiply the matrix element. This result is returned to the server.
result=2 * A(i,j); 
end

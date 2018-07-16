function result = local_workspace
% This function is executed locally on your computer and does not
% communicate with the Techila environment. The function contains two
% nested 'for'-loops. In each iteration, the iteration counters 'ii' and
% 'jj' will be multiplied. The multiplication result will be stored in a
% matrix.
%
% To use: result = local_workspace

% Copyright 2011-2013 Techila Technologies Ltd.

var1=[2 4 6]; % Length of 'var1' will define number of outer loop iterations
var2=[11 51 100]; % Length of 'var1' will define number of inner loop iterations
dummyvar=rand(2000); % Create a dummy variable, not used in computations
result=zeros(length(var1),length(var2)); % Create empty result matrix

% Locally executable nested 'for'-loop structures.
for ii=1:length(var1) % Beginning of the outer loop
    for jj=1:length(var2) % Beginning of the inner loop
        result(ii,jj)=var1(ii)*var2(jj); % Store the multiplication result in the matrix
    end % End of the inner loop
end % End of the outer loop

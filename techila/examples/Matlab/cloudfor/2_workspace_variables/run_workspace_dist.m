function result = run_workspace_dist()
% This function contains the 'cloudfor' version of the locally executable
% program. Calling this function will create a computational Project, where
% the multiplication operations in the nested loop structure will be executed on
% the Workers. Each Job will calculate one iteration of the loop structures.
%
% To use: result = run_workspace_dist()

% Copyright 2011-2015 Techila Technologies Ltd.

var1=[2 4 6]; % Length of 'var1' will define number of outer loop iterations
var2=[11 51 100]; % Length of 'var1' will define number of inner loop iterations
dummyvar=rand(2000); % Create a dummy variable, not used in computations
result=zeros(length(var1),length(var2)); % Create empty result matrix

% The keywords 'cloudfor' and 'cloudend' have been used to mark the
% beginning and end of the block of code that will be executed on Workers.
% ------------------------------------------------------------------------
% The %cloudfor(key,value) parameters used in this example are explained below:
% ------------------------------------------------------------------------
% ('stepsperjob',1)             Sets the amount of iterations performed in
%                               each Job to one (1)
% ('inputparam',var1,var2,result) Define that only variables 'var1','var2'
%                                         and 'result' will be transferred. This
%                                         means that the variable 'dummyvar' will not
%                                         be transferred.
% ------------------------------------------------------------------------
cloudfor ii=1:length(var1) % Beginning of the cloudfor-block #1
    %cloudfor('stepsperjob',1)
    cloudfor jj=1:length(var2) % Beginning of the cloudfor-block #2
        %cloudfor('stepsperjob',1)
        %cloudfor('inputparam',var1,var2,result)
        result(ii,jj)=var1(ii)*var2(jj); % Store the multiplication result in the matrix
    cloudend % End of cloudfor-block #2
cloudend % End of cloudfor-block #1

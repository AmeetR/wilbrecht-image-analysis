function result = download_pi_results(projectid)
% This function downloads the results of a previously created Project. 
% To download results of a previously created Project, use command:
%
% result = download_pi_results(projectid)
%
% projectid = The Project ID number of the Project for which the results will be downloaded.

% Copyright 2010-2013 Techila Technologies Ltd.

 result=peach('',{},1,...
    'ProjectId', projectid); % Links to an existing project
  
result = cell2mat(result);	% Convert to a single matrix
result = 4*sum(result(:,1)) / (result(1,2) * size(result,1)); % Calculate the value of Pi using the downloaded results.
 
end

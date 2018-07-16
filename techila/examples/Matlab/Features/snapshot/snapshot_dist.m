function result = snapshot_dist(loops)
% This m-file contains the Worker Code, which will be compiled and distributed
% to the Workers.  The saveSnapshot helper function will be used to 
% store intermediate results in the snapshot.mat file.

% Copyright 2010-2013 Techila Technologies Ltd.

result = 0;      %Init: No random points generated yet, init to 0.
iter=1;          %Init: No iterations have been performed yet, init to 1.
 
loadSnapshot; %Override Init values if snapshot exists
 
for iter = iter : loops; %Resume iterations from start or from snapshot
    
    if ((sqrt(rand() ^ 2 + rand() ^ 2)) < 1) 
        result = result + 1; 
    end
    
    if mod(iter,1e8)==0 %Snapshot every 1e8 iterations 
       saveSnapshot('iter','result') % Save intermediate results
    end
    
end
 
 

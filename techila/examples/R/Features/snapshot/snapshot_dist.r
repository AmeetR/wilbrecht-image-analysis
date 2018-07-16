# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Worker Code, which will be distributed
# and executed on the Workers. The saveSnapshot helper function will
# be used to store intermediate results in the snapshot.mat file. The
# loadSnapshot helper function
snapshot_dist <- function(loops) {

  count <- 0 # Init: No random points generated yet, init to 0.
  iter <- 1  # Init: No iterations have been performed yet, init to 1.

  loadSnapshot() # Override Init values if snapshot exists

  for (iter in iter:loops) { # Resume iterations from start or from snapshot
    if ((sum(((runif(1) ^ 2)  + (runif(1) ^ 2))) ^ 0.5) < 1) {
      count <- count + 1 
    }
    if (!(iter %% 1e7)) { # Snapshot every 1e7 iterations
      saveSnapshot(iter, count) # Save intermediate results
    }
  }
  return(count)
}

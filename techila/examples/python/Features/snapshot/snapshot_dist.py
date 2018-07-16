# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the Worker Code, which will be distributed
# and executed on the Workers. The save_snapshot helper function will
# be used to store intermediate results in the snapshot.dat file. The
# load_snapshot helper function will be used to load snapshot files
# if the job is resumed on another Worker.

import random
from peachclient import load_snapshot, save_snapshot

def snapshot_dist(loops):

    # Snapshot variables need to be declared global
    global count
    global i

    count = 0 # Init: No random points generated yet, init to 0.
    i = 0  # Init: No iterations have been performed yet, init to 0.

    load_snapshot() # Override Init values if snapshot exists

    while i < loops:
        if pow(pow(random.random(), 2) + pow(random.random(), 2), 0.5) < 1:
            count = count + 1
        if i > 0 and i % 1e7 == 0: # Snapshot every 1e7 iterations
            save_snapshot('i', 'count') # Save intermediate results

        i = i + 1

    return(count)

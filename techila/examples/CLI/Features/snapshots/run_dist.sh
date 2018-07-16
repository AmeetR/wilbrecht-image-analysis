#!/bin/sh
# Copyright 2011-2016 Techila Technologies Ltd.
# Usage: ./run_dist.sh 10 2000000000
techila="java -jar ../../../../lib/techila.jar"

# Remove any possible old result files
if [ -e ./output/result_1 ]
 then
  echo Removing old result files
  rm ./output/result*
fi

# First input argument determines the number of Jobs
jobs=$1

# Second input argument determines the number of iterations per Job
loops=$2

# Define the executable program
command="mcpi-snap.exe;osname=Windows,mcpi-snap;osname=Linux"

# Input parameters for the binary.
parameters="%P(jobidx) %P(loops) %O(output)"

# Output files that will be generated on the worker.
outputfiles="output;file=techila_result"

# Define that a file called 'snapshot.dat' is the snapshot file and the
# snapshot interval is five minutes.
binarybundleparameters="SnapshotFiles=snapshot.dat, \
SnapshotInterval=5"
# Defines which platforms will be used in the computational Project
platform="Linux;Windows"

# Create the peachvector based on the number of Jobs
peachvector=`seq -s" " 1 $jobs`

# Create the computational Project.
$techila peach command=$command parameters="$parameters" \
binarybundleparameters="$binarybundleparameters" \
outputfiles="$outputfiles" peachvector="$peachvector" \
platform="$platform" projectparameters="loops=$loops"

# Calculate the sum of the first columns in the result files (points within the unitary circle)
points=`cat ./output/output_* | cut -d " " -f 1 | awk '{for (i=1; i<=NF; i++) s=s+$i}; END{print s}'`

# Calculate the total number of points generated during the Jobs
total=`cat ./output/output_* | cut -d " " -f 2 | awk '{for (i=1; i<=NF; i++) s=s+$i}; END{print s}'`

# Calculate the value of Pi based on the Job results
RESULT=`echo $points $total|awk '{print $1 / $2 * 4}'

# Print the approximated value of Pi`
echo The approximated value of Pi is: $RESULT

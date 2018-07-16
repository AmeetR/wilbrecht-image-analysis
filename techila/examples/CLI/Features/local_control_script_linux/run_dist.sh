#!/bin/sh
# Copyright 2011-2016 Techila Technologies Ltd.
# Usage: ./run_dist.sh 10 1000000
# Create a variable for accessing the CLI interface.
techila="java -jar ../../../../lib/techila.jar"

# Remove any possible old result files
if [ ! -z "$(ls -A ./output/output_* 2>/dev/null)" ]
 then
  echo Removing old result files
  rm -f ./output/output_*
fi

# First input argument determines the number of Jobs
jobs=$1

# Second input argument determines the number of iterations per Job
loops=$2

# Define the executable program
command="mcpi.exe;osname=Windows,mcpi;osname=Linux"

# Input parameters for the binary. %P(jobidx) will be replaced with '1' for
# Job #1, '2' for Job #2 etc. %P(loops) will be replaced with the value of
# the second input argument. %O(output) will be replaced with the name of the
# output file.
parameters="%P(jobidx) %P(loops) %O(output)"

# Output files that will be transferred back from the Worker.
outputfiles="output;file=techila_result"

# Defines which platforms will be used in the computational Project
platform="Linux;Windows"

# Create the peachvector based on the number of Jobs
peachvector=`seq -s" " 1 $jobs`

# Create the computational Project.
$techila peach command=$command parameters="$parameters" \
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

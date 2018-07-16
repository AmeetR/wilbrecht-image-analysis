#!/bin/sh
# Copyright 2011-2013 Techila Technologies Ltd.
# Set the values of variables 'a' and 'b' based on the values defined
# in the 'parameters' in the Local Control Code.
a=$1
b=$2
# Multiply the variables 'a' and 'b'
result=$(($a*$b))
# Store the result in to the result file called 'output_1', which will
# be returned from the Worker
echo $result > output_1
# Echo the values of the variables. This stdout stream will be stored in
# a file, which will also be returned from the Worker
echo $a $b $result

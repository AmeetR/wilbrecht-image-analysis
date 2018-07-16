#!/bin/sh
# Copyright 2011-2013 Techila Technologies Ltd.
# Set the value of variables 'a' and 'b'
a=1
b=2
# Calculate the sum of variables 'a' and 'b'
sum=$(($a+$b))
# Store the result into the 'output_1' file
echo $sum > output_1

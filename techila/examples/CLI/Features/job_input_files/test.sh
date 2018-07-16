#!/bin/sh
# Copyright 2011-2013 Techila Technologies Ltd.
# Store the name of the Job specific input file to a variable
filename=$1
# Store a list of the files in the temporary directory to the
# 'techila_result' file
echo Files in the temporary working directory: > techila_result
ls  >> techila_result
echo Content of the Job Input File associated with this Job: >> techila_result
# Store the name of the Job-specific input file into the 'techila_result' 
# file
cat "$filename" >> techila_result

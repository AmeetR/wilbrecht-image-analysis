@ECHO OFF
REM Copyright 2011-2013 Techila Technologies Ltd.
REM Store the name of the Job specific input file to a variable
set filename=%1%
REM Store a list of the files in the temporary directory to the 
REM 'techila_result' file
echo Files in the temporary working directory: > techila_result
dir /b  >> techila_result
echo Content of the Job Input File associated with this Job: >> techila_result
REM Store the name of the Job-specific input file into the 'techila_result'
REM file
type %filename% >> techila_result

@ECHO OFF
REM Copyright 2011-2013 Techila Technologies Ltd.
REM Get the location of the files on the Worker by expanding the %L()
REM notation in the 'parameters' parameter in the 'commands' file.
set location=%1%
REM Set value of the 'filename' variable according to the peachvector
REM element for the Job
set filename=%2%
echo Location of the files in the Bundle on the worker is: >> output_1
REM Store the location of the files on the Worker to the 'output_1' file
echo %location% >> output_1
echo Files in the directory: >> output_1
REM Store a list of files in the directory to the 'output_1' file
dir /b %location% >> output_1
echo Content of file named "%filename%": >> output_1
REM Store the content of the file 'output_1' file. Job #1 will display
REM content of 'datafile1', Job #2 for 'datafile2'
type %location%\%filename% >> output_1

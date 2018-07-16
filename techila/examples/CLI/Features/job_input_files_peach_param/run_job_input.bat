@ECHO OFF
REM Copyright 2011-2013 Techila Technologies Ltd.
set techila=java -jar ../../../../lib/techila.jar
REM Define that 'test.bat' will be executed on Windows Workers and 'test.sh' on
REM Linux Workers.
set command="test.bat;osname=Windows,test.sh;osname=Linux" 

REM Define that a file called 'techila_result' is the output file. This
REM file will be returned from the Workers to the Techila Server and 
REM transferred back to your computer.
set outputfiles="output;file=techila_result" 

REM Specify that the list of files to be stored in the Job Input Bundle will
REM be read from stdin given to the command.
set jobinputfiles="<stdin>"

REM Specify that the Job-specific input files should be renamed to 'data1' and
REM 'data2' after the files have been transferred to the Worker.
set jobinputfilenames="data1 data2"

REM Input parameters for the executable. In each Job, the executable script 
REM will be given two input arguments. The input arguments 'data1' and 'data2'
REM corresponds to the names of the Job-specific input files as defined 
REM in the parameter 'jobinputfilenames'.
set parameters="data1 data2" 

REM Define that only Linux and Windows Workers can be assigned Jobs.
set platform="Windows;Linux" 

REM Create the Project with the 'peach' command using the parameters defined 
REM earlier in the batch file. The output of 'dir /b file*' command will be 
REM used to construct the list of files that be stored in the Job Input Bundle.
dir /b file* | %techila% peach command=%command% ^
parameters=%parameters% outputfiles=%outputfiles% ^
jobinputfiles=%jobinputfiles% jobinputfilenames=%jobinputfilenames% ^
platform=%platform%

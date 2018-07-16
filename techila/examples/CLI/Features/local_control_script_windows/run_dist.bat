@ECHO OFF
REM Copyright 2011-2016 Techila Technologies Ltd.
REM Usage: run_dist.bat 10 1000000
set techila=java -jar ..\..\..\..\lib\techila.jar
set jobs=%1%
set loops=%2%
set counter=1
REM Define that 'mcpi.exe' will be executed on Windows Workers and 'mcpi' on
REM Linux Workers.
set command="mcpi.exe;osname=Windows,mcpi;osname=Linux"

REM Input parameters for the binary. %%P(jobidx) is the first input parameter,
REM and will be different for each Job ('1' for Job #1, '2' for Job etc).
REM %%P(loops) will be replaced with the value of the second input argument read
REM from the command line. Note that this parameter has also been defined
REM in 'projectparameters'. %%O(output) defines that the third input argument
REM contains the name of the output file that will be transferred back from the
REM Worker.
set parameters="%%P(jobidx) %%P(loops) %%O(output)"

REM Define that a file called 'techila_result' is the output file. This
REM file will be returned from the Workers to the Techila Server and
REM transferred back to the End-Users computer.
set outputfiles="output;file=techila_result"

REM Define that only Linux and Windows Workers can be assigned Jobs.
set platforms="Linux;Windows"

REM Define the values for the 'loops' parameter based on the value read from
REM the command line arguments
set projectparameters="loops=%loops%"

REM Define that result files should be placed in the 'project_output' directory
REM under the current working directory. The directory will be automatically
REM created if it does not exist allready.
set destination=".\project_output"

REM Create the peachvector. The loop structure will create a peachvector that
REM contains an equal number of elements as the number of Jobs in the Project.
REM Peachvector elements will be '1','2','3',...n, where n is the number of Jobs-
set peachvector=1
if %peachvector%==%jobs% goto skip
:loop
set /A counter=%counter%+1
set peachvector=%peachvector% %counter%
if not %counter%==%jobs% goto loop
:skip

REM Create the Project with the 'peach' command using the parameters defined
REM earlier in the batch file.
%techila% peach command=%command% parameters=%parameters% ^
outputfiles=%outputfiles% destination=%destination% platform=%platforms% ^
projectparameters=%projectparameters% peachvector="%peachvector%"

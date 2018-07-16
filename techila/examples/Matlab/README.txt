Techila MATLAB examples
=======================

These folders contain examples for MATLAB.

Preparation steps and example material walkthroughs can be found in the
following guide:

http://www.techilatechnologies.com/matlab-guide

If you are unsure on where to begin, it is advisable that you start by
familiarizing yourself with the example material either in the cloudfor
or Tutorial folder. 

The typical naming convention of the m-files in the "Tutorial" and
"Features" folders is explained below:

- M-files ending with "_dist" contain the function (Worker Code),
  which will be compiled and distributed to the Workers when the Local
  Control Code is executed.
- M-files beginning with "run_" contain the function (Local Control
  Code), which will be executed locally and will create the
  computational Project.

The typical naming convention of the m-files in the cloudfor folder is
explained below:

- M-files beginning with "local_" contain the locally executable
  program. The functions in these m-files do not communicate with the
  Techila Server in any way.

- M-files beginning with "run_" contain the distributed version of the
  locally executable program. The functions in these m-files will
  create a Project where the computational operations will be
  performed on the Workers.

Some folders contain m-files having a different naming convention. The
role of these functions is explained in:

http://www.techilatechnologies.com/matlab-guide

The "Advanced" folder contains examples implemented without peach and
other more complex examples.

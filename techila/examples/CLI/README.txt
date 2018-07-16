Techila Command Line Interface (CLI) examples
==============================================

The "Tutorial" and "Features" folders contain examples that can be run
directly from the Windows Command Prompt or Linux shell. If you are
unsure on where to begin, it is advisable that you start by
familiarizing yourself with the example material in the Tutorial
folder.

Preparation steps and example material walkthroughs can be found 
in the following guide:

http://www.techilatechnologies.com/cli-guide

The typical naming convention of the files is explained below:

- Files beginning with "run_" contain Local Control Scripts, which can
  be executed either in a Linux or Windows environment. Executing
  these scripts locally will create the computational Project with
  given parameters.

- Files called 'commands' contain the Local Control Code. These files
  are given to the CLI with the 'read' command by using the syntax
  shown below.

  java -jar <path_to>\techila\lib\techila.jar read < commands

The 'java -jar <path_to>\techila\lib\techila.jar' notation can be
replaced by creating an environment variable to reduce typing.

To create an environment variable in a Windows environment to access
the CLI interface, use the command shown below. Note that the
<path_to> notation should be replaced with the path leading to the
'techila.jar' file:

set techila=java -jar <path_to>\techila.jar

To create an environment variable in a Linux environment to access the
CLI interface, use the command shown below. Again, replace the
<path_to> notation in the command with the path leading to the
'techila.jar' file on your computer:

techila="java -jar <path_to>/techila.jar"

After an environment variable has been created, it can be used for
executing CLI commands.

You can also create an alias for the command:

alias techila="java -jar <path_to>/techila.jar"

When using the environment variables described above, a CLI command
could be executed with the following syntax (in Windows):

%techila% <command>

And respectively in a Linux environment, a CLI command could be
executed with the following syntax (in Linux):

$techila <command>

Or if you defined an alias:

techila <command>

Most of the examples can be run by using the 'read' command as shown
below:

For a Windows based operating system:

%techila% read < commands

For a Linux based operating system:

$techila read < commands

Or if you defined an alias:

techila read < commands

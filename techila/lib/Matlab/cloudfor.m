%CLOUDFOR   Replacement for "for" control statement to distribute the
%          computation of program statements between cloudfor and cloudend
%          into Techila environment.
%
% Cloudfor statement must have corresponding cloudend statement in the same
% way as "end" statement is used for "for" statement.
%
% In the most simpliest case, the "for" loop may be changed into cloudfor
% just by adding word "cloud" in front of words "for" and "end", eg.
%       for i=1:10
%           % program statements
%       end
% -->
%       cloudfor i=1:10
%           % program statements
%       cloudend
%
% When running these statements, the program statements are executed once
% locally to estimate the execution time and the number of loops executed
% in a single cloud job is computed by the estimation. The execution time
% for a single job is tried to get at least to 5 seconds by default.
%
% It's possible to control the cloudfor by adding control parameters with
% %cloudfor('key', value) or %cloudfor:key=value statements. With %cloudfor 
% it's possible to change the required execution time or tell directly how 
% many loops of the cloudfor should be executed in a single job. If the 
% number of loops is told directly, the program statements are executed 
% immediately in the cloud instead of first running the local timing run.
% For example:
%
%       cloudfor i=1:10
%       %cloudfor('stepsperjob', 1)
%           cloudfor j=1:10
%           %cloudfor:stepsperjob=5
%               % program statements
%           cloudend
%       cloudend
%
% The i=1:10 loop would be splitted into 10 jobs alone, but additionally
% j=1:10 loop is splitted into two parts of 5 jobs creating total of 20
% jobs.
%
% The supported %cloudfor('key', value) control parameters are:
%   stepsperjob,<integer>               Execute the specified cloudfor loops
%                                       the given amount in a single job.
%                                       Skips the local timing execution
%                                       before running in the Techila
%                                       environment.
%
%   estimate,<numeric>                  The number of seconds required for
%                                       a single job's minimum execution
%                                       time. This time is computed by
%                                       executing the last loop of the
%                                       cloudfor locally. The number of
%                                       loops executed in a single job is
%                                       set by this estimation.
%
%   inputparam,<comma separated values> Variables to be deployed to the
%                                       Techila environment. Without this
%                                       all the local variables from the
%                                       current scope are deployed. This
%                                       may cause a large amount of data
%                                       transfer. To minimize the amount of
%                                       data transfer, the required
%                                       variables of the program statements
%                                       in the cloudfor may be specified
%                                       with this parameter. The special
%                                       value 'global' can be used to
%                                       transfer also the global variables.
%
%   outputparam,<comma separated values>    Variables to be returned from
%                                       the Techila environment. Without
%                                       this all the changed variables from
%                                       the executed program statements are
%                                       returned. This may cause
%                                       unnecessary large data transfer of
%                                       temporary variables. To prevent
%                                       this, the variables to be returned
%                                       may be specified with this
%                                       parameter.
%
%   sum,<comma separated values>        By default the return values from
%                                       the execution are joined together
%                                       by replacing the old values. For
%                                       example the jobs may return single
%                                       values to empty array. If the
%                                       returned values are using the same
%                                       non-array variables or the same
%                                       indexes into an array the existing
%                                       values would be replaced by later
%                                       ones by default. This parameter can
%                                       be used to tell the variables that
%                                       are summarized instead of replacing
%                                       when the values are returned.
%
%   finitesum,<comma separated values>  This is similar to the parameter
%                                       "sum", but requires the size of the
%                                       variables equal and the content of
%                                       the variables to be finite
%                                       numerical values.
%
%   cat,<comma separated values>        This is similar to the parameter
%                                       "sum", but instead of replacing or
%                                       summarizing the variables told here
%                                       are concatenated. By default the
%                                       variables are concatenated along 
%                                       their second dimension (horzcat).
%                                       Dimension can be changed by giving
%                                       dimension in parentheses, for
%                                       example: %cloudfor('cat','res(3)')
%                                       to concatenate variable "res" along
%                                       its 3rd dimension.
%
%   replace,<comma separated values>    The values for these variables will
%                                       be replaced with the value from
%                                       each received result. The final
%                                       value is the one returned from the
%                                       last iteration.
%
%   first,<comma separated values>      The values for these variables will
%                                       be the value from the last iteration
%                                       of the first job. If stepsperjob=1,
%                                       this means the first iteration.
%
%   dependency,<comma separated values> The external function files that
%                                       are required by the program
%                                       statements or the functions called
%                                       by them. The direct calls to
%                                       the external function files can be
%                                       found automatically, but the calls
%                                       performed for example with eval()
%                                       or solvers that are using the name
%                                       of the function as a string cannot
%                                       be found automatically. These
%                                       required function files can be
%                                       given in this parameter.
%
%   functiondep,<comma separated values> The functions that are required by
%                                       the program statements or the
%                                       functions called by them. For
%                                       example some class methods might
%                                       not be detected automatically.
%
%   stream,<true|false>                 By the default the results are
%                                       streamed from the execution and
%                                       their order cannot be guaranteed.
%                                       This is not a problem if the result
%                                       is not touched before cloudend.
%                                       However in some cases the
%                                       "%cloudfor('callback', ...)" may 
%                                       require the results to be in order.
%                                       In that case the streaming may be 
%                                       turned off and the results are not
%                                       returned until all the jobs are
%                                       completed.
%
%   quiet                               This turns off the Techila messages
%                                       and statistics.
%
%   parameters,<string>                 If the precompiled binary is
%                                       executed instead of Matlab code,
%                                       this can be used to deliver the
%                                       parameters for the binary. The
%                                       values from the cloudfor statements
%                                       can be set here with special values
%                                       '<paramx>' where "x" is the
%                                       index of cloudfor. For example
%                                       %cloudfor('parameters', '<param1> <param2>' 
%                                       with cloudfor i=1:10 and
%                                       cloudfor j=[2 4 6 8] would replace
%                                       the param1 with values from 1 to 10
%                                       and param2 with values 2,4,6 and 8.
%                                       See peach for defining precompiled
%                                       binaries.
%
%   force:loopcount                     The default maximum number of jobs
%                                       to be created is 100000. If larger
%                                       number of jobs needs to be created,
%                                       this parameter must be given.
%
%   force:largedata                     The default maximum size of input
%                                       data for cloudfor is 10 megabytes
%                                       which is computed from uncompressed
%                                       variables. To allow larger input
%                                       data, this parameter must be given.
%
%   callback,<string>                   There can be several callback lines
%                                       in cloudfor. The content of these
%                                       callback lines are executed every
%                                       time when a result is returned from
%                                       the execution. They can be used for
%                                       example to visualize the results or
%                                       to postprocess the job results
%                                       before the project is completed.
%
%   imcallback,<string>                 There can be several imcallback 
%                                       lines in cloudfor. The content of
%                                       these lines are executed every
%                                       time when an intermediate result is
%                                       returned from the execution. They
%                                       can be used for example to get the
%                                       status of the computations or to
%                                       compute intermediate results and
%                                       provide new data to the
%                                       computations based on them.
%
%   resultfilevar,<variable>            The name of the variable to save
%                                       the names of the result files. If
%                                       this parameter is specified, the
%                                       result files are not removed from
%                                       the local harddrive in the cloudend
%                                       but they must be manually removed.
%
%   importdatavar,<variable>            The name of the variable to save
%                                       data imported from non-Matlab
%                                       result files. This can be used when
%                                       executing precompiled non-Matlab
%                                       binaries.
%
%   importdata,{delimiter, nheaderlines} Specifies the format of the data
%                                       imported with importdatavar. See
%                                       importdata() for details.
%
%   datafile,<variable>|<csv>           File(s) to be transferred to the
%                                       execution environment. This can be
%                                       defined from a variable or as comma
%                                       separated list of file names.
%
%   jobinputfile,<paramx>|<see peach>   Read the job specific input file
%                                       names from cloudfor loop values or
%                                       use the format specified in peach.
%                                       See peach for details. If the
%                                       values of cloudfor loop are used,
%                                       the <paramx> is used. The x tells
%                                       the depth index of cloudfors.
%
%   donotinit                           Do not initialize the techila.
%                                       techilainit() needs to be called
%                                       before cloudfor if this is
%                                       specified. This can be used to
%                                       execute several cloudfors in a
%                                       single session. To prevent the
%                                       session from uninitialization, the
%                                       donotuninit must also be specified.
%
%   donotuninit                         See donotinit.
%
%   mfilename,<filename.m>              Filename to be used for generated
%                                       code. Default is techila_for.m.
%
%   donotimport,<true|false>            Do not import the results into
%                                       Matlab. Can be used with
%                                       resultfilevar to return just the
%                                       names of the result files. Default
%                                       is false.
%
%   removeresult,<true|false>           Remove result file after it has
%                                       been imported to Matlab. Default is
%                                       false.
%
%   legacymoderesults,<true|false>      Summarize result vectors instead of
%                                       using difference information. This
%                                       is old behavior which requires the
%                                       results vectors to be initialized
%                                       as empty or INF/NaN and does not
%                                       support INF/NaN as result values.
%                                       Default is false.
%
%  allowpartial,<true|false>            Ignore errors and interruptions in 
%                                       the projects. Continues with
%                                       partial or non-existing results.
%                                       Default is false.
%
%  removeproject,<true|false>           Remove Project from Techila Server 
%                                       after the results are downloaded. 
%                                       Default is true.
%
%  donotwait                            Returns immediately after the 
%                                       project is created. Returns the id 
%                                       of the project in global
%                                       TECHILA_PROJECTID.
%
%  allowrevert                          If code cannot be executed in
%                                       Techila Environment, it will be
%                                       executed locally.
%
%  runlocally                           Executes the code locally.
%
%  tips,<true|false>                    Show Techila usage tips. Default is
%                                       true.
%
%
% It's also possible to provide peach parameters through cloudfor by
% using %peach('key', value) syntax.
%
%
% It's allowed to use cloudfor in multiple level, eg.
%       cloudfor i=1:10
%           cloudfor j=1:10
%             % program statements
%           cloudend
%       cloudend
%
% and it's also allowed to use multiple cloudfors in the same level when
% they are not inside any cloudfor:
%       cloudfor i=1:10
%           % program statements
%       cloudend
%       cloudfor j=1:10
%           % program statements
%       cloudend
%
% But it's not possible to use multiple cloudfors in the same level when
% inside a cloudfor, so this is _NOT_ allowed:
%       cloudfor i=1:10
%           cloudfor j=1:10
%               % program statements
%           cloudend
%           cloudfor k=1:10
%               % program statements
%           cloudend
%       cloudend
%
%
% Cloudfor can be used as replacement only for the "for" loops that are
% independent of each other. For example
%
%       A=zeros(10,1);
%       for i=1:10
%           A(i)=i;
%       end
%
% can be changed into
%
%       A=zeros(10,1);
%       cloudfor i=1:10
%           A(i)=i;
%       cloudend
%
% But
%
%       A=5;
%       for i=1:10
%           A=A+A*i;
%       end
%
% cannot be changed into cloudfor because the value of A from the previous
% loop is used in the program statements.
%
% SEE ALSO peach, importdata

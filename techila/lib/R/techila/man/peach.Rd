\name{peach}
\alias{peach}
\title{
Techila R Peach
}
\description{
Peach (Parallel Each) is used to execute R computations in Techila system.
}
\usage{
result <- peach(funcname = NULL,
                params = NULL,
                files = NULL,
                peachvector = NULL,
                jobs = NULL,
                datafiles = NULL,
                messages = TRUE,
                priority = 4,
                sdkroot = NULL,
                stream = FALSE,
                callback = NULL,
                filehandler = NULL,
                initFile = NULL,
                ProjectParameters = NULL,
                BundleParameters = NULL,
                BinaryBundleParameters = NULL,
                donotwait = FALSE,
                donotuninit = FALSE,
                removeproject = TRUE,
                close = TRUE,
                imports = NULL,
                databundles = NULL,
                jobinputfiles = NULL,
                outputfiles = NULL,
                snapshot = FALSE,
                snapshotfiles = "snapshot.rda",
                snapshotinterval = 15,
                RVersion = NULL,
                runAsR = NULL,
                projectid = -1,
                steps = 1)
}
\arguments{

\item{funcname}{The function that will be executed on Workers. Can
refer to a function handle or to a function that is defined in an
R-script that is listed in the 'files' parameter. Example 1:
funcname=workerFunc. Defines that the function is a function handle.
Example 2: funcname="workerFunc". Defines that the function is defined
in one of the R-scripts that will be sourced with 'files'}

\item{params}{Input arguments to the function that is executed on
Workers. Example: params=list(a=10,b=100). Defines two input arguments
to the executable function.}

\item{files}{List of R-scripts that will be transferred and sourced on
Workers. Example: files=list("exampleScript.r"). Sources the
'exampleScript.r' file before doing any function calls.}

\item{peachvector}{peachvector elements, length defines the number of
jobs. Example: peachvector=1:10. Creates a Project consisting of 10
jobs.}

\item{jobs}{Alternative to peachvector, define the number of jobs to be
created. Steps parameter will affect the actual amount of jobs created.}

\item{datafiles}{List of additional data files that will be
transferred to the Workers.Example:
datafiles=list("datafile1.txt","datafile2.txt"). Transfers files
called 'datafile1.txt' and 'datafile2.txt' from the current working
directory to all partipating Workers.}

\item{messages}{Determines if messages will be displayed regarding
Project statistics and other Project related information. To disable
messages, use: messages=FALSE}

\item{priority}{Determines the priority of the Project. Adjusting the
priority value can be used to manage the order in which computational
Projects created by you are processed. Projects with priority = 1
receive the most resources and Projects with priority = 7 the least
amount of resources.}

\item{sdkroot}{Determines the path of the SDK directory. Example:
sdkroot="C:/techila"}

\item{stream}{Enables Job results to be streamed immediately after
they have been transferred to the Techila Server. To enable streaming,
use: stream=TRUE}

\item{callback}{Calls given function for each result and returns
callback function's result as the peach result as peach result.
Example: callback = "callbackFun"}

\item{filehandler}{Calls given file handler function for each
additional result file returned from Workers. See parameter
'outputfiles' for defining additional result files}

\item{initFile}{Specifies the path of the Techila config file
(techila_settings.ini)}

\item{ProjectParameters}{Defines additional Project parameters.
Example: ProjectParameters = list("techila_client_memorymin" =
"1073741824", "techila_client_os" = "Windows") Defines that only
Workers with a Windows operating system and 1 GB of free memory can be
assigned Jobs.}

\item{BundleParameters}{Defines parameters for the Parameter Bundle.
Example: BundleParameters=list("ExpirationPeriod" = "2 h"). Defines
that the Parameter Bundle should be stored for 2 hours on Workers.}

\item{BinaryBundleParameters}{Defines parameters for the Executor
Bundle. Example: BinaryBundleParameters=list("ExpirationPeriod" = "2
h"). Defines that the Executor Bundle should be stored for 2 hours on
Workers.}

\item{donotwait}{Defines that peach will return immediately after the
Project has been created. If no other parameters are specified, peach
will return the Project ID number. To make peach return immediately,
use: donotwait=TRUE}

\item{donotuninit}{Does not uninitialize the Techila environment. To
prevent uninitialization, use: donotuninit = TRUE}

\item{removeproject}{Determines if Project related data will be
removed from the Techila Server after the Project is completed. To
remove project, use: removeproject=TRUE}

\item{close}{Closes the handle. To prevent the handle from closing,
use: close=FALSE}

\item{imports}{Determines additional Bundles that will be imported in
the Project. Example: imports=list("example.bundle.v1",
"example.bundle2.v1"). Defines that, Bundles exporting
'example.bundle.v1' and 'example.bundle.v2' will be transferred to
each Worker participating in the Project.}

\item{databundles}{Used to create Data Bundles. Listed files will be
included in the Data Bundle(s). Example: databundles =
list(list(datafiles = list("file1","file2")). Defines that files
'file1' and 'file2' will be placed in the Bundle}

\item{jobinputfiles}{Assigns Job-Specific input files that will be
transferred with each computational Job. Example: jobinputfiles =
list(datafiles =list("file1_job1","file1_job2"),filenames =
list("workername")). Transfers 'file1_job1' to Job #1 and 'file1_job2'
to Job #2. Both files will be renamed to 'workername' on Workers}

\item{outputfiles}{Speficies additional output files that will be
transferred to the End-User's computer from Workers. Example:
outputfiles=list("file1","file2"). Defines that files named 'file1'
and 'file2' will be returned from Workers. See 'filehandler' for
post-processing these result files.}

\item{snapshot}{Enables snapshotting in the Project with the default
snapshot file name and snapshot transfer interval. To enable
snapshotting, use: snapshot=TRUE}

\item{snapshotfiles}{Specifies the name of the snapshot file. If
specified, this value overrides the default value. Example:
snapshotfiles = "test.txt". Defines that 'test.txt' will be used as
the snapshot file, which will be transferred to the Techila Server.}

\item{snapshotinterval}{Specifies a snapshot transfer interval in
minutes. If specified, this value overrides the default snapshot
transfer interval. Example: snapshotinterval=30. Defines that the
minimum interval for transfer is 30 minutes.}

\item{RVersion}{Specifies which R Runtime Bundle is used to execute
the computational Jobs. If the RVersion parameter is not specified,
the version of the R environment used to create the Project will be
used. Example: RVersion="2120". Defines that the Runtime Bundle built
from R 2.12.0 will be used.}

\item{runAsR}{Experimental feature. Enables R computations to be
performed by using the R-software installed on Workers. Enables R
computations to be performed without R Runtime Bundles. Requires a
that Techila Administrators have configured the system. To use this
feature, use: runAsR=TRUE}

\item{projectid}{Defines the Project ID number of the Project to which
the peach function call should be linked to. Can be used to download
results of previously started Projects. Example: projectid = 1234.
Defines the peach function call is linked to a Project with Project ID
1234.}

\item{steps}{The number of iteration steps to be run per job.}

}

\value{A list of values returned by the function. Dimensions are the
same as for the peachvector.}

\examples{
result <- peach(funcname = "distribution_dist",
                files = list("distribution_dist.r"),
                peachvector = 1:jobs
                sdkroot = "/home/user/techila/")
}
\author{
Maintainer: Techila <info@techila.fi>
}
\keyword{ techila peach }

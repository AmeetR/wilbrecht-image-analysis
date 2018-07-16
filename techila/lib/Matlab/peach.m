%peach    Parallel each execution of Matlab function (or a precompiled
%         executable)
%
%peach(funcname, params, [files], peachvector, ...) deploys and executes
%function funcname in Techila with parameters given in array 'params'.
%Parameter 'files' is optional.
%
%Additional datafiles may be included in array 'files'. If 'files' contains
%multiple arrays in format {{file1, file2},{file3, file4}} each of the
%subarrays will create separate bundle. If the bundle with the files
%already exists, the existing bundle is used. The verification of the files
%is made with crc-sums.
%
%'Peachvector' contains array of parameter values to replace '<param>' in
%'params' array, such as each of the project's jobs gets value of it's own.
%Parameters may also contain '<param1>', '<param2>', etc. In that case the
%peachvector needs to be a cell array in format {{job1param1,
%job1param2, ...}, {job2param1, job2param2, ...}, ...}.
%
%The method returns vector of return values in the same order with the
%peachvector.
%
% After these parameters, there may be the following additional parameter
% pairs:
% 'Jobs', <integer>        = Number of jobs to generate. This can be used
%                            instead of peachvector to create jobs 
%                            containing only parameter jobid (1..jobs)
% 'Messages', 'false'      = Does not print any messages
% 'Statistics', 'false'    = Does not print project statistics
% 'ReturnResults', 'false' = Return handle to the project instead of result
%                            values. Sets CleanFiles and CloseHandle to
%                            false.
% 'CleanFiles', 'false'    = Do not remove result files
% 'CloseHandle', 'false'   = Do not close the project handle
% 'ForceCompile', 'true'   = Force the function file to be compiled
% 'ForceNotCompile', 'true'= Prevents the function file from compiling
% 'DoNotInit', 'true'      = Does not initialize Techila
% 'DoNotUninit', 'true'    = Does not uninitialize Techila
% 'DoNotWait', 'true'      = Returns immediately after the project is
%                            created. Returns the id of the project by
%                            default. If CloseHandle is set to false,
%                            returns the project handle.
% 'StreamResults', 'true'  = Transfers the result immediately when it's
%                            completed
% 'ProjectId', <id>        = Binds to a project created earlier
% 'Parameters', '<params>' = Additional Command Line Parameters to control
%                            for example additional input files
% 'ProjectParameters', {{'param1', 'value1'},{'param2', value2'}}
%                          = Adds extra parameters for controlling the
%                            Techila system
% 'BundleParameters', {{'param1', 'value1'},{'param2', value2'}}
%                          = Adds extra bundle parameters for controlling
%                            the Techila system
% 'BinaryBundleParameters', {{'param1', 'value1'},{'param2', value2'}}
%                          = Adds extra binary bundle parameters for
%                            controlling the Techila system
% 'AllowPartial', 'true'   = Allow partial results (some of the results are
%                            allowed to fail)
% 'TmpDir', '<location>'   = The directory where the compiled executables
%                            are written into and where the project data is
%                            written temporarily
% 'sdkRoot', '<location>'  = Path to the Techila SDK root
% 'LibPath', '<location>'  = Path to the Techila libraries
% 'InitFile', '<location>' = Path to the Techila settings file
% 'Priority', <1..7>       = Project priority, default 4
% 'Description', '<...>'   = Project description
% 'BundleDescription', '<...>' = Executor Bundle description
% 'Handle', <handle>       = Handle from existing session
% 'OutputFiles', '{List of Files}' = Return files instead of return value
%                            from the workers. Returns project handle from
%                            peach.
% 'CallbackMethod', @function = Calls given function for each of the
%                            results and return callback function's results
%                            as peach result (the order of the results is
%                            random if StreamResults is used.) The function
%                            will get result file name as the only
%                            parameter by default. See also CallbackParams.
% 'CallbackParams', {params} = Parameters for Callback instead of result
%                            file name. The parameters in format
%                            '<parameter>' are read from result files.
%                            The parameter '<*>' will contain the contents
%                            of the result file as struct. The param
%                            '{resultfile}' will contain the name of the
%                            resultfile.
% 'TimeLimit', <seconds>   = Limit execution to <seconds> second. When the
%                            limit is exceeded, the project is interrupted.
%                            If 'AllowPartial' is activated, the results
%                            are returned.
% 'ResultsRequired', <x>|'<y>%' = Required amount or percential amount of
%                            results before the 'TimeLimit' is activated.
%                            Default is 1.
% 'RemoveProject', 'false' = Remove Project from Techila after the results are
%                            downloaded. Default is true.
% 'AlwaysSign', 'false'    = Always signs bundles. Default = 'true'.
% 'MCCStandAlone', 'false' = Do not use standalone mode (with system
%                            command) to execute MCC locally, but call it
%                            directly as Matlab function. This may cause
%                            mcc license to be locked up for the rest of
%                            the Matlab session.
% 'JobInputFiles', {{'job_1_inputfile_1', 'job_1_inputfile_2'},
%   {'job_2_inputfile_1', 'job_2_inputfile2'}, ...} = Use job-specific
%                            inputfiles. The list must be as long as the
%                            length of peachvector. Each element of the
%                            list contains job-specific inputfiles.
% 'JobInputFileNames', {'filename1', 'filename2'} = The names of the
%                            inputfiles on workers. The default value is
%                            jobinputfile1.mat for the first file,
%                            jobinputfile2.mat for the second, etc.
% 'Executable', 'true'     = Is the funcname precompiled binary instead of
%                            Matlab function. Default = 'false'. Also sets
%                            MatlabRequired default to false.
% 'MatlabRequired', 'false' = Does the Executable need Matlab runtime
%                            libraries? Default = 'true'.
% 'ReturnResultFiles', 'true' = Return the names of the result files
%                            instead of results.
% 'MexFiles', {{'file1.c', 'requirement1.c'}, 'file2.c'} = Include MEX files
%                            to compilation.
% 'DoNotCheckCRC', 'true'  = Do not check if Matlab files have been
%                            changed, requires existing .lastmod.mat file
%                            with proper metadata.
% 'UseBundle', '<bundlename>' = Use previously created executor bundle
% 'LibraryFiles', {'true', 'false'} = Flags for 'files' parameter to tell
%                            if the bundle should be handled as library
%                            (=do not copy files to the execution directory,
%                            but use them from bundle repository). The
%                            libraries can be accessed from parameters with
%                            %L(datafiles_<filesindex>) = library directory
%                            or %L(<filename>) = file in library directory
% 'Binaries', {{'filename1', 'osname1', 'osarch1'}, {'filename2',
%   'osname2', 'osarch2'}, ...} = In 'Executable' mode use different binary
%                            for different platforms. This will override
%                            the filename in 'funcname' parameter. This
%                            also sets Executable=true.
% 'RemoteExecutable', 'true' = Execute preinstalled binary on worker
%                            instead of compiling Matlab function. The
%                            preinstalled binaries are configured with
%                            'Binaries' parameter.
%                            Default = 'false'. Also sets MatlabRequired
%                            default to false.
% 'Snapshot', 'false'      = Is snapshot supported by the project.
%                            Default is true. Sets the following snapshot
%                            parameters:
%                            SnapshotFiles: snapshot.mat
%                            SnapshotInterval: 15 (minutes).
% 'SnapshotFiles', 'filename1,filename2' = Overrides the files defined in
%                            Snapshot=true. Requires snapshot=true.
% 'SnapshotInterval', <minutes> = Overrides the snapshot interval defined
%                            in Snapshot=true. Requires snapshot=true.
% 'UseJVM', 'true'         = Compile with JVM support.
% 'DependencyFiles', {'file1.m', 'file2.m', ...} = Additional Matlab file
%                            dependencies that cannot be automatically
%                            detected. If prefixed with #, then added to
%                            the compilation with -a, for example for .dll
%                            files.
% 'RunAsM', 'true'|{'featurename'} = Do not compile, run with workers' Matlab
% 'ImportResult', 'true'|{delimiter, nheaderlines} = Import result files
%                            with importdata().
% 'LocalMode', 'true'        Execute computation locally. The compilation
%                            etc. is done like in distributed mode but the
%                            execution is performed on local computer.
% 'MCCPath', {'path1', 'path2', ...} = Additional folders to add into
%                            MATLAB search path when compiling Matlab
%                            files.
% 'ResultFile', 'filename' = Read results from a result file downloaded
%                            from the server. The results returned may
%                            be in wrong order.
% 'Profile', 'true'|{{params}} = Run the code in Matlab profiler.
% 'Semaphore', {name, size, expiration} = Create a project specific 
%                            semaphore to be used with 
%                            techilaSemaphoreReserve and 
%                            techilaSemaphoreRelease. Optionally provide
%                            size and the expiration time for the
%                            semaphore. The size tells how many
%                            simultaneous reservations are allowed for the
%                            semaphore, default is one. The expiration time
%                            releases reserved semaphores automatically
%                            after timeout if they have not been already
%                            released with techilaSemaphoreRelease. By
%                            default the semaphores are not expired.
% 'StatefulProject', 'true' = Execute the project as stateful. 
%
% 'Tips', 'false'           = Show Techila usage tips. Default is true.
%
%SEE ALSO LocalCompile importdata

% Copyright 2010-2013 Techila Technologies Ltd.

function [result, varargout] = peach(varargin)

if nargin<3
    error('Usage: <a href="matlab:doc peach">peach(funcname, params, [files], peachvector, [...])</a>');
end
total=tic;

%#ok<*AGROW,*NASGU,*ST2NM,*ASGLU,*NUSED,*GFLD,*CCAT,*CTCH,*LERR>

%% Initialize mandatory input arguments
files={};
peachvector={};
funcname=varargin{1};
params=varargin{2};
if ~iscell(params)
    params={params};
end
if nargin>3 && (~ischar(varargin{3}) && ~ischar(varargin{4}))
    files=varargin{3};
    peachvector=varargin{4};
    firstVarargin=5;
elseif ischar(varargin{3})
    firstVarargin=3;
else
    peachvector=varargin{3};
    firstVarargin=4;
end

%% Initialize output arguments
result = 0;
for k=1:nargout-1
    varargout(k)={[]};
end

%% Initialize control parameters
ReturnResults = true;
ReturnResultFiles = false;
WaitForResults = true;
CleanFiles = true;
CloseHandle = true;
ForceNotCompile = false;
ForceCompile = false;
Init = true;
Uninit = true;
tmpdir = 'techila_tmp';
Messages = true;
PreParameters = '';
ProjectParameters = {};
BundleParameters = {};
BinaryBundleParameters = {};
AllowPartial = false;
projectid = false;
StreamResults = false;
OldHandle = -1;
OutputFiles = {};
CallbackMethod = {};
CallbackParams = {};
TimeLimit = 0;
ResultsRequired = 1;
RemoveProject = true;
Statistics = true;
JobInputFiles = {};
JobInputFileNames = {};
Executable = false;
MatlabRequired = true;
MexFiles = {};
DoNotCheckCRC = false;
LibraryFiles = {};
Binaries = {};
RemoteExecutable = false;
Snapshot = true;
SnapshotFiles = 'snapshot.mat';
SnapshotInterval = 15;
paramDependencies = {};
ImportData = false;
RunAsM = false;
LocalMode = false;
MatlabFeature = 'matlab';
platforms = {{'Windows', 'x86', 'mcc'}, {'Linux', 'i386', 'mcc'}, {'Linux', 'amd64', 'mcc_64'}, {'Mac OS X', 'i386', 'mcc'}, {'Mac OS X', 'x86_64', 'mcc_64'}};
jobs=[];
ResultFile=[];
handle=-1;
Wrapper=[];
WrapperParams=[];
UseProjectMessages = false;
Profile = [];
TechilaStatefulProject = false;
bundleDescription = '';
useBundle='';
dependencies=[];
ShowTips = true;

%% Define default priority and description for the project.
projectPriority = 4;
projectDescription = [funcname ' with peach'];

for i=firstVarargin:2:length(varargin)
    if strcmpi(varargin{i},'handle')
        OldHandle=varargin{i+1};
        Init=false;
    elseif strcmpi(varargin{i},'donotinit')
        Init = ~getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'messages')
        if (~getLogicalValue(varargin{i+1}))
            Messages = false;
            Statistics = false;
        else
            Messages = true;
        end
    elseif strcmpi(varargin{i},'localmode')
        LocalMode = getLogicalValue(varargin{i+1});
        Init = false;
        Uninit = false;
        CloseHandle = false;
    elseif strcmpi(varargin{i},'resultfile')
        ResultFile = varargin{i+1};
        Init = false;
        Uninit = false;
        jobs = -1;
        projectid = -1;
        ForceNotCompile = true;
        CloseHandle = false;
    end
end

%% Initialize
if Init
    inittime = tic();
    status = techilainit(varargin{firstVarargin:end});
    if status==0 && Messages
        fprintf('Techila initialized.\n');
    end
end

%Defines the TechilaManager, bundle and result management interface
%variables TECHILA, TECHILA_BUNDLES, TECHILA_PROJECTS and TECHILA_RESULTS as global,
%the management interfaces has been assigned in the techilainit() toolbox
%function.
global OK;
global TECHILA;
global TECHILA_BUNDLES;
global TECHILA_PROJECTS;
global TECHILA_RESULTS;
global TECHILA_SUPPORT;
global CLEANUP_MODE_ALL;

global peach_cputime;
global peach_realtime;
global peach_totaltime;
global peach_stats;
peach_cputime=0;
peach_realtime=0;
peach_totaltime=0;
peach_stats={};

%% Check .ini file for default configuration values
if ~isempty(TECHILA) && ismethod(TECHILA, 'getConf')
    matlabConfiguration = TECHILA.getConf('matlab');
    if ~isempty(matlabConfiguration)
        configurationKeys = matlabConfiguration.keys;
        while (true)
            if ~configurationKeys.hasNext
                break;
            end
            configurationKey = char(configurationKeys.next);
            if strncmpi(configurationKey, 'peach.', 6)
                configurationValue = char(matlabConfiguration.get(configurationKey));
                configurationKey = strrep(configurationKey, 'peach.', '');
                varargin=[varargin(1:firstVarargin-1), {configurationKey}, {configurationValue}, varargin(firstVarargin:end)];
            end
        end
    end
end

%% Parse optional control parameters
for i=firstVarargin:2:length(varargin)
    if strcmpi(varargin{i},'tmpdir')
        tmpdir=varargin{i+1};
    elseif strcmpi(varargin{i},'parameters')
        PreParameters=varargin{i+1};
    elseif strcmpi(varargin{i},'projectparameters') || strcmpi(varargin{i},'projectparams')
        ProjectParameters=[ProjectParameters varargin{i+1}];
    elseif strcmpi(varargin{i},'bundleparameters') || strcmpi(varargin{i},'bundleparams')
        BundleParameters=[BundleParameters varargin{i+1}];
    elseif strcmpi(varargin{i},'binarybundleparameters') || strcmpi(varargin{i},'binarybundleparams')
        BinaryBundleParameters=[BinaryBundleParameters varargin{i+1}];
    elseif strcmpi(varargin{i},'projectid')
        projectid=varargin{i+1};
        if projectid ~= false
            ForceNotCompile = true;
        end
    elseif strcmpi(varargin{i},'priority')
        projectPriority=varargin{i+1};
    elseif strcmpi(varargin{i},'description')
        projectDescription=varargin{i+1};
    elseif strcmpi(varargin{i},'handle')
        OldHandle=varargin{i+1};
        Init=false;
    elseif strcmpi(varargin{i}, 'callbackmethod')
        CallbackMethod=varargin{i+1};
    elseif strcmpi(varargin{i}, 'callbackparameters') || strcmpi(varargin{i}, 'callbackparams')
        CallbackParams=varargin{i+1};
    elseif strcmpi(varargin{i},'outputfiles')
        OutputFiles=[OutputFiles varargin{i+1}];
        if isempty(CallbackMethod) || ~isempty(CallbackParams)
            if islogical(ImportData) && ImportData==false
                ReturnResults = false;
                CleanFiles = false;
                CloseHandle = false;
                Uninit = false;
            end
        end
    elseif strcmpi(varargin{i},'returnresults')
        if (~getLogicalValue(varargin{i+1}))
            ReturnResults = false;
            CleanFiles = false;
            CloseHandle = false;
            Uninit = false;
            RemoveProject = false;
        else
            ReturnResults = true;
        end
    elseif strcmpi(varargin{i},'returnresultfiles')
        if (getLogicalValue(varargin{i+1}))
            ReturnResultFiles = true;
            ReturnResults = false;
            CleanFiles = false;
            CloseHandle = true;
            Uninit = true;
            RemoveProject = true;
        else
            ReturnResultFiles = false;
        end
    elseif strcmpi(varargin{i},'cleanfiles')
        CleanFiles = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'closehandle')
        CloseHandle = getLogicalValue(varargin{i+1});
        if (CloseHandle == false)
            Uninit = false;
        end
    elseif strcmpi(varargin{i},'forcecompile')
        ForceCompile = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'forcenotcompile')
        ForceNotCompile = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'donotinit')
        Init = ~getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'donotuninit')
        Uninit = ~getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'donotwait')
        WaitForResults = ~getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'messages')
        if (~getLogicalValue(varargin{i+1}))
            Messages = false;
            Statistics = false;
        else
            Messages = true;
        end
    elseif strcmpi(varargin{i},'statistics')
        Statistics = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'streamresults')
        StreamResults = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'allowpartial')
        AllowPartial = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i}, 'timelimit')
        TimeLimit=varargin{i+1};
    elseif strcmpi(varargin{i}, 'resultsrequired')
        ResultsRequired=varargin{i+1};
    elseif strcmpi(varargin{i}, 'JobInputFiles')
        JobInputFiles = [JobInputFiles varargin{i+1}];
    elseif strcmpi(varargin{i}, 'MexFiles')
        MexFiles = varargin{i+1};
    elseif strcmpi(varargin{i}, 'JobInputFileNames')
        JobInputFileNames = [JobInputFileNames varargin{i+1}];
    elseif strcmpi(varargin{i}, 'Executable')
        if (getLogicalValue(varargin{i+1}))
            Executable = true;
            MatlabRequired = false;
            ForceNotCompile = true;
        else
            Executable = false;
        end
    elseif strcmpi(varargin{i}, 'RemoteExecutable')
        if (getLogicalValue(varargin{i+1}))
            Executable = true;
            RemoteExecutable = true;
            MatlabRequired = false;
            ForceNotCompile = true;
        else
            RemoteExecutable = false;
        end
    elseif strcmpi(varargin{i},'MatlabRequired')
        MatlabRequired = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'removeproject')
        RemoveProject = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'donotcheckcrc')
        if (getLogicalValue(varargin{i+1}))
            DoNotCheckCRC = true;
        else
            DoNotCheckCRC = false;
        end
    elseif strcmpi(varargin{i},'libraryfiles')
        LibraryFiles = [LibraryFiles varargin{i+1}];
    elseif strcmpi(varargin{i},'binaries')
        Binaries = [Binaries varargin{i+1}];
        Executable = true;
        MatlabRequired = false;
        ForceNotCompile = true;
    elseif strcmpi(varargin{i},'snapshot')
        Snapshot = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'snapshotfiles')
        SnapshotFiles = varargin{i+1};
    elseif strcmpi(varargin{i},'snapshotinterval')
        SnapshotInterval = varargin{i+1};
    elseif strcmpi(varargin{i},'dependencyfiles')
        paramDependencies = [paramDependencies varargin{i+1}];
    elseif strcmpi(varargin{i},'importdata') || strcmpi(varargin{i},'importresult')
        ImportData = varargin{i+1};
        if ~iscell(ImportData)
            ImportData=getLogicalValue(ImportData);
        end
        ReturnResults = true;
        CleanFiles = true;
        CloseHandle = true;
        Uninit = true;
    elseif strcmpi(varargin{i},'runasm')
        value = varargin{i+1};
        if ~iscell(value)
            RunAsM=getLogicalValue(value);
        else
            RunAsM=true;
            MatlabFeature=value{:};
        end
        if RunAsM
            MatlabRequired=false;
        end
    elseif strcmpi(varargin{i}, 'platforms') || strcmpi(varargin{i}, 'compilationplatforms')
        platforms=varargin{i+1};
    elseif strcmpi(varargin{i},'localmode')
        LocalMode = getLogicalValue(varargin{i+1});
        Init = false;
        Uninit = false;
        CloseHandle = false;
    elseif strcmpi(varargin{i},'jobs')
        jobs = str2num(num2str(varargin{i+1}));
    elseif strcmpi(varargin{i},'resultfile')
        ResultFile = varargin{i+1};
        Init = false;
        Uninit = false;
        jobs = -1;
        projectid = -1;
        ForceNotCompile = true;
        CloseHandle = false;
    elseif strcmpi(varargin{i},'wrapper')
        Wrapper = varargin{i+1};
    elseif strcmpi(varargin{i},'wrapperparameters') || strcmpi(varargin{i},'wrapperparams')
        WrapperParams = varargin{i+1};        
    elseif strcmpi(varargin{i},'projectmessages')
        UseProjectMessages = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'profile')
        Profile = varargin{i+1};
    elseif strcmpi(varargin{i},'semaphore')
        semparams = varargin{i+1};
        semname=semparams{1};
        if length(semparams)==1
            semsize='1';
        else
            semsize=num2str(semparams{2});
            if length(semparams)==3
                semsize=[semsize ',' num2str(semparams{3})];
            end
        end
        ProjectParameters=[ProjectParameters {{['techila_semaphore_' semname], semsize}}];
    elseif strcmpi(varargin{i},'stateful')
        TechilaStatefulProject = getLogicalValue(varargin{i+1});
        ProjectParameters=[ProjectParameters {{'techila_stateful_project', 'true'}}];
        varargin=[varargin, {'UseJVM'}, {'true'}];
    elseif strcmpi(varargin{i},'bundledescription')
        bundleDescription=varargin{i+1};
    elseif strcmpi(varargin{i},'usebundle')
        useBundle=varargin{i+1};
    elseif strcmpi(varargin{i},'tips')
        ShowTips = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'usejvm')
        BinaryBundleParameters = [ {
            {'UseJVM', num2str(getLogicalValue(varargin{i+1}))}
            } BinaryBundleParameters];
    end
end

if isempty(peachvector) && (isempty(jobs) || ~isnumeric(jobs))
    error('Error in Peach: peachvector or ''Jobs'' must be specified');
end

if ~isempty(jobs)
    if ~isempty(peachvector)
        if ~isempty(files)
            error('Error in Peach: peachvector or ''Jobs'' must be specified but not both');
        else
            files = peachvector; % fix the order of the parameters
            peachvector = {};
        end
    end
end

% The number of the jobs in the project is the number of the
% elements in the peachvector.
if isempty(jobs)
    jobs=length(peachvector);
end

%% Check the parameters
% If the peach is compiled, do not try to compile user's code
if isdeployed
    ForceNotCompile = true;
end

if ~isempty(useBundle)
    ForceNotCompile = true;
end

if ForceNotCompile
    DoNotCheckCRC = true;
end    


% Check validity of parameters when running with precompiled Executable
if (~projectid && Executable)
    if isempty(Binaries)
        if ~RemoteExecutable
            if ~exist(funcname, 'file')
                error(['Error in Peach: Unable to find Executable ' funcname]);
            end
        end
    else
        for i = 1:length(Binaries)
            binary = Binaries{i};
            if ~RemoteExecutable
                if ~exist(binary{1}, 'file')
                    error(['Error in Peach: Unable to find Executable ' binary{1}]);
                end
                if i==1 && isempty(funcname)
                    [pathstr, name, ext] = fileparts(binary{1});
                    funcname=[name ext];
                end
            end
            if length(binary) < 3
                error('''Binaries'' parameter must contain {{filename, osname, processor},...}, for example {{''test'', ''Linux'', ''i386''}}');
            end
            if length(binary) < 4 && MatlabRequired
                [mcrmajor,mcrminor]=wrapmcrversion(varargin{firstVarargin:end});
                binary = [binary, [ int2str(mcrmajor) int2str(mcrminor) ]];
            end
            Binaries{i}=binary;
        end
    end
end

% If job-specific inputfiles are specified, they must match the number of
% jobs (=length of peachvector)
if (~projectid && ~isempty(JobInputFiles) && length(JobInputFiles) ~= jobs)
    error('Error in Peach: the JobInputFiles length must match the peachvector length');
end

% If MEX files are used, check that their sources exist
if ~ForceNotCompile
    if ~isempty(MexFiles)
        for i=1:length(MexFiles)
            MexFile = MexFiles{i};
            if ischar(MexFile(1))
                MexFile={MexFile};
            end
            for j=1:length(MexFile)
                MexFileTest=MexFile{j};
                if strncmp(MexFileTest, '#', 1)
                    MexFileTest=MexFileTest(2:end);
                end
                if ~exist(MexFileTest, 'file')
                    error(['Error in Peach: unable to find MEX file ' MexFile{j}]);
                end
            end
        end
    end
end

% Matlab must be required when using Matlab functions as compiled
if (~projectid && ~MatlabRequired && ~Executable && ~RunAsM)
    error('Error in Peach: Cannot use MatlabRequired=false with Executable=false and RunAsM=false');
end

%% Add snapshot parameters
if Snapshot
    BinaryBundleParameters = [ {
        {'SnapshotFiles', SnapshotFiles}, ...
        {'SnapshotInterval', num2str(SnapshotInterval)}
        } BinaryBundleParameters];
end

try
    
    if (Init)
        checkStatusCode(status);
    else
        if ~LocalMode && (isempty(TECHILA) || ~TECHILA.isInitialized) && isempty(ResultFile)
            error('Techila is not initialized! If ''DoNotInit'' is set to ''true'', please call techilainit() before peach().');
        end
    end
    
    %% Use the existing handle and optionally projectid or open a new
    %% handle
    if OldHandle ~= -1
        if Messages
            fprintf('Using old handle %d.\n', OldHandle);
        end
        handle=OldHandle;
        if ~projectid
            projectid=TECHILA_PROJECTS.getProjectId(handle);
            if (projectid > 0)
                if Messages
                    fprintf('Using old Project ID %d.\n', projectid);
                end
                ForceNotCompile = true;
            else
                projectid=false;
            end
        end
    elseif ~LocalMode && isempty(ResultFile)
        handle=TECHILA.open();
    end
    
    if handle ~= -1 && UseProjectMessages
        realHandle = TECHILA.getHandle(handle);
        if ismethod(realHandle, 'setUseProjectMessages')
            realHandle.setUseProjectMessages(true);
        else
            warning('PEACH:NOTSUPPORTED', 'ProjectMessages parameter is not supported in this version');
        end
    end
    
    if ~projectid
        %% Handle the metadatafile containing information of sourcefiles and
        %% compilations
        if ~ForceNotCompile
            fun=functions(str2func(funcname));
            if isempty(fun.file)
                error(['Error in Peach: Unable to find function ' funcname]);
            end
            % If old version of the file is found, rename it.
            filedatefile=[fun.file '.lastmod.mat'];
            if ~exist(['./' filedatefile], 'file')
                filedatefile=[funcname '.lastmod.mat'];
            else
                movefile(filedatefile, [funcname '.lastmod.mat']);
                filedatefile=[funcname '.lastmod.mat'];
            end
        else
            filedatefile=[ funcname '.lastmod.mat'];
        end
        
        % Initialize compilation metadata
        compile=0;       % Should we compile something
        ctfcrcsum=0;     % CRC sum of the compilations
        data=false;      % Metadata from the file
        filedate=0;      % Timestamp of the source files
        cfiledate=0;     % Timestamp of the compilations
        compilations={}; % The compiled files
        cfiledatestr=''; % Timestamp of the compilations in string
        randpart=[];     % Random part in bundle name
        
        % If the metadata file exists, load the metadata
        if exist(['./' filedatefile], 'file')==2
            data=load(filedatefile);
            if (isfield(data, 'mcrminor'))
                mcrminor=data.mcrminor;
            end
            if (isfield(data, 'mcrmajor'))
                mcrmajor=data.mcrmajor;
            end
            if (isfield(data, 'ctfcrcsum'))
                ctfcrcsum=str2num(num2str(data.ctfcrcsum));
            end
            if (isfield(data, 'cfiledate'))
                cfiledate=data.cfiledate;
                cfiledatestr=num2str(cfiledate*10000000000);
            end
            if (isfield(data, 'filedate'))
                filedate=data.filedate;
            end
            if (isfield(data, 'compilations'))
                compilations=data.compilations;
            end
            if (isfield(data, 'randpart'))
                randpart=data.randpart;
            end
            if ~isempty(cfiledatestr) && ctfcrcsum ~= 0
                bundleName=sprintf('%s_%0.f_%0.f_%s', funcname, str2num(cfiledatestr), ctfcrcsum, randpart);
                bundleVersion='0.0.1';
                if ~TECHILA_BUNDLES.bundleVersionExists(bundleName, bundleVersion)
                    ctfcrcsum2=0;
                    for pf=1:length(compilations)
                        if exist(char(compilations{pf}{1}), 'file')
                            ctfcrcsum2 = ctfcrcsum2+crcsum(char(compilations{pf}{1}));
                        end
                    end
                    if ctfcrcsum ~= ctfcrcsum2
                        compile=1;
                    end
                end
            end

            % If the file does not exist, use current MCR version (compiler
            % version)
        else
            [mcrmajor,mcrminor]=wrapmcrversion(varargin{firstVarargin:end});
        end
        if isempty(randpart)
            randpart = num2str(rand * 10000000000000000);
        end
        
        %% Check the parameters for function handles and therefore additional
        %% function dependencies
        if ~ForceNotCompile && (~DoNotCheckCRC || ~exist('data', 'var') || ~isstruct(data))
            for idx=1:length(params)
                if (isa(params{idx}, 'function_handle'))
                    funinfo = functions(params{idx});
                    if (~isempty(funinfo.file))
                        paramDependencies=unique([paramDependencies {funinfo.file}]);
                    end
                elseif (iscell(params{idx}))
                    par=params{idx};
                    for cellidx=1:length(par)
                        if (isa(par{cellidx}, 'function_handle'))
                            funinfo = functions(par{cellidx});
                            if (~isempty(funinfo.file))
                                paramDependencies=unique([paramDependencies {funinfo.file}]);
                            end
                        end
                    end
                elseif (isstruct(params{idx}))
                    par=params{idx};
                    strfields = fields(par);
                    for fieldidx=1:length(strfields)
                        for stridx=1:length(par)
                            fld = getfield(par(stridx), strfields{fieldidx});
                            if (isa(fld, 'function_handle'))
                                funinfo = functions(fld);
                                if (~isempty(funinfo.file))
                                    paramDependencies=unique([paramDependencies {funinfo.file}]);
                                end
                            end
                        end
                    end
                end
            end
        end
        paramDependencies = unique(paramDependencies);
        
        pccrc = 0;
        
        %% Get the sum of CRCsums of Matlab methods
        if ~DoNotCheckCRC || Executable || ~exist('data', 'var') || ~isstruct(data)
            crctime = tic();
            if ~Executable
                if ~ForceNotCompile
                    dependencies = getDependencies(funcname);
                    pccrc = getFuncTreeCRCSum(funcname, dependencies) + crcsum('peachclient.m');
                    if ~isempty(paramDependencies)
                        for i=1:length(paramDependencies)
                            paramdep=paramDependencies{i};
                            if strncmp(paramdep, '#', 1)
                                pccrc = pccrc + getFuncTreeCRCSum(paramdep(2:end));
                            else
                                pccrc = pccrc + getFuncTreeCRCSum(paramdep);
                            end
                        end
                    end
                    if ~isempty(MexFiles)
                        for i=1:length(MexFiles)
                            MexFile=MexFiles{i};
                            if (ischar(MexFile(1)))
                                MexFile = {MexFile};
                            end
                            for j=1:length(MexFile)
                                MexFileTest=MexFile{j};
                                if strncmp(MexFileTest, '#', 1)
                                    MexFileTest=MexFileTest(2:end);
                                end
                                pccrc = pccrc + crcsum(MexFileTest)+abs(java.lang.String(MexFileTest).hashCode);
                            end
                        end
                    end
                end
            else
                % If the funcname is not Matlab function, but precompiled executable,
                % use it's crcsum. If RemoteExecutable, crcsum=0.
                if RemoteExecutable
                    pccrc=0;
                else
                    if isempty(Binaries)
                        pccrc = crcsum(funcname)+abs(java.lang.String(funcname).hashCode);
                    else
                        pccrc = 0;
                        for i=1:length(Binaries)
                            binary = Binaries{i};
                            pccrc = pccrc + crcsum(binary{1})+abs(java.lang.String(binary{1}).hashCode);
                        end
                    end
                end
            end
            pccrc = pccrc + getBundleParametersCRC(BinaryBundleParameters);
        else
            if exist('data', 'var') && isstruct(data) && isfield(data, 'pccrc')
                pccrc = data.pccrc;
            else
                if isempty(useBundle)
                    error('Error in Peach: DoNotCheckCRC=true requires valid .lastmod.mat file');
                end
            end
        end
        

        
        %% Create temporary directory if it does not exist
        if (exist(tmpdir, 'dir') == 0)
            TECHILA_SUPPORT.log('INFO', ['creating dir ' tmpdir]);
            mkdir(tmpdir);
        end
                
        %% Check if the code needs to be compiled.
        if ~ForceCompile && ~ForceNotCompile
            % Find the file containing the function to be executed on the Techila environment.
            file=dir(fun.file);
            
            % If the file has been compiled before, check if the source files
            % have been modified since and compile again if needed. Also the
            % MCR version is checked.
            filedate=getdatenum(file);
            [mcrmajor,mcrminor]=wrapmcrversion(varargin{firstVarargin:end});
            if mcrmajor==0 && mcrminor==0
                error('Error in Peach: Could not find Matlab Compiler');
            end
            % Check the values saved after the last compilation. If they are
            % older or the file is not found, force compilation.
            if exist('data', 'var') && isstruct(data)
                if (data.filedate<filedate ...
                        || ~isfield(data, 'pccrc') ...
                        || ~(strcmp(num2str(data.pccrc),num2str(pccrc))) ...
                        || ~isfield(data, 'BinaryBundleParameters') ...
                        || ~cellcmp(data.BinaryBundleParameters, BinaryBundleParameters) ...
                        || ~isfield(data, 'compilations') ...
                        || isempty(compilations))
                    compile=1;
                end
                if ~isfield(data, 'mcrmajor') ...
                        || ~(data.mcrmajor == mcrmajor ...
                        && strcmp(num2str(data.mcrminor),num2str(mcrminor)))
                    compile=1;
                end
            else
                compile=1;
            end
        else
            if ForceCompile
                compile=1;
            end
            if ForceNotCompile
                compile=0;
            end
        end
        
        %% Get system architecture and operating system name
        arch = char(java.lang.System.getProperty('os.arch'));
        osname = char(java.lang.System.getProperty('os.name'));
        
        
        %% Compile the peachclient.m and the file containing funcname (and
        %% the other files which are imported) if needed
        if RunAsM
            % Do not compile, but run as M-files
            if exist([tmpdir '/peachclient.zip'], 'file')
                delete([tmpdir '/peachclient.zip']);
            end
            peachclientfun = functions(str2func('peachclient'));
            printerrorfun = functions(str2func('printError'));
            funfile = functions(str2func(funcname));
            dependencies=getDependencies(funcname);
            for pidx=1:length(paramDependencies)
                paramdep=paramDependencies{pidx};
                if strncmp(paramdep, '#', 1)
                    paramdep=paramdep(2:end);
                end
                dependencies=[dependencies getDependencies(paramdep)];
            end
            zipfiles = {peachclientfun.file, printerrorfun.file, fun.file, dependencies{:}};
            zip([tmpdir '/peachclient.zip'], zipfiles, tmpdir);
            file=dir([tmpdir '/peachclient.zip']);
            if ~isempty(file)
                crctime2 = tic();
                cfiledate=getdatenum(file);
                cfiledatestr=num2str(cfiledate*10000000000);
                % Get the CRC checksum of ZIP file
                ctfcrcsum = crcsum([tmpdir '/peachclient.zip']);
                [mcrmajor,mcrminor]=wrapmcrversion(varargin{firstVarargin:end});
                mcrver = [ num2str(mcrmajor) num2str(mcrminor) ];
                compilations={};
                for i = 1:length(platforms)
                    compilations = [compilations, {{[tmpdir '/peachclient.zip'], platforms{i}{1}, platforms{i}{2}, mcrver}}];
                end
            end
        else
            % Compile locally if needed
            % The version of Matlab runtime libraries.
            libver = [ num2str(mcrmajor) num2str(mcrminor) ];
            localcompilation = {[tmpdir '/peachclient.zip'], osname, arch, libver};            
            if compile
                if isempty(dependencies)
                    dependencies=getDependencies(funcname);
                end
                for pidx=1:length(paramDependencies)
                    paramdep=paramDependencies{pidx};
                    if strncmp(paramdep, '#', 1)
                        dependencies=[dependencies paramdep];
                    else
                        dependencies=[dependencies getDependencies(paramdep)];
                    end
                end
                localcompilation = localCompile(funcname, 'paramDependencies', dependencies, 'MexFiles', MexFiles, varargin{firstVarargin:end});
                localcompilation = localcompilation{:};
            end
            if compile || isempty(cfiledatestr) || ctfcrcsum == 0 || isempty(compilations)
                % Get the creation time of ZIP file
                file=dir(localcompilation{1});
                if ~isempty(file)
                    crctime2 = tic();
                    cfiledate=getdatenum(file);
                    cfiledatestr=num2str(cfiledate*10000000000);
                    % Get the CRC checksum of ZIP file
                    ctfcrcsum = crcsum(localcompilation{1});
                    compilations = {localcompilation};
                end
            end
        end
        
        %% If precompiled binary is used instead of Matlab function, generate
        %% the necessary metadata from executable.
        if Executable
            if RemoteExecutable
                compilations = {};
                if ~isempty(Binaries)
                    for i=1:length(Binaries)
                        binary = Binaries{i};
                        compilations = [compilations {{{}, binary{2}, binary{3}, ''}}];
                    end
                end
                ctfcrcsum=pccrc;
                cfiledatestr='0';
                filedate=0;
            else
                ctfcrcsum=pccrc;
                if isempty(Binaries)
                    if MatlabRequired
                        compilations = {{funcname, osname, arch, [ num2str(mcrmajor) num2str(mcrminor) ]}};
                    else
                        compilations = {{funcname, osname, arch, ''}};
                    end
                    file=dir(funcname);
                    cfiledate=getdatenum(file);
                else
                    compilations={};
                    for i=1:length(Binaries)
                        binary = Binaries{i};
                        if MatlabRequired
                            compilations = [compilations {{binary{1}, binary{2}, binary{3}, binary{4}}}];
                        else
                            compilations = [compilations {{binary{1}, binary{2}, binary{3}, ''}}];
                        end
                        file=dir(binary{1});
                        cfiledatetmp=getdatenum(file);
                        if ~exist('cfiledate', 'var') || cfiledatetmp>cfiledate
                            cfiledate=cfiledatetmp;
                        end
                    end
                end
                cfiledatestr=num2str(cfiledate*10000000000);
                filedate=cfiledate;
            end
        end
        
        %% Handle metadata
        % If the peach.m is compiled or crc is not computed, do not save the metadata
        if ~isdeployed && exist('pccrc', 'var')
            filedatefile = [ funcname '.lastmod.mat'];
            save(filedatefile, 'filedate', 'mcrmajor', 'mcrminor', 'pccrc', 'ctfcrcsum', 'compilations', 'cfiledate', 'BinaryBundleParameters', 'randpart');
        end
        
        % Check that the metadata is loaded or generated.
        if isempty(useBundle) && (isempty(cfiledatestr) || (ctfcrcsum==0 && ~RemoteExecutable))
            error('Error in Peach: Unable to find metadata (*.lastmod.mat) of compilation');
        end
        
        %% Create binarybundle name and description
        % Description, name and version of the binarybundle. The name of the
        % bundle depends on function name and EXE file timestamp and CRC.
        if isempty(bundleDescription)
            bundleDescription=[funcname ' with peach'];
        end
        if ~isempty(useBundle)
            bundleName=useBundle;
        else
            bundleName=sprintf('%s_%0.f_%0.f_%s', funcname, str2num(cfiledatestr), ctfcrcsum, randpart);
        end
        bundleVersion='0.0.1';
        
        %Construct the framework internal name of the binary bundle, to be used
        %in the import statement later.
        binarybundlefullname = [ bundleName ';specification-version=' ...
            bundleVersion ];
        
        % Files included in the bundles and to be copied to execution
        % directory on the clients.
        if RemoteExecutable
            copyfiles = '';
            externalresources = '';
            fileparams = {};
        else
            copyfiles = 'peachclient, techila_peach_inputdata.mat';
            externalresources = 'techila_peach_inputdata.mat;resource=techila_peach_inputdata';
            fileparams = {{'techila_peach_inputdata.mat', [tmpdir '/techila_peach_inputdata.mat']}};
        end
        
        %% Create databundles
        % If there are data files defined in the parameters, they are also
        % added to the bundle.
        databundleimports = '';
        if ~LocalMode && ~isempty(files)
            databundles={};
            if ischar(files{1})
                files={files};
            end
            if Messages
                fprintf('Creating %d databundle(s)...\n', length(files));
            end
            for fl=1:length(files)
                bundletime=tic;
                filelist=files{fl};
                bundlecrcsum=0;
                bundlefileparams={};
                bundlelength=0;
                if ~isempty(externalresources)
                    externalresources = [ externalresources ','];
                end
                externalresources = [ externalresources 'datafiles_' num2str(fl) ';file=.;resource=datafiles_' num2str(fl) ];
                for f=1:length(filelist)
                    if iscell(filelist{f})
                        cellfile=filelist{f};
                        filelist{f}=cellfile{:};
                    end
                    if ~exist(filelist{f},'file')
                        error(['File not found: ' filelist{f}]);
                    end
                    if ~exist([ './' filelist{f}], 'file')
                        fileloc=which(filelist{f});
                        if ~isempty(fileloc)
                            filelist{f}=fileloc;
                        end
                    end
                    bundlecrcsum=bundlecrcsum+crcsum(filelist{f})+abs(java.lang.String(filelist{f}).hashCode);
                    fileinfo=dir(filelist{f});
                    bundlelength=bundlelength+fileinfo.bytes;
                    [path, name, ext]=fileparts(filelist{f});
                    bundlefileparams = [ bundlefileparams {{ [name ext], filelist{f} }} ];
                    if length(LibraryFiles) < fl || ~getLogicalValue(LibraryFiles{fl})
                        if ~isempty(copyfiles)
                            copyfiles = [ copyfiles ',' ];
                        end
                        copyfiles = [ copyfiles [name ext] ];
                    end
                    if ~isempty(externalresources)
                        externalresources = [ externalresources ','];
                    end
                    externalresources = [ externalresources [name ext] ';resource=datafiles_' num2str(fl) ];
                end
                dataBundleName = sprintf('data_%0.f_%0.f', fl, bundlecrcsum);
                dataBundleVersion = '0.0.1';
                databundlefullname = [ bundleName '.{user}.' dataBundleName ];
                databundleimports = [databundleimports ',' databundlefullname];
                expirationperiod = 3600000;
                if bundlelength > 1048576
                    expirationperiod = 86400000;
                end
                if ~TECHILA_BUNDLES.bundleVersionExists(databundlefullname, dataBundleVersion)
                    if Messages
                        fprintf('Creating Datafile Bundle %d...\n', fl);
                    end
                    createBundle(handle, bundleName, dataBundleName, '', dataBundleVersion, ...
                        databundlefullname, databundlefullname, ...
                        '{user}', ['datafiles_' int2str(fl)], binarybundlefullname, ...
                        {{'ExpirationPeriod', int2str(expirationperiod)}}, ...
                        bundlefileparams, 'approve', 'false', varargin{firstVarargin:end});
                end
            end
        end
        
        %% Create JobData bundles
        % If there are job-specific input files, create a bundle of them.
        JobFileParameters = '';
        if ~isempty(JobInputFiles)
            bundlecrcsum=0;
            bundlefileparams={};
            bundlelength=0;
            bundletime=tic;
            zipmode=0;
            if isempty(JobInputFileNames) || length(JobInputFileNames) < length(JobInputFiles{1})
                for f=1:length(JobInputFiles{1})
                    JobInputFileNames = [JobInputFileNames {['jobinputfile' num2str(f) '.mat']}];
                end
            end
            for fl=1:length(JobInputFiles)
                filelist=JobInputFiles{fl};
                if ~isempty(filelist) && ischar(filelist(1))
                    filelist={filelist};
                end
                if length(filelist) > 1
                    zipmode=1;
                end
                for f=1:length(filelist)
                    bundlecrcsum=bundlecrcsum+crcsum(filelist{f})+abs(java.lang.String(filelist{f}).hashCode);
                end
            end
            if ~LocalMode
            jobDataBundleName = sprintf('data_%0.f_%0.f', fl, bundlecrcsum);
            jobDataBundleVersion = '0.0.1';
            jobDatabundlefullname = [ bundleName '.' char(TECHILA.getUserLogin()) '.' jobDataBundleName ];
            end
            if ~LocalMode && ~TECHILA_BUNDLES.bundleVersionExists(jobDatabundlefullname, jobDataBundleVersion)
                for fl=1:length(JobInputFiles)
                    filelist=JobInputFiles{fl};
                    if ~isempty(filelist) && ischar(filelist(1))
                        filelist={filelist};
                    end
                    if length(filelist) > 1
                        zos = java.util.zip.ZipOutputStream(java.io.FileOutputStream([tmpdir '/jobinput_' num2str(fl) '.zip']));
                        zos.setLevel(0);
                        buffer = java.nio.ByteBuffer.allocate(10240);
                        for f=1:length(filelist)
                            [flpath, flname, flsuffix]=fileparts(filelist{f});
                            jifname = strrep(strrep(JobInputFileNames{f}, '<original>', [flname flsuffix]), '<originalpath>', [flpath '/' flname flsuffix]);
                            ze = java.util.zip.ZipEntry(jifname);
                            zos.putNextEntry(ze);
                            ifc = java.io.FileInputStream(filelist{f}).getChannel();
                            while 1
                                buffer.clear();
                                count = ifc.read(buffer);
                                if count > 0
                                    zos.write(buffer.array(), 0, count);
                                else
                                    break;
                                end
                            end
                            ifc.close();
                        end
                        zos.flush();
                        zos.close();
                        bundlefilename = ['input_' num2str(fl)];
                        bundlefileparams = [ bundlefileparams {{ bundlefilename, [tmpdir '/jobinput_' num2str(fl) '.zip'] }} ];
                    else
                        for f=1:length(filelist)
                            bundlefilename = ['input_' num2str(fl) '_' num2str(f)];
                            bundlefileparams = [ bundlefileparams {{ bundlefilename, filelist{f} }} ];
                        end
                    end
                end
                if Messages
                    fprintf('Creating Jobdata Bundle...\n');
                end
                createBundle(handle, bundleName, jobDataBundleName, '', jobDataBundleVersion, ...
                    jobDatabundlefullname, jobDatabundlefullname, ...
                    '{user}', '', '', {}, bundlefileparams, 'approve', 'false', varargin{firstVarargin:end});
                if zipmode == 1
                    for fl=1:length(JobInputFiles)
                        delete([tmpdir '/jobinput_' num2str(fl) '.zip']);
                    end
                end
            end
            filelist=JobInputFiles{1};
            if ~isempty(filelist) && ischar(filelist(1))
                filelist={filelist};
            end
            if ~LocalMode
                if zipmode == 1
                    JobFileParameters = [JobFileParameters ['%Z(%B(jobinput;bundle=' jobDatabundlefullname ';file=input_%P(jobidx)))']];
                else
                    for f=1:length(filelist)
                        JobInputFileName = JobInputFileNames{f};
                        JobFileParameters = [JobFileParameters ['%B(jobinput' num2str(f) ';bundle=' jobDatabundlefullname ';returnfile=false;file=input_%P(jobidx)_' num2str(f) ';dest=' JobInputFileName ')']];
                    end
                end
            end
        end
        
        %% Initialize parameters for binary bundle
        clientos='';
        natives = '';
        environment = 'USERPROFILE;value="%C(tmpdir,PGET)",MCR_CACHE_ROOT;value="%C(tmpdir,PGET)";appenddefault=true';
        imports = '';
        binaryfileparams = {};
        internalresources = '';
        
        win64use32b=true;
        win64=false;
        mac64use32b=true;
        mac64=false;
        
        for pf=1:length(compilations)
            os=char(compilations{pf}{2});
            processor=char(compilations{pf}{3});
            if strncmpi(os, 'Windows', 7)
                if strncmpi(processor, 'amd64', 5)
                    win64use32b=false;
                end
            elseif strncmpi(os, 'Mac OS X', 8)
                if strncmpi(processor, 'x86_64', 6)
                    mac64use32b=false;
                end                
            end
        end
        %% Generate more metadata for different compilations.
        for pf=1:length(compilations)
            if ~isempty(compilations{pf}{1})
                [pathstr, name, ext] = fileparts(compilations{pf}{1});
                binaryfileparams = [binaryfileparams {{[name ext], compilations{pf}{1}}}];
            end
            os=char(compilations{pf}{2});
            processor=char(compilations{pf}{3});
            mcrver=compilations{pf}{4};
            
            
            if strncmpi(os, 'Windows', 7)
                os = 'Windows';
                oslist = {'Windows 2000', 'Windows XP', 'Windows Vista', 'Windows 7', 'Windows 2003', 'Windows Server 2008', 'Windows Server 2008 R2'};
                if strcmpi(processor, 'x86')
                    if win64 || ~win64use32b
                        processor={processor};
                    else
                        processor={processor, 'amd64'};
                        win64 = true;
                    end
                else
                    win64use32b = false;
                    if win64
                        continue
                    else
                        processor={processor};
                        win64 = true;
                    end
                end
            elseif strncmpi(os, 'Mac OS X', 8)
                os = 'Mac OS X';
                oslist = {os};
                if strcmpi(processor, 'i386')
                    if mac64 || ~mac64use32b
                        processor={processor};
                    else
                        processor={processor, 'x86_64'};
                        mac64=true;
                    end
                elseif strcmpi(processor, 'x86_64')
                    mac64use32b = false;
                    if mac64
                        continue
                    else
                        processor={processor};
                        mac64 = true;
                    end
                else
                    processor={processor};
                end
                if ~RemoteExecutable
                    pcFun=functions(str2func('peachclient'));
                    pcDir=fileparts(pcFun.file);
                    binaryfileparams = [binaryfileparams {{'peachclient.sh', [pcDir '/peachclient.sh']}}];
                    copyfiles = [copyfiles ',peachclient.sh;osname=Mac OS X'];
                end
            else
                oslist = {os};
                processor={processor};
            end
            for proci=1:length(processor)
                if ~RemoteExecutable
                for osi=1:length(oslist)
                    if ~isempty(natives)
                        natives = [natives ','];
                    end
                    natives = [natives name ext ];
                    if ~isempty(oslist{osi})
                        natives = [natives ';osname=' oslist{osi}];
                    end
                    if ~isempty(processor{proci})
                        natives = [natives ';processor=' processor{proci}];
                    end
                    if ~((length(oslist{osi})>=7 && strcmpi(oslist{osi}(1:7), 'Windows') && strcmpi(processor{proci}, 'amd64') && win64use32b) || ...
                            (length(oslist{osi})>=8 && strcmpi(oslist{osi}(1:8), 'Mac OS X') && strcmpi(processor{proci}, 'x86_64') && mac64use32b))
                        if MatlabRequired
                            if ~isempty(imports)
                                imports = [imports ','];
                            end
                            imports = [imports 'fi.techila.grid.cust.common.library.matlab.v' mcrver '.client;specification-version=na'];
                            if ~isempty(oslist{osi})
                                imports = [imports ';osname=' oslist{osi} ];
                            end
                            if ~((strcmpi(os, 'Windows') && win64use32b) || (strcmpi(os, 'Mac OS X') && mac64use32b))
                                imports = [imports ';processor=' processor{proci}];
                            end
                        end
                    end
                    
                end
                end
                if ~isempty(clientos)
                    clientos = [clientos ';'];
                end
                
                if ~isempty(os)
                    clientos = [ clientos os ];
                    if ~isempty(processor{proci})
                        clientos = [ clientos ',' processor{proci}];
                    end
                end
                
                if strcmpi(processor{proci}, 'amd64') || strcmpi(processor{proci}, 'x86_64')
                    if strcmpi(os, 'Windows')
                        adir='win64';
                    elseif strcmpi(os, 'Mac OS X')
                        adir='maci64';
                    else
                        adir='glnxa64';
                        javadir='amd64';
                    end
                else
                    if strcmpi(os, 'Windows')
                        adir='win32';
                    elseif strcmpi(os, 'Mac OS X')
                        adir='maci';
                    else
                        adir='glnx86';
                        javadir='i386';
                    end
                end
                
                if ~((strcmpi(os, 'Windows') && strcmpi(processor{proci},'amd64') && win64use32b) || (strcmpi(os, 'Mac OS X') && strcmpi(processor{proci},'x86_64') && mac64use32b))
                    if ~isempty(internalresources)
                        internalresources = [internalresources ','];
                    end
                    if MatlabRequired
                        externalresources = [externalresources ',matlab;resource=matlab;file=' processor{proci} '/' os '/v' mcrver '/runtime/' adir ';osname=' os ];
                        if ~((strcmpi(os, 'Windows') && win64use32b) || (strcmpi(os, 'Mac OS X') && mac64use32b))
                            if ~isempty(processor{proci})
                                externalresources = [externalresources ';processor=' processor{proci}];
                            end
                        end
                    end
                    if ~Executable
                        if strcmpi(os, 'Mac OS X')
                            internalresources = ['peachclient.sh;file=peachclient.sh;osname=Mac OS X,' internalresources];
                        end
                        internalresources = [internalresources 'peachclient;file=' name ext ';extract=1'];
                    else
                        if ~RemoteExecutable
                            internalresources = [internalresources 'peachclient;file=' name ext];
                        end
                    end
                    if ~isempty(os)
                        internalresources = [internalresources ';osname=' os];
                        if ~((strcmpi(os, 'Windows') && win64use32b) || (strcmpi(os, 'Mac OS X') && mac64use32b))
                            if ~isempty(processor{proci})
                                internalresources = [internalresources ';processor=' processor{proci}];
                            end
                        end
                    end
                end
                if strcmpi(os, 'Windows')
                    environment = [environment ',WINDIR;value="%C(WINDIR,ENVGET)",NUMBER_OF_PROCESSORS;value="%C(NUMBER_OF_PROCESSORS,ENVGET)",SYSTEMROOT;value="%C(SYSTEMROOT,ENVGET)";osname=Windows;processor=' processor{proci} ];
                elseif strcmpi(os, 'Linux')
                    environment = [environment ',HOME;value="%C(tmpdir,PGET)";osname=Linux;processor=' processor{proci}];
                elseif strcmpi(os, 'Mac OS X')
                    environment = [environment ',HOME;value="%C(tmpdir,PGET)";osname=Mac OS X;processor=' processor{proci}];
                end
                if MatlabRequired
                    if strcmpi(os, 'Windows')
                        environment = [environment ',PATH;value="%C(%L(matlab);,PATH,ENVGET,|)";osname=Windows;processor=' processor{proci} ];
                    elseif strcmpi(os, 'Linux')
                        environment = [environment ',PATH;value="%C(%L(matlab):,PATH,ENVGET,|)";osname=Linux;processor=' processor{proci} ',LD_LIBRARY_PATH;value="%L(matlab):%L(matlab)/../../sys/os/' adir '/:%L(matlab)/../../bin/' adir '/:%L(matlab)/../../sys/java/jre/' adir '/jre/lib/' javadir '/server/";osname=Linux;processor=' processor{proci}];
                    elseif strcmpi(os, 'Mac OS X')
                        environment = [environment ',PATH;value="%C(%L(matlab):,PATH,ENVGET,|)";osname=Mac OS X;processor=' processor{proci} ',XAPPLRESDIR;value="%L(matlab)/../../X11/app-defaults";osname=Mac OS X;processor=' processor{proci} ',DYLD_LIBRARY_PATH;value="%L(matlab):%L(matlab)/../../sys/os/' adir '/:%L(matlab)/../../bin/' adir '/";osname=Mac OS X;processor=' processor{proci}];
                    end
                end
            end
        end
        
        if (win64 && win64use32b) || (mac64 && mac64use32b)
            % Support executing 32bit code on 64bit environments.
            ProjectParameters = [ ProjectParameters {{'techila_force32bit','true'}}];
            platforms64b='';
            if win64 && win64use32b
                platforms64b = 'Windows,amd64';
            end
            if ~isempty(platforms64b)
                platforms64b = [ platforms64b ';' ];
            end
            if mac64 && mac64use32b
                platforms64b = [ platforms64b 'Mac OS X,x86_64'];
            end
            ProjectParameters = [ ProjectParameters {{'techila_force32bit_platforms', platforms64b}}];
        end
        
        if ~LocalMode && ~isempty(clientos)
            workerdata = TECHILA.getServerData('worker');
            if strcmpi('worker', workerdata)
                ProjectParameters = [ ProjectParameters {{'techila_worker_os', clientos}} ];
            else
                ProjectParameters = [ ProjectParameters {{'techila_client_os', clientos}} ];
            end
        end
        
        %% Create binary bundle if it doesn't already exist
        if LocalMode
            [ignore, ignore, ignore]=rmdir('techila_exec', 's');
            mkdir('techila_exec');
            for file=1:length(binaryfileparams)
                copyfile(binaryfileparams{file}{2}, 'techila_exec');
            end
            unzip('techila_exec/peachclient.zip', 'techila_exec'); 
        elseif ~TECHILA_BUNDLES.bundleVersionExists(bundleName, bundleVersion)
            signedBundleTime=tic;
            
            % Extraparameters telling which files are copied to the execution
            % environment, which file is used as executable and which
            % parameters are delivered to the executable. The bundle is removed
            % from the clients 1 hour after the computation is completed.
            if Executable
                if isempty(Binaries)
                    if RemoteExecutable
                        peachExecutable = funcname;
                    else
                        file = dir(funcname);
                        peachExecutable = file.name;
                    end
                else
                    peachExecutable = '';
                    for i=1:length(Binaries)
                        binary = Binaries{i};
                        if ~isempty(peachExecutable)
                            peachExecutable = [ peachExecutable ',' ];
                        end
                        if RemoteExecutable
                            peachExecutable = [ peachExecutable binary{1} ];
                        else
                            [bindir, binname, binext] = fileparts(binary{1});
                            peachExecutable = [ peachExecutable binname binext ];
                        end
                        if ~isempty(binary{2})
                            peachExecutable = [ peachExecutable ';osname=' binary{2} ];
                        end
                        if ~isempty(binary{3})
                            peachExecutable = [ peachExecutable ';processor=' binary{3} ];
                        end
                    end
                end
            elseif RunAsM
                peachExecutable = ['%A(' MatlabFeature ')'];
            elseif ~isempty(Wrapper)
                peachExecutable = Wrapper;
            else
                peachExecutable = 'peachclient;osname=Linux,peachclient.sh;osname=Mac OS X,peachclient.exe;osname=Windows';
            end
            extraparams = [ {
                {'InternalResources', internalresources}, ...
                {'Environment', environment}, ...
                {'Imports', ''}, ...
                {'PostImports', imports}, ...
                {'ExternalResources', externalresources} ...
                {'Executable', peachExecutable}, ...
                {'ExpirationPeriod', '604800000'} ...
                } BinaryBundleParameters];
            
            % Create a signed bundle of the given information. Matlab
            % imports are added already above.

            if Messages
                fprintf('Creating Executor Bundle...\n');
            end
            createSignedBundle(handle, bundleName, bundleDescription, ...
                bundleVersion, natives, extraparams, binaryfileparams, {'skipmatlab', true}, {'approve', false});

        end
        
        bundleCreateTime = tic;
        % Save the information of the function name and the parameters to
        % techila_peach_inputdata file.
        if isempty(peachvector)
            pvdim=[jobs 1];
        else
            pvdim = size(peachvector);
            peachvector = reshape(peachvector,1,numel(peachvector));
        end
		paramsize=whos('params');
        if paramsize.bytes>=2^31
            save([tmpdir '/techila_peach_inputdata.mat'], 'peachvector', 'funcname', 'params', 'Snapshot', 'SnapshotInterval', 'SnapshotFiles', 'TechilaStatefulProject', '-v7.3');
        else
            save([tmpdir '/techila_peach_inputdata.mat'], 'peachvector', 'funcname', 'params', 'Snapshot', 'SnapshotInterval', 'SnapshotFiles', 'TechilaStatefulProject');
        end
        if ~isempty(Profile)
            if iscell(Profile)
                TechilaProfile=true;
                for profid=1:length(Profile)
                    profparam=Profile{profid};
                    if length(profparam)==2 && strncmpi(profparam{1},'Techila', 7)
                        eval([profparam{1} '=' profparam{2} ';']);
                    end
                end
            elseif getLogicalValue(Profile)
                TechilaProfile=true;
            end
            if TechilaProfile
                save([tmpdir '/techila_peach_inputdata.mat'], 'TechilaProfile', '-append');
            end
        end
        % Create databundle containing techila_peach_inputdata.mat
        dataBundleName = sprintf('data_%0.f', now*10000000000);
        dataBundleVersion = '0.0.1';
        databundlefullname = [ bundleName '.{user}.' dataBundleName ];
        
        % Define resultfiles
        if ~isempty(OutputFiles)
            resultfiles = '';
            for of=1:length(OutputFiles)
                if of>1
                    resultfiles = [ resultfiles ',' ];
                end
                resultfiles = [ resultfiles 'output' num2str(of) ';file=' OutputFiles{of} ];
            end
            BundleParameters = [ BundleParameters, {{'ResultJobSuffix', '.zip'}}];
        else
            resultfiles='output;file=result.mat';
            BundleParameters = [ BundleParameters, {{'ResultJobSuffix', '.mat'}}];
        end
        
        % For compiled Matlab methods (with peachclient.m), the only
        % parameter needed is jobid, all the other values are read from
        % parameter bundle. For the executables, the parameter list
        % contains the values from the peach parameter array.
        Parameters = '';
        createAsJobs = 0;
        if Executable
            for p=1:length(params)
                Parameters = [Parameters num2str(params{p}) ' '];
            end
            Parameters = [Parameters JobFileParameters];
            if ~isempty(strfind(Parameters, '<param'))
                if ~isempty(strfind(Parameters, '<param1'))
                    createAsJobs = 2;
                else
                    createAsJobs = 1;
                end
                Parameters = regexprep(Parameters, '<param([0-9]*)>', '%P(param$1)');
            end
        elseif RunAsM
            Parameters = '-nojvm -nosplash -nodesktop -sd "%P(tmpdir)" -minimize -wait -r peachclient(%P(jobidx));';
            ProjectParameters = [ ProjectParameters, {{'techila_client_features', ['(' MatlabFeature '=*)']}}];
            if ~isempty(JobFileParameters)
                Parameters = [Parameters ' ' JobFileParameters];
            end
        else
            Parameters = '%P(jobidx)';
            if ~isempty(JobFileParameters)
                Parameters = [Parameters ' ' JobFileParameters];
            end
        end
        if ~isempty(PreParameters)
            Parameters = [Parameters ' ' PreParameters];
        end
        if ~isempty(Wrapper) && ~isempty(WrapperParams)
            Parameters = strrep(WrapperParams, '<peachparameters>', Parameters);
        end
        
        % Input and output files (and libraries) to be added to data bundle
        % metadata.
        BundleParameters = [ {
            {'Copy', copyfiles}, ...
            {'ExternalResources', externalresources}, ...
            {'OutputFiles', resultfiles}, ...
            {'Parameters', Parameters}, ...
            {'ExpirationPeriod', '3600000'}, ...
            } BundleParameters ];
        
        % Create parameter bundle.

        if LocalMode
            copyfile([tmpdir '/techila_peach_inputdata.mat'], 'techila_exec');
            for file=1:length(files)
                copyfile(files{file}{1}, 'techila_exec');
            end
        else
            if Messages
                fprintf('Creating Parameter Bundle...\n');
            end
        createBundle(handle, bundleName, dataBundleName, '', dataBundleVersion, ...
            [binarybundlefullname ',' databundlefullname databundleimports], databundlefullname, ...
            '{user}', 'techila_peach_inputdata', binarybundlefullname, ...
            [BundleParameters {{'ExpirationPeriod', '3600000'}}], ...
            fileparams, varargin{firstVarargin:end});
        end
        
        
        % Remove temporarily saved local inputdata file.
        delete([tmpdir '/techila_peach_inputdata.mat']);
        
        % Binds the databundle to be the base for the project to be created.
        if ~LocalMode
        checkStatusCode(TECHILA_BUNDLES.useBundle(handle, databundlefullname));
        end
                
        % Create a new project.
        projectCreateTime=tic;
        if LocalMode
            
        elseif createAsJobs>0 && ~isempty(peachvector)
            checkStatusCode(TECHILA_PROJECTS.createProject(handle, projectPriority, projectDescription));
            checkStatusCode(setProjectParams(handle, ProjectParameters));
            checkStatusCode(TECHILA_PROJECTS.addUserClientsToProject(handle));
            for jobid=1:jobs
                if createAsJobs==1
                    checkStatusCode(createJob(handle, {{'param', peachvector(jobid)}}));
                else
                    pvcell = peachvector{jobid};
                    jobparams={};
                    for pvid=1:length(pvcell)
                        jobparams = [jobparams, {{['param' num2str(pvid)], pvcell{pvid}}}];
                    end
                    checkStatusCode(createJob(handle, jobparams));
                end
            end
            checkStatusCode(TECHILA_PROJECTS.flushCachedJobs(handle));
            checkStatusCode(TECHILA_PROJECTS.markAllJobsCreated(handle));
            checkStatusCode(TECHILA_PROJECTS.startProject(handle));
        else
            checkStatusCode(createProject(handle, projectPriority, projectDescription, ...
                [ProjectParameters {{'jobs', jobs}}]));
        end
        
        %Get the id of the created project and write it to the console. This
        %information is also used in the output filename.
        if LocalMode
            projectid = -1;
        else
        projectid = TECHILA_PROJECTS.getProjectId(handle);
        end
        if Messages
            fprintf('Project ID %d created (%d jobs)\n', projectid, jobs);
            if ShowTips
                fprintf('NOTE: For the first Project, it may take extra time to prepare the Techila Distributed Computing Engine environment.\n      This can range from 10 minutes to 1.5 hours depending on the required configuration steps.\n');
            end
        end
        
    elseif isempty(ResultFile)
        TECHILA_PROJECTS.setProjectId(handle, projectid);
    end
    
    extratime=tic();
    
    %% If the results are not waited, return the handle instead of results.
    % Optionally clean the environment and close the handle. If the handle
    % is closed, the projectid of the project is returned.
    if ~WaitForResults
        if (CleanFiles)
            TECHILA.cleanup(handle, CLEANUP_MODE_ALL);
        end
        if (CloseHandle)
            result = TECHILA_PROJECTS.getProjectId(handle);
            TECHILA.close(handle); %Closes the project handle.
        else
            result = handle;
        end
        if (CleanFiles && Uninit)
            TECHILA.unload(true);
        end
        return
    end
    
    %% Wait for project completion
    % Wait until the project is completed (the completion level is
    % printed out to the console). If the results are streamed, do not
    % wait, but start the background thread.
    if LocalMode
    elseif ~isempty(ResultFile)
    elseif StreamResults
        TECHILA_RESULTS.setStreamResults(handle, true);
        if (AllowPartial)
            TECHILA_RESULTS.setAllowPartial(handle, true);
        end
        checkStatusCode(TECHILA_PROJECTS.waitCompletionBG(handle));
    else
        waitCompletion(handle, varargin{firstVarargin:end});
        if Messages
            fprintf('\nProject completed.\n');
        end
    end
    
    if Messages
        if StreamResults
            fprintf('Streaming results...\n');
        elseif ~isempty(ResultFile)
            fprintf('Using resultfile: %s...\n', ResultFile);
        else
            fprintf('Downloading results...\n');
        end
    end
    
    %% Download and extract the results if the results are not streamed.
    downloadtime=tic;
    if ~StreamResults && ~LocalMode && isempty(ResultFile)
        if (~checkResultsRequired(handle, ResultsRequired))
            error('Unable to download required amount of results.');
        end
        checkStatusCode(TECHILA_RESULTS.downloadResult(handle, AllowPartial, StreamResults));
        if Messages
            gridhandle = TECHILA.getHandle(handle);
            resultsize = gridhandle.getDownloaded();
            if resultsize > 0
                fprintf('Result size %1.3fMB.\n', resultsize/1048576);
            end
            fprintf('Results downloaded.');
            if resultsize > 0
                fprintf('(%1.3fMB/s)\n', resultsize/1048576/toc(downloadtime));
            else
                fprintf('\n');
            end
            fprintf('\nExtracting results...\n');
        end
        extracttime=tic;
        checkStatusCode(TECHILA_RESULTS.unzip(handle));
        if Messages
            fprintf('Results extracted.\n');
        end
    elseif ~isempty(ResultFile)
        [ignore, ignore, ignore] = mkdir(tmpdir, 'unzipdir');
        resultfiles = unzip(ResultFile, [tmpdir '/unzipdir']);
        resultfiles = resultfiles(:);
    end
    
    %% Handle results
    % Read the result files and assign each of the results to
    % the vector element of its own.
    if (ReturnResults || ReturnResultFiles)
        result = {};
        % If the results are streamed, loop until all the results are
        % arrived.
        if LocalMode || StreamResults || ~isempty(ResultFile)
            jobid=1;
            WaitStarted = tic();
            running = 1;
            while  (running == 1)
                if ~isempty(ResultFile)
                    running = 0;
                end
                if LocalMode
                    if ~isempty(JobInputFiles)
                        jif=JobInputFiles{jobid};
                        for jifid=1:length(JobInputFileNames)
                            copyfile(jif{jifid}, ['techila_exec/' JobInputFileNames{jifid}]);
                        end
                    end
                    cd('techila_exec');
                    cmd = ['peachclient ' num2str(jobid)]; 
                    [cmdstatus, cmderrormsg] = system(cmd);
                    cd('..');
                    if cmdstatus~=0
                        error(['Error executing command: ' cmderrormsg]);
                    end
                    resultfiles={'techila_exec/result.mat'};
                    jobid=jobid+1;
                    if jobid > jobs
                        running = 0;
                    end
                elseif isempty(ResultFile)
                    TECHILA_PROJECTS.actionWait(1000);
                    if (TECHILA_PROJECTS.isCompleted(handle))
                        running = 0;
                    end
                    resultfiles = TECHILA_RESULTS.getNewStreamedResultFiles(handle);
                end
                for p=1:size(resultfiles,1)
                    % If Callback Method is used, call the method with the
                    % results and return callback method's result.
                    if ~isempty(CallbackMethod)
                        if (nargout > 1)
                            cbres = execCallbackCommand(CallbackMethod, CallbackParams, resultfiles(p));
                            if (length(cbres) < nargout)
                                error('Error in peach. Callback method contains less output arguments than expected.');
                            end
                            result=[result cbres{1}];
                            for k=2:nargout
                                va=varargout(k-1);
                                va{1}=[va{1} cbres{k}];
                                varargout(k-1)=va;
                            end
                        else
                            result=[result execCallbackCommand(CallbackMethod, CallbackParams, resultfiles(p))];
                        end
                    else
                        if islogical(ImportData)
                            if ImportData==false
                                clientres=load('-mat', char(resultfiles(p)));
                            else
                                clientres.result=importdata(char(resultfiles(p)));
                            end
                        else
                            clientres.result=importdata(char(resultfiles(p)), ImportData{:});
                        end
                        if (nargout > 1)
                            if (length(clientres.result) < nargout)
                                error('Error in peach. Result contains less output arguments than expected.');
                            end
                            result=[result clientres.result{1}];
                            for k=2:nargout
                                va=varargout(k-1);
                                va{1}=[va{1} clientres.result{k}];
                                varargout(k-1)=va;
                            end
                        else
                            result=[result clientres.result];
                        end
                    end
                end
                if isempty(ResultFile) && TimeLimit > 0 && checkResultsRequired(handle, ResultsRequired) && toc(WaitStarted) >= TimeLimit
                    TECHILA_PROJECTS.stopProject(handle);
                    running = 0;
                end
            end
            if Messages
                fprintf('\nProject completed and results streamed.\n');
            end
            if ReturnResultFiles
                result = {};
                if isempty(ResultFile)
                    resultfiles = TECHILA_RESULTS.getResultFiles(handle);
                end
                for i=1:length(resultfiles), result{i,1}=char(resultfiles(i));end
            end
            % If the results are not streamed, they should be all completed
            % before this.
        else
            if isempty(ResultFile)
                resultfiles = TECHILA_RESULTS.getResultFiles(handle);
            end
            if ReturnResultFiles
                for i=1:length(resultfiles), result{i,1}=char(resultfiles(i));end
            else
                loadtime=tic;
                result=cell(size(resultfiles,1),1);
                for k=2:nargout
                    varargout(k-1)={cell(size(resultfiles,1),1)};
                end
                for p=1:size(resultfiles,1)
                    if ~isempty(CallbackMethod)
                        if (nargout > 1)
                            cbres = execCallbackCommand(CallbackMethod, CallbackParams, resultfiles(p));
                            if (length(cbres) < nargout)
                                error('Error in peach. Callback method contains less output arguments than expected.');
                            end
                            result{p}=cbres{1};
                            for k=2:nargout
                                va=varargout(k-1);
                                va{1}{p}=cbres{k};
                                varargout(k-1)=va;
                            end
                        else
                            result{p}=execCallbackCommand(CallbackMethod, CallbackParams, resultfiles(p));
                        end
                    else
                        if islogical(ImportData)
                            if ImportData==false
                                clientres=load('-mat', char(resultfiles(p)));
                            else
                                clientres.result=importdata(char(resultfiles(p)));
                            end
                        else
                            clientres.result=importdata(char(resultfiles(p)), ImportData{:});
                        end
                        if (nargout > 1)
                            if (length(clientres.result) < nargout)
                                error('Error in peach. Result contains less output arguments than expected.');
                            end
                            result{p}=clientres.result{1};
                            for k=2:nargout
                                va=varargout(k-1);
                                va{1}{p}=clientres.result{k};
                                varargout(k-1)=va;
                            end
                        else
                            result{p}=clientres.result;
                        end
                    end
                end
                % Support result dimension change only in nonseparated sessions when all the results are received.
                if isempty(ResultFile)
                    ready = TECHILA_PROJECTS.ready(handle);
                else
                    ready = 100;
                end
                if exist('pvdim', 'var') && ready == 100
                    result=reshape(result, pvdim);
                    for k=2:nargout
                        va=varargout(k-1);
                        varargout(k-1)={reshape(va{1}, pvdim)};
                    end
                end
                if Messages
                    fprintf('Results imported.\n');
                end
            end
        end
    else
        result = handle;
    end

    %% Cleanup phase 1
    %Removes the temporary files etc. created by the Techila interface.
    if (CleanFiles)
        cleantime = tic();
        if ~LocalMode
            if isempty(ResultFile)
                TECHILA.cleanup(handle, CLEANUP_MODE_ALL);
            elseif ~isempty(resultfiles)
                delete(resultfiles{:});
            end
        end
        if Messages
            fprintf('Temporary files cleaned.\n');
        end
    end

    % Remove the project from Techila server.
    if RemoveProject && isempty(ResultFile)
        removetime = tic();
        if ~LocalMode
        TECHILA_PROJECTS.removeProject(handle);
        end
        if Messages
            fprintf('Project removed.\n');
        end
    end
    
    %% Handle statistics
    % If the peach has not been running from project's start to its end, do
    % not try to benchmark the total time
    if OldHandle == -1 && (ReturnResults || ReturnResultFiles)
        peach_totaltime = toc(total);
    end
    % nor cputime, realtime and statistics
    if ~LocalMode && isempty(ResultFile) && (ReturnResults || ReturnResultFiles)
        peach_cputime = TECHILA_PROJECTS.getUsedCpuTime(handle);
        peach_realtime = TECHILA_PROJECTS.getUsedTime(handle);
        if Statistics
            peach_stats = TECHILA_PROJECTS.getProjectStatistics(handle);
        end
    end
    % nor print the statistics.
    if ~LocalMode && isempty(ResultFile) && (Statistics && Messages && (ReturnResults || ReturnResultFiles))
        printStatistics(handle, varargin{firstVarargin:end});
    end

    %% Cleanup phase 2
    if CloseHandle
        TECHILA.close(handle); %Closes the project handle.
    end

    %Catches any possible exceptions caused by any error during the
    %execution and prints out the error message to console using toolbox
    %function printError().
catch
    %% Error handling
    printError(lasterror);
    %Unloads the Techila interface and removes the temp. directories.
    if Uninit && ~isempty(TECHILA)
        TECHILA.unload(CleanFiles);
        TECHILA=[];
    end
    rethrow(lasterror);
end
%% Cleanup phase 3
%Unloads the Techila interface and removes the temp. directories.
if Uninit && ~isempty(TECHILA)
    TECHILA.unload(CleanFiles);
    TECHILA=[];
end
end

function crcsum = getBundleParametersCRC(bp)
crc = java.util.zip.CRC32;
for i = 1:length(bp)
    crc.update(java.lang.String(bp{i}{1}).getBytes);
    crc.update(java.lang.String(bp{i}{2}).getBytes);
end
crcsum = crc.getValue;
end
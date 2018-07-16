# Copyright 2012-2017 Techila Technologies Ltd.
"""Techila Python module

The Techila module is used to command the Techila system.

"""

import base64
import ctypes
import cPickle
import imp
import inspect
import marshal
import math
import os
import pkgutil
import platform
import random
import sys
import time
import types
import warnings
import zipimport

class Techila:
    """Class to store internal state"""
    _libloaded = False
    _initialized = False
    _lib = None

class TechilaException(Exception):
    """Techila Exception

    Attributes:
        msg - Error message
        statuscode - Techila specific statuscode
    """

    def __init__(self, msg, statuscode, msg2 = None, msg3 = None):
        self.msg = msg
        self.statuscode = statuscode
        self.msg2 = msg2
        self.msg3 = msg3

    def __str__(self):
        #return(self.msg + '(' + str(self.statuscode) + ')' + self.msg2)
        s = self.msg

        desc = describeStatusCode(self.statuscode)
        if desc is None:
            desc = ''

        s = s + ': ' + desc + ' (' + str(self.statuscode) + ')'

        if self.msg3 is not None:
            s += ' (' + self.msg3 + ')'

        return s

class ResultIter(object):
    def __init__(self,
                 lib,
                 ph,
                 tmpdir,
                 peachclient,
                 useoutputfiles,
                 callback,
                 filehandler,
                 intermediate_callback,
                 douninit = True,
                 iter_mode = False,
                 resumefn = None):
        #print ' @init'
        self.lib = lib
        self.ph = ph
        self.tmpdir = tmpdir
        self.peachclient = peachclient
        self.useoutputfiles = useoutputfiles

        self.callback = callback
        self.filehandler = filehandler

        self.intermediate_callback = intermediate_callback
        self.imcallbackset = False

        self.douninit = douninit

        self.iter_mode = iter_mode
        self.return_idx = not iter_mode

        self.results = []
        self.rpos = 1
        self.stepindex = 0

        self.resumefn = resumefn

        self.postCount = 0

        self.handle = lib.techila_peach_getProjectHandle(ph)

    def __iter__(self):
        #print ' @iter'
        return self


    def next(self):
        #print ' @next'

        ph = self.ph
        lib = self.lib
        tmpdir = self.tmpdir

        if self.intermediate_callback is not None and not self.imcallbackset:
            #print 'setting intermediate callback'

            kwargs = {}
            argspec = inspect.getargspec(self.intermediate_callback)

            if 'handle' in argspec.args:
                kwargs['handle'] = self.handle

            addjobid = False
            addjobidx = False
            addpid = False
            if 'jobid' in argspec.args:
                addjobid = True
            if 'jobidx' in argspec.args:
                addjobidx = True
            if 'pid' in argspec.args:
                addpid = True

            def imcbfun(filename):
                #print 'python im callback:', filename

                try:
                    f = open(filename, 'rb')
                    unpickler = cPickle.Unpickler(f)
                    jobid = unpickler.load()
                    imdata = unpickler.load()
                    f.close()

                    if self.intermediate_callback is not None:
                        if addjobid:
                            kwargs['jobid'] = jobid
                        if addpid:
                            pid = int(jobid >> 32)
                            kwargs['pid'] = pid
                        if addjobidx:
                            jobidx = int(jobid & 0xFFFF)
                            kwargs['jobidx'] = jobidx

                        self.intermediate_callback(imdata, **kwargs)
                except Exception as e:
                    print e


            CALLBACK = ctypes.CFUNCTYPE(None, ctypes.c_char_p)
            # store the callback into self so it won't be
            # garbage collected too early
            self._imcbfunc = CALLBACK(imcbfun)

            lib.techila_peach_setIntermediateResultHandler(ph, self._imcbfunc)
            self.imcallbackset = True

        if self.results is not None and self.stepindex < len(self.results):
            # when steps > 1 return each peachclient result from cache list
            #print ' @next returning from cache'
            rv = self.results[self.stepindex]
            self.stepindex += 1
            return rv
        else:
            self.stepindex = 0
            self.results = None

        filename = ctypes.create_string_buffer('\000', size=255)
        length = ctypes.c_int(255)
        pnfrv = lib.techila_peach_nextFile(ph, filename, ctypes.byref(length))

        if pnfrv != 0:
            raise StopIteration()

        if length.value == 0:
            # no more results
            if self.iter_mode:
                _peach_end(lib, ph, self.douninit)

            if self.resumefn is not None and os.path.exists(self.resumefn):
                os.remove(self.resumefn)

            raise StopIteration()

        iszip = False
        filelist = [filename.value]
        unzipdir = None

        # AAA
        tmpdir = self.tmpdir
        self.results = []
        rnd = random.randint(0, 2 ** 31 - 1)

        if self.useoutputfiles:
            unzipdir = tmpdir + '/python_tmp_' + str(rnd) + '_' + str(self.rpos)

            import zipfile
            zf = zipfile.ZipFile(filename.value)
            zf.extractall(unzipdir)
            filelist0 = zf.namelist()

            filelist = []
            for f in filelist0:
                filelist.append(unzipdir + '/' + f)

            iszip = True

        for ufile in filelist:
            if self.peachclient and (not iszip or ufile.endswith('techila_peach_result')):
                file = open(ufile, 'rb')
                data = cPickle.Unpickler(file)
                pcresults = data.load()
                file.close()

                for pcresult in pcresults:
                    idx = pcresult['idx']
                    result = pcresult['result']

                    if self.callback:
                        result = self.callback(result)

                    #results[idx] = result
                    self.results.append(self._ra(idx, result))

            else:
                if self.filehandler is not None:
                    fhres = self.filehandler(ufile)

                    if not self.peachclient:
                        if self.callback:
                            fhres = self.callback(fhres)
                        self.results.append(self._ra(None, fhres))

            self.postCount += 1
            Techila._lib.techila_peach_postProcessed(ph, self.postCount)

            if iszip and os.path.exists(ufile):
                os.remove(ufile)

        if iszip and os.path.exists(unzipdir):
            os.rmdir(unzipdir)

        self.rpos = self.rpos + 1

        # BBB
        #print 'end next'
        self.stepindex = 0
        rv = self.results[self.stepindex]
        self.stepindex += 1
        return rv

    def _ra(self, idx, result):
        """Append results"""
        if self.return_idx:
            return (idx, result)
        else:
            return result

    def set_return_idx(self, return_idx):
        """When set to true the next function will return the """
        self.return_idx = return_idx



def describeStatusCode(code):
    estr = None
    if Techila._libloaded:
        errorstr = ctypes.create_string_buffer('\000', size=255)
        length = ctypes.c_int(255)
        Techila._lib.techila_describeStatusCode(code, errorstr, ctypes.byref(length))

        estr = errorstr.value

    return estr


def init(sdkroot = None,
         initfile = None,
         password = None):
    """Initialize connection to the Techila server.

    Arguments:
    sdkroot -- The path to Techila SDK root directory
    initfile -- the settings file used for initializing Techila SDK
    password -- the password
    """

    #print 'init called'

    if not sdkroot:
        envroot = os.environ.get('TECHILA_SDKROOT')

        if envroot is not None:
            sdkroot = envroot
        else:
            try:
                import sdkroot_config
                sdkroot = sdkroot_config.sdkroot
            except ImportError:
                raise TechilaException('Unable to get sdkroot', -1)

    if not Techila._libloaded:
        #print 'Loading Techila library'
        if platform.system()=='Windows':
            if platform.architecture()[0] == '32bit':
                libname = 'Techila32.dll'
            else:
                libname = 'Techila64.dll'
        elif platform.system()=='Darwin':
            libname = 'libTechila.dylib'
        else:
            if platform.architecture()[0] == '32bit':
                libname = 'libTechila32.so'
            else:
                libname = 'libTechila64.so'

        libname = sdkroot + '/lib/' + libname

        #print libname
        Techila._lib = ctypes.cdll.LoadLibrary(libname)
        #print Techila._lib

        Techila._libloaded = True

    if not Techila._initialized:
        sc = Techila._lib.techila_initFile(initfile)
        if sc != 0:
            raise TechilaException('init failed', sc)

        Techila._initialized = True


def uninit(remove_temp_dir = True, recursive = True):
    """Uninitialize the connection and cleanup temporary files.

    Arguments:
    remove_temp_dir -- True is temporary directory should be removes
    recursive -- True is temporary directory should be cleaned recursively

    """

    if Techila._initialized:
        Techila._lib.techila_unload2(remove_temp_dir, recursive)
        Techila._initialized = False

def getProjectId(handle):
    """Get project ID associated with the handle."""

    pid = -1
    if Techila._initialized:
        pid = Techila._lib.techila_getProjectId(handle)

    return pid

def getTempDir():
    """Get the session specific temporary directory."""

    tdir = None
    if Techila._initialized:
        dir0 = ctypes.create_string_buffer('\000', size=255)
        length = ctypes.c_int(255)
        Techila._lib.techila_getTempDir(dir0, ctypes.byref(length))

        if length.value > 0:
            tdir = dir0.value


    return tdir

def waitCompletion(handle):
    """Wait for project completion."""

    if Techila._initialized:
        Techila._lib.techila_waitCompletion(handle)

def downloadResult(handle):
    """Download result."""

    if Techila._initialized:
        return Techila._lib.techila_downloadResult(handle)

def unzip(handle):
    """Unzip downloaded results"""

    if Techila._initialized:
        return Techila._lib.techila_unzip(handle)

def cleanup(handle, mode):
    """Cleanup a handle."""

    if Techila._initialized:
        Techila._lib.techila_cleanup(handle, mode)

def close(handle):
    """Close a handle."""

    if Techila._initialized:
        Techila._lib.techila_close(handle)

def getUsedCpuTime(handle):
    """Get used CPU time from a project."""

    if Techila._initialized:
        return Techila._lib.techila_getUsedCpuTime(handle)

def getUsedTime(handle):
    """Get used time (wall clock) from a project."""

    if Techila._initialized:
        return Techila._lib.techila_getUsedTime(handle)



def peach(funcname = None,
          params = None,
          files = None,
          xfiles = None,
          peachvector = None,
          jobs = None,
          description = None,
          datafiles = None,
          messages = True,
          stream = False,
          priority = 'Normal',
          callback = None,
          filehandler = None,
          donotwait = False,
          donotuninit = False,
          removeproject = False,
          close = True,
          project_parameters = None,
          bundle_parameters = None,
          binary_bundle_parameters = None,
          imports = None,
          packages = None,
          databundles = None,
          jobinputfiles = None,
          outputfiles = None,
          snapshot = False,
          snapshotfiles = 'snapshot.dat',
          snapshotinterval = 15,
          python_version = None,
          python_required = True,
          executable = False,
          realexecutable = None,
          exeparams = None,
          binaries = None,
          run_as_python = False,
          projectid = None,
          steps = 1,
          sdkroot = None,
          initfile = None,
          password = None,
          allowpartial = False,
          resultfile = None,
          extra_params = None,
          return_iterable = False,
          intermediate_callback = None,
          resume = False,
          split_peachvector = False,
          funclist = None,
          ):
    """Execute Python computations in Techila system.

    Arguments:

    funcname -- The function that will be executed on Workers. Can
    refer to a function handle or to a function that is defined in a
    Python file that is listed in the 'files' parameter. Example 1:
    funcname=workerFunc. Defines that the function is a function
    handle. Example 2: funcname='workerFunc'. Defines that the
    function is defined in one of the Python files that will be
    sourced with 'files'

    params -- Input arguments to the function that is executed on
    Workers. Example: params = [a=10,b=100]. Defines two input
    arguments to the executable function.

    files -- List of Python scripts that will be transferred and
    sourced on Workers. Example: files = ['examplescript.py']. Sources
    the 'examplescript.py' file before doing any function calls.

    peachvector -- peachvector elements, length defines the number of
    jobs. Example: peachvector = range(1, 10 + 1). Creates a Project
    consisting of 10 jobs. Steps parameter will affect the actual
    amount of jobs created.

    jobs -- Alternative to peachvector, define the number of jobs to
    be created. Steps parameter will affect the actual amount of jobs
    created.

    description -- Description of the project.

    datafiles -- List of additional data files that will be
    transferred to the Workers. Example: datafiles = ['datafile1.txt',
    'datafile2.txt']. Transfers files called 'datafile1.txt' and
    'datafile2.txt' from the current working directory to all
    partipating Workers.

    messages -- Determines if messages will be displayed regarding
    Project statistics and other Project related information. To disable
    messages, use: messages = False

    stream -- Enables Job results to be streamed immediately after
    they have been transferred to the Techila Server. To enable
    streaming, use: stream = True

    priority -- Determines the priority of the Project. Adjusting the
    priority value can be used to manage the order in which
    computational Projects created by you are processed. Projects with
    priority = 1 receive the most resources and Projects with priority
    = 7 the least amount of resources.

    callback -- Calls given function for each result and returns
    callback function's result as the peach result as peach result.
    Example: callback = 'callbackfun'

    filehandler -- Calls given file handler function for each
    additional result file returned from Workers. See parameter
    'outputfiles' for defining additional result files

    donotwait -- Defines that peach will return immediately after the
    Project has been created. If no other parameters are specified, peach
    will return the Project ID number. To make peach return immediately,
    use: donotwait = True

    donotuninit -- Does not uninitialize the Techila environment. To
    prevent uninitialization, use: donotuninit = True

    removeproject -- Determines if Project related data will be
    removed from the Techila Server after the Project is completed. To
    remove project, use: removeproject = True

    close -- Closes the handle. To prevent the handle from closing,
    use: close = False

    project_parameters -- Defines additional Project parameters.
    Example: project_parameters = {'techila_client_memorymin' :
    '1073741824', 'techila_worker_os' : 'Windows'} Defines that only
    Workers with a Windows operating system and 1 GB of free memory can be
    assigned Jobs.

    bundle_parameters -- Defines parameters for the Parameter Bundle.
    Example: bundle_parameters = {'ExpirationPeriod' : '2 h'}. Defines
    that the Parameter Bundle should be stored for 2 hours on Workers.

    binary_bundle_parameters -- Defines parameters for the Executor
    Bundle. Example: binary_bundle_parameters = {'ExpirationPeriod' :
    '2 h'}. Defines that the Executor Bundle should be stored for 2
    hours on Workers.

    imports -- Determines additional Bundles that will be imported in
    the Project. Example: imports =
    ['example.bundle.v1', 'example.bundle2.v1']. Defines that, Bundles
    exporting 'example.bundle.v1' and 'example.bundle.v2' will be
    transferred to each Worker participating in the Project.

    packages -- Determines additional Python packages to be included
    in the Project. This will automatically call bundleit for the
    specified packages and add the created bundles to the import list.

    databundles -- Used to create Data Bundles. Listed files will be
    included in the Data Bundle(s). Example: databundles =
    {'datafiles' : ['file1', 'file2']}. Defines that files 'file1' and
    'file2' will be placed in the Bundle

    jobinputfiles -- Assigns Job-Specific input files that will be
    transferred with each computational Job. Example: jobinputfiles =
    {'datafiles' : ['file1_job1', 'file1_job2'], 'filenames' :
    ['workername']}. Transfers 'file1_job1' to Job #1 and 'file1_job2'
    to Job #2. Both files will be renamed to 'workername' on Workers

    outputfiles -- Speficies additional output files that will be
    transferred to the End-User's computer from Workers. Example:
    outputfiles = ['file1', 'file2']. Defines that files named 'file1'
    and 'file2' will be returned from Workers. See 'filehandler' for
    post-processing these result files.

    snapshot -- Enables snapshotting in the Project with the default
    snapshot file name and snapshot transfer interval. To enable
    snapshotting, use: snapshot=True

    snapshotfiles -- Specifies the name of the snapshot file. If
    specified, this value overrides the default value. Example:
    snapshotfiles = 'test.txt'. Defines that 'test.txt' will be used as
    the snapshot file, which will be transferred to the Techila Server.

    snapshotinterval -- Specifies a snapshot transfer interval in
    minutes. If specified, this value overrides the default snapshot
    transfer interval. Example: snapshotinterval = 30. Defines that
    the minimum interval for transfer is 30 minutes.

    python_version -- Specifies which Python Runtime Bundle is used to
    execute the computational Jobs. If the python_version parameter is
    not specified, the version of the Python environment used to
    create the Project will be used. Example: python_version = '272'.
    Defines that the Runtime Bundle built from Python 2.7.2 will be
    used.

    python_required -- Is python Runtime bundle required on the
    Workers.

    executable -- Set this to True when using binaries.

    realexecutable -- Set the Executable parameter in the binary
    bundle. May be a feature reference %A(feature), hard coded path on
    the Worker '/bin/ls'.

    exeparams -- Parameters to be passed to the executable defined
    above.

    binaries -- Run precompiled binaries, see also executable. Use
    binaries = [{'file': 'test.sh', 'osname': 'Linux'}, {'file':
    'test.bat', 'osname': 'Windows'}] or binaries = [{'file':
    'test32', 'osname': 'Linux', 'processor' : 'i386'}, {'file':
    'test64', 'osname': 'Linux', 'processor' : 'amd64'}, {'file':
    'test32.exe', 'osname': 'Windows', 'processor' : 'x86'}, {'file':
    'test64.exe', 'osname': 'Windows', 'processor' : 'amd64'}]

    run_as_python -- Experimental feature. Enables Python computations
    to be performed by using the Python software installed on Workers.
    Enables Python computations to be performed without Python Runtime
    Bundles. Requires a that Techila Administrators have configured
    the system. To use this feature, use: run_as_python = True

    projectid -- Defines the Project ID number of the Project to which
    the peach function call should be linked to. Can be used to download
    results of previously started Projects. Example: projectid = 1234.
    Defines the peach function call is linked to a Project with Project ID
    1234.

    steps -- The number of iteration steps to be run per job.

    sdkroot -- Determines the path of the SDK directory. Example:
    sdkroot = 'C:/techila'

    initfile -- Specifies the path of the Techila config file
    (techila_settings.ini)

    password -- Keystore password.

    allowpartial -- Allow partial results to be downloaded even if the
    project fails.

    resultfile -- Read a previously downloaded project result file as
    input and process it appropriately, no new project is created.

    extra_params -- Extra parameters for peachclient itself. Use
    <extraparams> in params list to get a list of the parameters to
    the function being used.

    return_iterable -- Return results as a iterable object which can
    be iterated. When this is used the results are loaded one by one
    when processing them in a loop thus concerving memory when
    individual results are huge.

    split_peachvector -- Split peachvector elements into individual
    job input files. Regular job input files cannot be used at the
    same time.

    funclist -- List of additional function handles to be included in
    the project. Example funclist = [fun1, fun2]

    """

    if type(funcname).__name__ == 'function':
        resumefn = 'func_' + funcname.func_name
    elif type(funcname).__name__ == 'builtin_function_or_method':
        resumefn = 'builtin_' + funcname.__name__
    else:
        resumefn = str(funcname) + '_resume.dat'
    if resume and os.path.exists(resumefn):
        print 'resuming from file: ' + resumefn
        resumefile = open(resumefn, 'rb')
        resumedata = cPickle.Unpickler(resumefile)
        resumepid = resumedata.load()
        resumefile.close()

        projectid = resumepid

    peachclient = True
    if executable:
        if exeparams is not None:
            if exeparams.find('<peachclientparams>') >= 0:
                peachclient = True
            else:
                peachclient = False
        else:
            exeparams = params
            peachclient = False
    else:
        exeparams = '<peachclientparams>'

    envver = os.environ.get('TECHILA_PYTHON_VERSION')
    if python_version is None and envver is not None:
        python_version = envver

    mode = 'file'
    if type(funcname).__name__ == 'function' :
        mode = 'function'
        function = funcname
        funcname = funcname.func_name
    elif type(funcname).__name__ == 'builtin_function_or_method':
        mode = 'builtin'
        function = funcname
        funcname = function.__name__


    if not peachclient and steps > 1:
        warnings.warn('Setting steps to 1 because peachclient is not used.')
        steps = 1

    if donotwait:
        removeproject = False

    if not funcname and projectid < 1 and not resultfile:
        raise TechilaException('funcname, projectid or resultfile must be defined', -1)

    if type(steps) is not int or steps < 1:
        raise TechilaException('Steps must integer and at least 1', -1)

    if donotwait and return_iterable:
        raise TechilaException('donotwait and return_iterable must not both be True', -1)

    # init
    douninit = False

    if not Techila._initialized:
        douninit = True
        init(sdkroot, initfile, password)

    if donotuninit:
        douninit = False

    if projectid == None:
        if peachvector is not None:
            if isinstance(peachvector, types.GeneratorType):
                peachvector = list(peachvector)
            maxidx = len(peachvector)
        else:
            maxidx = jobs

    # Open a new peach handle
    lib = Techila._lib
    ph = lib.techila_peach_handle()

    lib.techila_peach_setName(ph, funcname)
    lib.techila_peach_setMessages(ph, messages)

    if type(priority) is int:
        lib.techila_peach_setPriorityI(ph, priority)
    else:
        lib.techila_peach_setPriority(ph, priority)

    lib.techila_peach_setAllowPartial(ph, allowpartial)
    lib.techila_peach_setStream(ph, stream)
    lib.techila_peach_setRemove(ph, removeproject)
    lib.techila_peach_setClose(ph, close)

    outputfilecount = 0
    if peachclient:
        outputfilecount = 1

    if outputfiles:
        if type(outputfiles) is str:
            outputfiles = [outputfiles]
        outputfilecount += len(outputfiles)

    executesc = 0
    if projectid is not None and projectid > 0:
        lib.techila_peach_setProjectId(ph, projectid)
    elif resultfile is not None:
        lib.techila_peach_setResultFile(ph, resultfile)
    else:
        # execute

        jifdatadir = None
        pvjifmode = False
        if peachvector is not None and jobinputfiles is None and split_peachvector:
            jifrnd = random.randint(0, 2 ** 31 - 1)
            jifdatadir = 'techila_splitpv_' + str(jifrnd)
            os.mkdir(jifdatadir)

            jifi = 0
            jiffns = []

            for pvelem in peachvector:
                jifi += 1
                jiffn = 'input_' + str(jifi)
                f = open(jifdatadir + '/' + jiffn, 'wb')
                p = cPickle.Pickler(f, 1)
                p.dump(pvelem)
                f.close()

                jiffns.append(jiffn)

            jobinputfiles = {
                'datafiles' : jiffns,
                'filenames' : ['pvjifdata'],
                'datadir' : jifdatadir,
            }
            jobs = len(peachvector)
            peachvector = None
            pvjifmode = True

        # bundleit
        if packages:
            for pkg in packages:
                #print 'bundling package:', pkg

                if type(pkg) == str:
                    bn = bundleit(pkg)
                elif type(pkg) == dict:
                    bn = bundleit(**pkg)
                elif type(pkg) == tuple:
                    bn = bundleit(*pkg)

                if imports == None:
                    imports = []

                imports.append(bn)

        # Executor

        if python_required:

            envadd = '' # hax

            if run_as_python:
                if peachclient:
                    lib.techila_peach_setExecutable(ph, '%A(python)')
                lib.techila_peach_putProjectParam(ph, 'techila_worker_features', '(python=*)')
            else:

                # Set peach parameters
                if peachclient:
                    lib.techila_peach_setExecutable(ph, '%L(python)')

                if python_version == None:
                    ver = sys.version_info
                    python_version = str(ver[0])+str(ver[1])+str(ver[2])

                import_name = 'fi.techila.grid.cust.common.library.python.r' + python_version + '.client'
                lib.techila_peach_addExeImport(ph, import_name)
                lib.techila_peach_putExeExtras(ph, 'ExternalResources', 'python;resource=python;file=python.exe;osname=Windows,python;resource=python;file=python;osname=Linux,python;resource=python;file=python;osname=Mac OS X,pythondir;resource=python')
                envadd = '%C(path.separator,PROPGET)%L(pythondir)%C(file.separator,PROPGET)Lib%C(path.separator,PROPGET)%L(pythondir)%C(file.separator,PROPGET)Lib%C(file.separator,PROPGET)site-packages%C(path.separator,PROPGET)%L(pythondir)%C(file.separator,PROPGET)Modules'

            envstr = 'LD_LIBRARY_PATH;value=\"%P(tmpdir)/Lib' + envadd + '\";osname=Linux;appendDefault=true,DYLD_LIBRARY_PATH;value=%P(tmpdir)/Lib;osname=Mac OS X,PYTHONPATH;value=\"%C(python_path,PGET,path.separator,PROPGET,|)%P(tmpdir)%C(file.separator,PROPGET)Lib%C(file.separator,PROPGET)site-packages' + envadd + '\";appendDefault=true'

            lib.techila_peach_putExeExtras(ph, 'Environment', envstr)

        if realexecutable:
            lib.techila_peach_setExecutable(ph, realexecutable)


        if imports:
            for import_name in imports:
                lib.techila_peach_addExeImport(ph, import_name)

        if outputfiles:
            for of in outputfiles:
                lib.techila_peach_addOutputFile(ph, of)

        if binaries:
            for bin in binaries:
                binres = bin.get('res')
                binfile = bin.get('file')
                binos = bin.get('osname')
                binprocessor = bin.get('processor')

                if not binres:
                    binres = 'exe'

                lib.techila_peach_addExeFile(ph, binres, binfile, binos, binprocessor)


        if files:
            if type(files) is str:
                files = [files]
            for filename in files:
                lib.techila_peach_addExeFile(ph, os.path.basename(filename), filename, None, None)

        if xfiles:
            if type(xfiles) is str:
                xfiles = [xfiles]
            for filename in xfiles:
                lib.techila_peach_addExeFile(ph, os.path.basename(filename), filename, None, None)

        if peachclient:

            peachclientfile = imp.find_module('techila')[1] + '/peachclient.py'

            lib.techila_peach_addExeFile(ph, 'peachclient.py', peachclientfile, None, None)

            pcparams = '%I(peachclient.py) %P(jobidx) %O(peachoutput)'

            exeparams = exeparams.replace('<peachclientparams>', pcparams)

            if extra_params is not None:
                exeparams = exeparams + ' ' + extra_params

            lib.techila_peach_addOutputFile(ph, 'peachoutput;file=techila_peach_result')

        if exeparams is not None:
            lib.techila_peach_putExeExtras(ph, 'Parameters', exeparams)


        if snapshot:
            lib.techila_peach_putExeExtras(ph, 'SnapshotFiles', snapshotfiles)
            lib.techila_peach_putExeExtras(ph, 'SnapshotInterval', str(snapshotinterval))


        if binary_bundle_parameters:
            if type(binary_bundle_parameters) is not dict:
                raise TechilaException('binary_bundle_parameters must be defined as dictionaries, eg. {''key1'': ''value1'', ''key2'': ''value2''}', -1)

            for name in binary_bundle_parameters.keys():
                lib.techila_peach_putExeExtras(ph, name, str(binary_bundle_parameters.get(name)))


        # databundles

        if databundles:
            for databundle in databundles:
                if type(databundle) is not dict:
                    raise TechilaException('Databundles must be defined as dictionaries', -1)

                dbdatadir = '.'
                if databundle.get('datadir'):
                    dbdatadir = databundle.get('datadir')

                lib.techila_peach_newDataBundle(ph)

                dbdatafiles = databundle.get('datafiles')
                for dbdatafile in dbdatafiles:
                    lib.techila_peach_addDataFileWithDir(ph, dbdatadir, dbdatafile)

                dbparams = databundle.get('parameters')
                if dbparams:
                    if type(dbparams) is not dict:
                        raise TechilaException('Databundle Parameters must be defined as dictionaries, eg. {''key1'': ''value1'', ''key2'': ''value2''}', -1)

                    for name in dbparams.keys():
                        lib.techila_peach_putDataExtras(ph, name, str(dbparams.get(name)))

                dblibs = databundle.get('libraryfiles')
                if dblibs:
                    lib.techila_peach_setDataCopy(ph, False)

        # job input bundle

        if jobinputfiles:
            if type(jobinputfiles) is not dict:
                raise TechilaException('Jobinputfiles must be defined as dictionary', -1)

            jidatadir = '.'
            if jobinputfiles.get('datadir'):
                jidatadir = jobinputfiles.get('datadir')

            jidatafiles = jobinputfiles.get('datafiles')
            for jidatafile in jidatafiles:
                if type(jidatafile) is str:
                    jidatafile = [jidatafile]

                jilen = len(jidatafile)
                cjidf = ctypes.c_char_p * jilen
                jidf = cjidf(*jidatafile)

                lib.techila_peach_addJobFileWithDir3(ph, jidatadir, jilen, jidf)


            jifilenames = jobinputfiles.get('filenames')
            if jifilenames:
                if type(jifilenames) is str:
                    jifilenames = [jifilenames]

                jifnlen = len(jifilenames)
                cjifn = ctypes.c_char_p * jifnlen
                jifn = cjifn(*jifilenames)

                lib.techila_peach_setJobFileNames3(ph, jifnlen, jifn)


            jiparams = jobinputfiles.get('parameters')
            if jiparams:
                if type(jiparams) is not dict:
                    raise TechilaException('Jobinputfile Parameters must be defined as dictionaries, eg. {''key1'': ''value1'', ''key2'': ''value2''}', -1)

                for name in jiparams.keys():
                    lib.techila_peach_putJobExtras(ph, name, str(jiparams.get(name)))


        # parameter bundle

        # datafiles into parameter bundle
        if datafiles:
            if type(datafiles) is str:
                datafiles = [datafiles]

            for datafile in datafiles:
                lib.techila_peach_addParamFile(ph, datafile)

        if peachclient:
            # Create datafile for parameters
            inputdataname = 'techila_peach_inputdata_%d_%d' % (time.time(), random.randint(1, 1000000))
            file = open(inputdataname, 'wb')

            data = cPickle.Pickler(file, 1)
            data.dump(mode)

            funcdata = []
            if mode == 'function':
                code_str = marshal.dumps(function.func_code)
                defaults = function.func_defaults
                closure_values = []
                if function.func_closure:
                    closure_values = [v.cell_contents for v in function.func_closure]
                funcdata.append(code_str)
                funcdata.append(funcname)
                funcdata.append(defaults)
                funcdata.append(closure_values)
            elif mode == 'builtin':
                funcdata.append(funcname)
                funcdata.append(function.__module__)
            else:
                funcdata.append(funcname)

            data.dump(funcdata)

            if type(params) is str:
                params = [params]
            data.dump(params)
            data.dump(files)
            data.dump(peachvector)
            data.dump(maxidx)
            data.dump(steps)
            data.dump(pvjifmode)

            # funclist
            xfuncdatas = []
            if funclist is not None:
                if type(funclist) not in (list, tuple):
                    funclist = [funclist]
                for xfunc in funclist:
                    xfuncdata = []
                    xmode = None
                    if type(xfunc).__name__ == 'function':
                        xmode = 'function'
                        xfunction = xfunc
                        xfuncname = xfunc.func_name

                        xfuncdata.append(xmode)

                        xcode_str = marshal.dumps(xfunction.func_code)
                        xdefaults = xfunction.func_defaults
                        xclosure_values = []
                        if xfunction.func_closure:
                            xclosure_values = [v.cell_contents for v in xfunction.func_closure]
                        xfuncdata.append(xcode_str)
                        xfuncdata.append(xfuncname)
                        xfuncdata.append(xdefaults)
                        xfuncdata.append(xclosure_values)

                        xfuncdatas.append(xfuncdata)
            data.dump(xfuncdatas)

            file.close()


            # Add parameter file into parameter bundle
            lib.techila_peach_addParamFileWithTarget(ph, inputdataname, 'techila_peach_inputdata')

        if bundle_parameters:
            if type(bundle_parameters) is not dict:
                raise TechilaException('bundle_parameters must be defined as dictionaries, eg. {''key1'': ''value1'', ''key2'': ''value2''}', -1)

            for name in bundle_parameters.keys():
                lib.techila_peach_putParamExtras(ph, name, str(bundle_parameters.get(name)))


        if project_parameters:
            if type(project_parameters) is not dict:
                raise TechilaException('project_parameters must be defined as dictionaries, eg. {''key1'': ''value1'', ''key2'': ''value2''}', -1)

            for name in project_parameters.keys():
                lib.techila_peach_putProjectParam(ph, name, str(project_parameters.get(name)))



        # Project
        if peachvector is not None:
            jobs = int(math.ceil(float(len(peachvector)) / steps))
        else:
            jobs = int(math.ceil(float(jobs) / steps))

        # Set the number of jobs
        lib.techila_peach_setJobs(ph, jobs)

        if description:
            lib.techila_peach_setDescription(ph, description)

        #
        # execute
        #
        executesc = lib.techila_peach_execute(ph)

        if peachclient:
            os.remove(inputdataname)

        if pvjifmode and jifdatadir is not None:
            for pvjiffn in jobinputfiles.get('datafiles'):
                os.remove(jifdatadir + '/' + pvjiffn)
            os.rmdir(jifdatadir)

        if resume:
            resumefile = open(resumefn, 'wb')
            resumedata = cPickle.Pickler(resumefile, 1)
            resumepid = lib.techila_peach_getProjectId(ph)
            resumedata.dump(resumepid)
            resumefile.close()

    if executesc == 0:

        if donotwait:
            # return project handle
            # if the handle is closed, return projectid instead
            if close:
                results = lib.techila_peach_getProjectId(ph)
            else:
                results = lib.techila_peach_getProjectHandle(ph);

        else:
            # wait for results
            results = []

            tmpdir = getTempDir()
            resiter = ResultIter(lib,
                                 ph,
                                 tmpdir,
                                 peachclient,
                                 outputfiles is not None and outputfilecount > 1,
                                 callback,
                                 filehandler,
                                 intermediate_callback,
                                 douninit,
                                 return_iterable,
                                 resumefn)

            if return_iterable:
                # just return the iterable directly
                results = resiter
            else:
                # return list of results

                for (idx, result) in resiter:
                    #print 'resiter loop'

                    if idx is None:
                        # no peachclient, no idx returned
                        results.append(result)
                    else:
                        # increase result list size if needed
                        currentlen = len(results)
                        if currentlen < idx + 1:
                            for i in range(currentlen, idx + 1):
                                results.append(None)

                        results[idx] = result


    if donotwait:
        # suppress printing statistics
        lib.techila_peach_setMessages(ph, 0)

    if not return_iterable:
        # when iterable is returned this is called at the last result
        # within the iterable next function
        _peach_end(lib, ph, douninit)

    if executesc != 0:
        msg = ctypes.create_string_buffer('\000', size=4096)
        length = ctypes.c_int(4096)
        msg3 = None
        try:
            lib.techila_peach_getLastErrorMessage(ph, msg, ctypes.byref(length))

            if length.value > 0:
                msg3 = msg.value
        except:
            # not implemented in the dll?
            pass

        raise TechilaException('Peach execute failed', executesc, msg3 = msg3)

    return results

def _peach_end(lib, ph, douninit):
    # Clean up the environment
    lib.techila_peach_done(ph)

    if douninit:
        uninit()

def bundleit(package,
             version = None,
             all_platforms = False,
             expiration = '7 d',
             bundlename = None,
             sdkroot = None,
             initfile = None,
             password = None):

    print 'bundling', package

    if not bundlename:
        ver = sys.version_info
        python_version = str(ver[0])+str(ver[1])+str(ver[2])

        if not version:
            try:
                import pkg_resources
                version = pkg_resources.get_distribution(package).version
            except:
                version = '1.0.0'

        bundlename = '{user}.Python.v%s.package.%s.%s' % (python_version, package, version)

    douninit = False

    DIR = 0
    FILE = 1
    EGG = 2

    module = pkgutil.find_loader(package)

    if module is None:
        raise Exception('package %s not found' % package)

    if isinstance(module, zipimport.zipimporter):
        filename = module.archive
        mtype = EGG
    else:
        filename = module.filename
        if os.path.isdir(filename):
            mtype = DIR
        else:
            mtype = FILE

    bfilename = None
    moduleroot = None

    afiles=[]
    bfiles=[]
    envfile = ''
    if mtype == DIR:
        moduleroot = os.path.dirname(filename)
        for root, dirs, files in os.walk(filename):
            for name in files:
                afilename = os.path.join(root,name)
                if moduleroot != '':
                    bfilename = afilename.replace(moduleroot, '').replace(os.path.sep, '', 1)
                else:
                    bfilename = afilename
                afiles.append(afilename)
                bfiles.append(bfilename)
    elif mtype == FILE:
        bfilename = os.path.basename(filename)
        afiles.append(filename)
        bfiles.append(bfilename)
    elif mtype == EGG:
        bfilename = os.path.basename(filename)
        afiles.append(filename)
        bfiles.append(bfilename)
        envfile = '/' + bfilename
    else:
        raise TechilaException('Package %s found, but type %d is not supported' % (module[1], mtype), -1)


    environment = 'IGNORE_093843485;value=\"%%C(python_path,%%L(%s)%s,path.separator,PROPGET,|,python_path,PGET,ISNULL,,python_path,PGET,IF,|,PSET)\"' % (bundlename, envfile)


    if not Techila._initialized:
        douninit = True
        init(sdkroot, initfile, password)

    try:
        osname = get_java_system_property('os.name')
        processor = get_java_system_property('os.arch')

        ok = False
        natives = ''

        #print 'all_platforms = ', all_platforms

        if not all_platforms:
            samplefile = bfiles[0]
            if osname.startswith('Windows'):
                natives = '%s;osname=WindowsXP;processor=%s,'\
                    '%s;osname=Windows 2000;processor=%s,'\
                    '%s;osname=Windows Vista;processor=%s,'\
                    '%s;osname=Windows 7;processor=%s,'\
                    '%s;osname=Windows Server 2008;processor=%s,'\
                    '%s;osname=Windows Server 2008R2;processor=%s' % (samplefile, processor, samplefile, processor, samplefile, processor, samplefile, processor, samplefile, processor, samplefile, processor)
                ok = True
            elif osname.startswith('Linux'):
                natives = '%s;osname=Linux;processor=%s' % (samplefile, processor)
                ok = True
            else:
                raise TechilaException('Unsupported OS: %s' % osname, -1)
        else:
            ok = True

        externalresources = '%s;resource=%s' % (bundlename,bundlename)

        filesht = {}
        if ok:
            if len(afiles) > 0:
                for i in range(len(afiles)):
                    filesht[bfiles[i]] = afiles[i]

        extrasht = {}
        extrasht['ExternalResources'] = externalresources
        extrasht['Environment'] = environment
        extrasht['ExpirationPeriod'] = expiration

        try:
            ret = create_signed_bundle(bundlename,
                                       'bundled Python package: %s' % package,
                                       '0.0.1',
                                       bundlename,
                                       bundlename,
                                       natives,
                                       '',
                                       bundlename,
                                       '',
                                       extrasht,
                                       filesht,
                                       sdkroot,
                                       initfile,
                                       password,
                                       )

        except TechilaException as te:
            if te.msg2 is not None: # Bundle exists already, ignore the error
                ret = te.msg2

    finally:
        if douninit:
            uninit(True, True)

    return ret



def create_signed_bundle(name,
                         description = '',
                         version = '0.0.1',
                         imports = '',
                         exports = '',
                         natives = '',
                         category = '',
                         resource = '',
                         executor = '',
                         extras = None,
                         files = None,
                         sdkroot = None,
                         initfile = None,
                         password = None):

    #print 'create_signed_bundle'

    #print name, description, version, imports, exports, natives, category, resource, executor, extras, files, sdkroot, initfile, password

    filesarray = []
    for key in files.keys():
        filesarray.append(key + '=' + files.get(key))

    extrasarray = []
    if extras is not None:
        for key in extras.keys():
            extrasarray.append(key + '=' + extras.get(key))

    douninit = False
    if not Techila._initialized:
        douninit = True
        init(sdkroot, initfile, password)

    bundlename = None

    lib = None
    handle = None

    try:

        combinedarray = extrasarray + filesarray

        arraylen = len(combinedarray)
        carray = ctypes.c_char_p * arraylen
        ca = carray(*combinedarray)

        lib = Techila._lib

        handle = lib.techila_open()

        exists = lib.techila_bundleVersionExists(name, version)

        if exists:
            raise TechilaException('Bundle already exists', -1, name)

        ret = lib.techila_createSignedBundle3(handle, name, description, version, imports, exports, natives, category, resource, '', '', '', len(extrasarray), len(filesarray), ca)

        if ret != 0:
            raise TechilaException('Failed creating bundle', ret)

        cbundlename = ctypes.create_string_buffer('\000', size=1024)
        cbnlen = ctypes.c_int(1024)
        lib.techila_getLastCreatedBundleName(handle, cbundlename, ctypes.byref(cbnlen))

        tmpbundlename = cbundlename.value

        #print tmpbundlename

        exists = lib.techila_bundleVersionExists(tmpbundlename, version)

        if exists:
            raise TechilaException('Bundle already exists', -1, tmpbundlename)

        ret = lib.techila_uploadBundle(handle)

        if ret != 0:
            raise TechilaException('Failed uploading bundle', ret)

        ret = lib.techila_approveUploadedBundles(handle)

        if ret != 0:
            raise TechilaException('Failed approving bundle', ret)

        bundlename = tmpbundlename

    finally:
        if lib is not None and handle is not None:
            lib.techila_cleanup(handle, 255)
            lib.techila_close(handle)

        if douninit:
            uninit(True, True)


    return bundlename

def get_java_system_property(name):

    rvalue = None

    if Techila._libloaded:

        value = ctypes.create_string_buffer('\000', size=1024)
        length = ctypes.c_int(1024)
        r = Techila._lib.techila_getJavaSystemProperty(name, value, ctypes.byref(length))

        #print r

        rvalue = value.value

    return rvalue

def print_statistics(pid, out = sys.stdout):

    douninit = False

    if not Techila._initialized:
        douninit = True
        init()

    if Techila._libloaded:

        lib = Techila._lib

        handle = lib.techila_open()
        lib.techila_setProjectId(handle, pid)

        #lib.techila_printStatistics(handle)
        value = ctypes.create_string_buffer('\000', size=1024)
        length = ctypes.c_int(1024)
        r = lib.techila_getStatisticsString(handle, value, ctypes.byref(length))
        out.write(value.value)

        lib.techila_cleanup(handle, 255)
        lib.techila_close(handle)

    if douninit:
        uninit()

def send_im_data(jobid, data, handle = -1):
    if Techila._libloaded:
        lib = Techila._lib

        size = sys.getsizeof(data)

        try:
            if size < 256 * 1024:
                b64data = base64.encodestring(cPickle.dumps(data))

                command = 'inputdata;value="%F(key=' + b64data + ';file=techila_iminputdata.dat;fromparam=false;b64=true)"'
            else:
                f = open('techila_iminputdata.dat', 'wb')
                p = cPickle.Pickler(f)
                p.dump(data)
                f.close()

                bundlename = 'techila_{user}_inputdata_' + str(int(time.time())) + '_' + str(random.randint(0, 10000000000000000))

                bundlename = create_signed_bundle(bundlename, files = {'techila_iminputdata.dat' : 'techila_iminputdata.dat'})

                command = 'inputdata;value="%B(data;bundle=' + bundlename + ';file=techila_iminputdata.dat;dest=techila_iminputdata.dat)"'


            ljobid = ctypes.c_int64(jobid)

            exitcode = lib.techila_sendJobPostParameter(handle, ljobid, command)

        except Exception as e:
            print(e)

% createSignedBundle creates a new Matlab binary bundle
% handle        = techila handle
% bundlename    = bundle's name
% description   = description for bundle
% bundleversion = version in format x.y.z (eg. 0.0.1)
% natives       = platforms supported by the bundle
% extraparams   = additional control parameters
% fileparams    = files included in this bundle

% Copyright 2010-2012 Techila Technologies Ltd.

function createSignedBundle(handle, bundlename, description, bundleversion, natives, extraparams, fileparams, varargin)

% In normal execution, the Matlab libraries etc. are added to the
% environment and to the import statement. In case when the binary bundle
% doesn't contain Matlab binary, these libraries should be ignored. This
% can be forced by giving optional parameter after "fileparams". If this
% optional parameter has value 1, the Matlab libraries are ignored,
% otherwise they are included.
skipmatlab=0;
approve=true;
localmode=false;
bundlefile='';

%% Parse optional parameters
for i=1:size(varargin,2)
    varname=varargin{i}{1};
    varvalue=varargin{i}{2};
    if (isnumeric(varvalue))
        varvalue=num2str(varvalue);
    elseif (islogical(varvalue))
        if (varvalue==true)
            varvalue='true';
        else
            varvalue='false';
        end
    end
    cmd=[varname '=' varvalue ';'];
    eval(cmd);
end

%% Check parameters
global TECHILA_BUNDLES;
if ((~iscell(fileparams) && ~strcmp(fileparams,'')))
    %    throw(MException('TECHILA:error', 'Error in createSignedBundle: fileparams has to be in cells'));
    error('Error in createSignedBundle: fileparams has to be in cells');
end

if ((~iscell(extraparams) && ~strcmp(extraparams,'')))
    %    throw(MException('TECHILA:error', 'Error in createSignedBundle: extraparams has to be in cells'));
    error('Error in createSignedBundle: extraparams has to be in cells');
end

%% Converts file parameters to Java Hashtable
htfiles = java.util.Hashtable();
for i = 1:length(fileparams)
    fileparam=fileparams{i}{1};
    filename=fileparams{i}{2};
    if ~exist(filename, 'file')
        error(['Error in CreateSignedBundle: Unable to find file ' filename]);
    end
    htfiles.put(java.lang.String(fileparam), java.lang.String(filename));
end

%% Get Matlab Runtime version
[mcrmajor,mcrminor]=wrapmcrversion();
libver = [ 'v' num2str(mcrmajor) num2str(mcrminor) ];

%% Set default Matlab values for Environment and External Resources
if ~skipmatlab
    defaultEnvironment = ...
        'PATH;value="%C(%L(matlab);,PATH,ENVGET,|)";osname=Windows,PATH;value="%C(%L(matlab):,PATH,ENVGET,|)";osname=Linux,LD_LIBRARY_PATH;value="%L(matlab):%L(matlab)/../../sys/os/glnx86/:%L(matlab)/../../bin/glnx86/:%L(matlab)/../../sys/java/jre/glnx86/jre/i386/server/";osname=Linux;processor=i386,LD_LIBRARY_PATH;value="%L(matlab):%L(matlab)/../../sys/os/glnxa64/:%L(matlab)/../../bin/glnxa64/:%L(matlab)/../../sys/java/jre/glnxa64/jre/amd64/server/";osname=Linux;processor=amd64,USERPROFILE;value="%C(tmpdir,PGET)",HOME;value="%C(tmpdir,PGET)";osname=Linux,SYSTEMROOT;value="%C(SYSTEMROOT,ENVGET)";osname=Windows,DYLD_LIBRARY_PATH;value="%L(matlab):%L(matlab)/../../sys/os/maci/:%L(matlab)/../../bin/maci/";osname=Mac OS X;processor=i386,XAPPLRESDIR;value="%L(matlab)/../../X11/app-defaults";osname=Mac OS X;processor=i386';
    defaultExternalResources = [ 'matlab;resource=matlab;file=x86/Windows/' libver '/runtime/win32;osname=Windows;processor=x86,matlab;resource=matlab;file=x86/Windows/' libver '/runtime/win64;osname=Windows;processor=amd64,matlab;resource=matlab;file=i386/Linux/' libver '/runtime/glnx86;osname=Linux;processor=i386,matlab;resource=matlab;file=amd64/Linux/' libver '/runtime/glnxa64;osname=Linux;processor=amd64,matlab;resource=matlab;file=i386/maci/' libver '/runtime/maci;osname=Mac OS X;processor=i386' ];
    defaultImports = [ 'fi.techila.grid.cust.common.library.matlab.' libver '.client' ];
end

%% Assign default values, if they are not overridden
environmentSet = false;
resultHandlerSet = false;
splitterSet = false;
externalResourcesSet = false;

%% Default values for some parameters
if ~skipmatlab
    imports=defaultImports;
else
    imports = '';
end
exports = bundlename;
executor = [ bundlename ';specification-version=' bundleversion ];
resources = '';
activator = '';
categoryname = '{user}';

%% Converts extra parameters to Java Hashtable
htextras = java.util.Hashtable();
for i = 1:length(extraparams)
    extraparam=extraparams{i}{1};
    extravalue=extraparams{i}{2};
    if strcmp(extraparam, 'ExternalResources')
        if ~skipmatlab
            extravalue=[ defaultExternalResources ',' extravalue ];
        end
        externalResourcesSet = true;
    end
    if strcmp(extraparam, 'Imports')
        if ~skipmatlab
            imports=[ defaultImports ',' extravalue ];
        else
            imports=extravalue;
        end
        continue;
    end
    if strcmp(extraparam, 'Exports')
        exports=[ exports ',' extravalue ];
        continue;
    end
    if strcmp(extraparam, 'Executor')
        executor=extravalue;
        continue;
    end
    if strcmp(extraparam, 'Resources')
        resources=extravalue;
        continue;
    end
    if strcmp(extraparam, 'Activator')
        activator=extravalue;
        continue;
    end
    if strcmp(extraparam, 'Category')
        categoryname=extravalue;
        continue;
    end
    htextras.put(java.lang.String(extraparam), java.lang.String(extravalue));
    if strcmp(extraparam, 'Environment')
        environmentSet = true;
    end
    if strcmp(extraparam, 'ResultHandler')
        resultHandlerSet = true;
    end
    if strcmp(extraparam, 'Splitter')
        splitterSet = true;
    end
end

if ~skipmatlab
    if ~environmentSet
        htextras.put('Environment', defaultEnvironment);
    end
    if ~externalResourcesSet
        htextras.put('ExternalResources', defaultExternalResources);
    end
end

if ~resultHandlerSet
    htextras.put('ResultHandler', 'default');
end

if ~splitterSet
    htextras.put('Splitter', 'default');
end

if ~localmode && TECHILA_BUNDLES.bundleVersionExists(bundlename, bundleversion)
    keys = java.util.Vector;
    values = java.util.Vector;
    keys.add('name');
    values.add(['^' bundlename '$']);
    versions = TECHILA_BUNDLES.getBundles('createdat', true, 1, 0, keys, values);
    if isempty(versions) || versions.size() == 0
        error(['Bundle ''' bundlename ':' bundleversion ''' already exists']);
    else
        version = versions.get(0);
        error(['Bundle ''' bundlename ''' already exists. The latest version is ''' version.get('version') '''']);
    end
end

%% Create and upload bundle
% Creates a signed bundle with Matlab prerequisite as import and tells
% which operating systems are supported.
checkStatusCode(TECHILA_BUNDLES.createSignedBundle(handle, bundlename, description, bundleversion, imports, exports, natives, categoryname, resources, activator, executor, htextras, htfiles, bundlefile));
if ~localmode
% Uploads the binary bundle to the server.
checkStatusCode(TECHILA_BUNDLES.uploadBundle(handle));
% Tells the server, that no more binary bundles are uploaded. Server checks
% the prerequisites and the signatures of the uploaded bundles.
if approve
checkStatusCode(TECHILA_BUNDLES.approveUploadedBundles(handle));
    end
end

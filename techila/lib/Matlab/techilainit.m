% techilainit   Initializes Techila functionality
%
% techilainit(varargin)
%
% 'sdkRoot', '<location>'  = Path to the Techila SDK root
% 'LibPath', '<location>'  = Path to the Techila libraries
% 'InitFile', '<location>' = Path to the Techila settings file
% 'Password', '<password>' = Keystore password
% 'Init', {'InitParam', 'Initvalue', ...} = Initialize with the given
%                            parameters. Allowed parameters are
%                            'keystore' = keystore location
%                            'alias' = user's alias
%                            'password' = keystore password
%                            'hostname' = server's address
%                            'port' = server's port
%                            'temp' = temporary directory location
%                            'logfilename' = filename for log files
%                            'logfilesize' = maximum size of log file
%                            'logfilecount' = maximum number of log files
%                            'fileloglevel' = logging level to file
%                            'consoleloglevel' = logging level to console
%                            Logging levels allowed are OFF, SEVERE,
%                            WARNING, INFO, FINE, FINER, FINEST.

% Copyright 2010-2013 Techila Technologies Ltd.

function statuscode = techilainit(varargin)

%% Check existing initialization
global TECHILA;
if ~isempty(TECHILA)
    if TECHILA.isInitialized
        techilauninit;
%        warning('TECHILA:Init', 'Ignoring techilainit; Techila is already initialized. To uninitialize, execute techilauninit().')
%        statuscode = 0;
%        return;
    end
end

%% Workarounds
% workaround setting current dir, make relative paths work
java.lang.System.setProperty('user.dir', pwd);

% Remove broken https handler
urlStreamHandlerFactory = ice.util.net.URLStreamHandlerFactory;
urlStreamHandlerFactory.addStreamHandler('https', 'sun.net.www.protocol.https.Handler')

%% Initialize control parameters
initfile = '';
libPath = '';
sdkRoot = '';
init = {};
keystore = '';
alias = '';
password = '';
hostname = '';
port = '25001';
temp = tempdir();
logfilename = 'techila.log';
logfilesize = '100000';
logfilecount = '4';
fileloglevel = 'ALL';
consoleloglevel = 'OFF';
localmode = false;

%% Parse optional control parameters
for i=1:2:length(varargin)
    if strcmpi(varargin{i}, 'sdkroot')
        sdkRoot = varargin{i+1};
    elseif strcmpi(varargin{i}, 'gmkroot')
        sdkRoot = varargin{i+1};
    elseif strcmpi(varargin{i}, 'initfile')
        initfile = varargin{i+1};
    elseif strcmpi(varargin{i}, 'libpath')
        libpath = varargin{i+1};
    elseif strcmpi(varargin{i}, 'init')
        init = varargin{i+1};
    elseif strcmpi(varargin{i}, 'password')
        password = varargin{i+1};
    elseif strcmpi(varargin{i}, 'localmode')
        localmode = getLogicalValue(varargin{i+1});
    end
end

%% Define library and initfile paths
if ~isempty(init)
    for i=1:2:length(init)
        cmd = [lower(init{i}) '=''' init{i+1} ''';'];
        eval(cmd);
    end
end
if ~isempty(libPath)
    if isempty(sdkRoot)
        sdkRoot=[libPath '/..'];
    end
end
if isempty(sdkRoot)
    sdkRootEnv = getenv('TECHILA_SDKROOT');
    if ~isempty(sdkRootEnv)
        sdkRoot = sdkRootEnv;
    else
        pathstr = fileparts(mfilename('fullpath'));
        sdkRoot = [pathstr, '/../..'];
    end
end
if isempty(initfile)
    initfile = [ ];
end
if isempty(libPath)
    libPath = [ sdkRoot '/lib/'];
end
if ~exist([libPath '/techila.jar'], 'file')
    if exist([pwd '/techila.jar'], 'file')
        libPath = pwd;
    else
        error(['Error in TechilaInit: Unable to find techila.jar in ' libPath]);
    end
end

%% Add Java methods into path
techilajar = [libPath '/techila.jar'];
url = java.io.File(techilajar).toURL;
jl = com.mathworks.util.jarloader.JarLoader(techilajar);
cl = jl.getLoader;
classes=javaArray('java.lang.Class', 1);
classes(1)=url.getClass;
extcl = cl.getSystemClassLoader.getParent;
addExtURL = extcl.getClass.getDeclaredMethod('addExtURL', classes);
addExtURL.setAccessible(true);
addExtURL.invoke(extcl, url);
tmf = cl.loadClass('fi.techila.user.TechilaManagerFactory');
support = cl.loadClass('fi.techila.user.Support');
%% Initialize Techila methods
global TECHILA; %#ok<REDEF>
global TECHILA_BUNDLES;
global TECHILA_PROJECTS;
global TECHILA_RESULTS;
global TECHILA_SUPPORT;
global OK;
global CLEANUP_MODE_ALL;
global CLEANUP_MODE_RESULT_FILE;
global CLEANUP_MODE_UNZIP_FILES;
global CLEANUP_MODE_DOWNLOAD_DIR;
global CLEANUP_MODE_UNZIP_DIR;
global CLEANUP_MODE_CREATED_BUNDLES;
global CLEANUP_MODE_ERROR_FILES;
OK = support.getField('OK').get('');
CLEANUP_MODE_ALL = support.getField('CLEANUP_MODE_ALL').get('');
CLEANUP_MODE_RESULT_FILE = support.getField('CLEANUP_MODE_RESULT_FILE').get('');
CLEANUP_MODE_UNZIP_FILES = support.getField('CLEANUP_MODE_UNZIP_FILES').get('');
CLEANUP_MODE_DOWNLOAD_DIR = support.getField('CLEANUP_MODE_DOWNLOAD_DIR').get('');
CLEANUP_MODE_UNZIP_DIR = support.getField('CLEANUP_MODE_UNZIP_DIR').get('');
CLEANUP_MODE_CREATED_BUNDLES = support.getField('CLEANUP_MODE_CREATED_BUNDLES').get('');
CLEANUP_MODE_ERROR_FILES = support.getField('CLEANUP_MODE_ERROR_FILES').get('');
TECHILA = tmf.getMethod('getTechilaManager', '').invoke('', '');
TECHILA_BUNDLES = TECHILA.bundleManager();
TECHILA_PROJECTS = TECHILA.projectManager();
TECHILA_RESULTS = TECHILA.resultManager();
TECHILA_SUPPORT = TECHILA.support();

%% Workaround
% set Java working directory to Matlab's working directory
java.lang.System.setProperty('user.dir', pwd);

%% Techila initialization
if ~isempty(init)
    % Check parameters for initialization without inifile
    if isempty(keystore)
        error('Error in TechilaInit: Keystore location is mandatory parameter');
    end
    if isempty(alias)
        error('Error in TechilaInit: Alias is mandatory parameter');
    end
    if isempty(hostname)
        error('Error in TechilaInit: Server hostname is mandatory parameter');
    end
    statuscode = TECHILA.init(keystore, alias, password, hostname, str2num(port), temp, ...
        logfilename, str2num(logfilesize), str2num(logfilecount), fileloglevel, consoleloglevel);
else
    if localmode
        configuration = TECHILA.preInitFile(initfile, password);
        configuration.setHostname('<none>'); % Prevent server connection
        configuration.setSecurity(false); % Prevent signing of the bundles
        statuscode = TECHILA.init(configuration);
    else
    if isempty(password)
        statuscode = TECHILA.initFile(initfile);
    else
        statuscode = TECHILA.initFile(initfile, password);
    end
    end
    if statuscode == -101
        error(['Error in TechilaInit: Unable to find techila_settings.ini']);
    end
end
if ~isempty(TECHILA)
    if ismethod(TECHILA, 'getPluginNames')
    plugins=TECHILA.getPluginNames();
    for id=1:plugins.length
        pluginname = plugins(id);
        pluginconf = TECHILA.getPluginConf(pluginname);
        if ~isempty(pluginconf)
            pluginloc = pluginconf.get('location');
            if ~isempty(pluginloc) && exist(pluginloc, 'file')
                url2 = java.io.File(pluginloc).toURL;
                addExtURL.invoke(extcl, url2);
                pluginclass = TECHILA.getPluginClassName(pluginname);
                cl.loadClass(pluginclass);
                plugin=TECHILA.getPlugin(pluginname);
                end
            end
        end
    end
    
end
end

%localCompile   Compiles Matlab code on local machine
%
%localCompile(funcname, ...) compiles function.
%
%The method returns compilation in array having values:
%filename, osname, osarch, MCRversion
%
% The optional parameters for localCompile are:
%
% 'Messages', 'false'      = Do not print any messages
%
% 'TmpDir', '<location>'   = The directory where the compiled executables
%                            are written into and where the project data is
%                            written temporarily
%
% 'MCCStandAlone', 'false' = Do not use standalone mode (with system
%                            command) to execute MCC locally, but call it
%                            directly as Matlab function. This may cause
%                            mcc license to be locked up for the rest of
%                            the Matlab session.
%
% 'MatlabRequired', 'false' = Compiling with Matlab-compiler.
%                            Default = 'true'.
%
% 'MCCPath', {'path1', 'path2', ...} = Additional folders to add into
%                            MATLAB search path when compiling Matlab
%                            files.
%
% 'PeachClient', 'false'   = Compile something that is not
%                            using PeachClient.
%
% 'UseJVM', 'true'         = Compile with JVM support.
%
% 'UseMatlabPath', 'false' = Do not include Matlab's path to the
%                            compilation.
%
% 'MCCParams', '<string>'  = Additional parameters for MCC
%
% 'MultiThreading', 'true' = Allow compiled code to use multiple CPU cores
%                            if the code supports multithreading.
%
% Copyright 2010-2016 Techila Technologies Ltd.
function compilation = localCompile(funcname, varargin)
Messages = true;
tmpdir = 'techila_tmp';
UseJVM = false;
MCCPath = {};
MCCStandAlone = true;
PeachClient = true;
MatlabMode = true;
MultiThreading = false;
paramDependencies={};
MexFiles={};
platform=-1;
UseMatlabPath = true;
AdditionalParams = '';

if length(funcname) > 2 && strcmp(funcname(end-1:end), '.m')
    funcname=funcname(1:end-2);
end
fun=functions(str2func(funcname));
[pathstr, name, ext] = fileparts(fun.file);

for i=1:2:length(varargin)
    if strcmpi(varargin{i},'tmpdir')
        tmpdir=varargin{i+1};
    elseif strcmpi(varargin{i},'usejvm')
        UseJVM = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'mccstandalone')
        MCCStandAlone = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'peachclient')
        PeachClient = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'messages')
        if (~getLogicalValue(varargin{i+1}))
            Messages = false;
        else
            Messages = true;
        end
    elseif strcmpi(varargin{i},'matlabrequired')
        MatlabMode = getLogicalValue(varargin{i+1});
        if ~MatlabMode
            PeachClient = false;
        end
    elseif strcmpi(varargin{i},'mccpath')
        MCCPath = [MCCPath varargin{i+1}];
    elseif strcmpi(varargin{i}, 'paramDependencies')
        paramDependencies = varargin{i+1};
    elseif strcmpi(varargin{i}, 'MexFiles')
        MexFiles = varargin{i+1};
    elseif strcmpi(varargin{i}, 'platform')
        platform = varargin{i+1};
    elseif strcmpi(varargin{i}, 'usematlabpath')
        UseMatlabPath = getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i}, 'mccparams')
        AdditionalParams = varargin{i+1};
    elseif strcmpi(varargin{i}, 'multithreading')
        MultiThreading = getLogicalValue(varargin{i+1});
    end
end

% If Interconnection is used, JVM is needed
if ~isempty(cell2mat(strfind(paramDependencies, 'commTechila.'))) || ~isempty(cell2mat(strfind(paramDependencies, 'techilaSendRequest.'))) || ~isempty(cell2mat(strfind(paramDependencies, 'saveIMData.'))) || ~isempty(cell2mat(strfind(paramDependencies, 'techilaSemaphore.')))
    UseJVM = true;
end

paramDependencies=unique(paramDependencies);

if ~iscell(platform) && platform==-1
    platform = {char(java.lang.System.getProperty('os.name')), char(java.lang.System.getProperty('os.arch'))};
end


[mcrmajor,mcrminor]=wrapmcrversion(varargin{:});
if mcrmajor==0 && mcrminor==0
    error('Error in Peach: Could not find Matlab Compiler');
end

% Create temporary directory if it does not exist
if (exist(tmpdir, 'dir') == 0)
    mkdir(tmpdir);
end
cmptmpdir = [tmpdir '/' num2str(now*10000000000) '_' num2str(rand*1000000000)];
mkdir(cmptmpdir);

compiletime=tic;
% Remove old files
if PeachClient
    if exist([tmpdir '/peachclient'], 'file')
        delete([tmpdir '/peachclient']);
    end
    if exist([tmpdir '/peachclient.exe'], 'file')
        delete([tmpdir '/peachclient.exe']);
    end
    if exist([tmpdir '/peachclient.ctf'], 'file')
        delete([tmpdir '/peachclient.ctf']);
    end
    if exist([tmpdir '/peachclient.zip'], 'file')
        delete([tmpdir '/peachclient.zip']);
    end
    if exist([tmpdir '/peachclient.app'], 'dir')
        rmdir([tmpdir, '/peachclient.app'], 's');
    end
else
    if exist([tmpdir '/' name], 'file')
        delete([tmpdir '/' name]);
    end
    if exist([tmpdir '/' name '.exe'], 'file')
        delete([tmpdir '/' name '.exe']);
    end
    if exist([tmpdir '/' name '.ctf'], 'file')
        delete([tmpdir '/' name '.ctf']);
    end
    if exist([tmpdir '/' name '.zip'], 'file')
        delete([tmpdir '/' name '.zip']);
    end
    if exist([tmpdir '/' name '.app'], 'dir')
        rmdir([tmpdir, '/' name '.app'], 's');
    end
end
if MatlabMode
    if PeachClient
        peachclientfun = functions(str2func('peachclient'));
        peachclientfile = ['"' peachclientfun.file '" '];
    else
        peachclientfile = '';
    end
    % Check the compilation environment
    if ~exist([prefdir '/compopts.bat'], 'file') && ~exist([prefdir '/mbuildopts.sh'], 'file') && ~exist([prefdir '/MBUILD_C_' computer('arch') '.xml'], 'file')
        mbuild -setup
    end
    if ~exist([prefdir '/compopts.bat'], 'file') && ~exist([prefdir '/mbuildopts.sh'], 'file') && ~exist([prefdir '/MBUILD_C_' computer('arch') '.xml'], 'file')
        error('Unable to compile, compiler is not configured!');
    end
    if UseJVM
        jvmparam = ' ';
        hlpfun = functions(str2func('hlp_serialize'));
        if sum(cellfun(@(x) isequal(hlpfun.file, x), paramDependencies))==0
            paramDependencies = [paramDependencies {hlpfun.file}];
        end
    else
        jvmparam = ' -R -nojvm ';
    end
    if MultiThreading
        mtparam = '';
    else
        mtparam = '-R -singleCompThread ';
    end
end
% Compile MEX files
if ~isempty(MexFiles)
    % Check the MEX compilation environment
    cc=mex.getCompilerConfigurations;
    if isempty(cc)
        mex -setup
        cc=mex.getCompilerConfigurations;
    end
    if isempty(cc)
        error('Unable to compile MEX files, compiler is not configured!');
    end
    for i=1:length(MexFiles)
        MexFile = MexFiles{i};
        if (ischar(MexFile(1)))
            MexFile = {MexFile};
        end
        MexIncludes={};
        RealMexFiles={};
        for j=1:length(MexFile)
            if strncmp(MexFile{j}, '#', 1)
                MexIncludes=[MexIncludes MexFile{j}(2:end)];
            else
                RealMexFiles=[RealMexFiles MexFile{j}];
            end
        end
        if Messages
            fprintf('Compiling MEX %s...\n', RealMexFiles{1});
        end
        mex('-outdir', cmptmpdir, RealMexFiles{:});
    end
end
if Messages
    fprintf('Compiling %s for %s-%s locally ...\n', name, platform{1}, platform{2});
end

zipfiles = {};
if MatlabMode
    % Support compiling standalone (releases the compiler license
    % faster)
    if MCCStandAlone
        osname = char(java.lang.System.getProperty('os.name'));
        if strncmpi(osname, 'Windows', 7)
            mcccmd = '';
        else
            mcccmd = [getenv('MATLAB') '/bin/'];
        end
        
        mcccmd = [mcccmd 'mcc -N -m -w disable:all_warnings -d "' cmptmpdir '" -I "' cmptmpdir '"' jvmparam mtparam AdditionalParams ' '];
        mccdeps=[peachclientfile '"' fun.file '"'];
        for pidx=1:length(paramDependencies)
            paramdep=paramDependencies{pidx};
            [pathstr, name, ext]=fileparts(paramdep);
            if ~isempty(strfind(pathstr, [filesep '+'])) || ~isempty(strfind(pathstr, [filesep '@'])) || strncmp(name, '+', 1) || strncmp(name, '@', 1)
                continue
            end
            if strncmp(paramdep, '#', 1)
                paramdep=['-a "' paramdep(2:end) '"'];
            else
                paramdep=['"' paramdep '"'];
            end
            mccdeps = [mccdeps ' ' paramdep];
        end
        f=fopen('mccpath', 'wt');
        for mp=MCCPath
            [pathstr, name, ext] = fileparts(mp{:});
            while ~isempty(strfind(fullfile(pathstr), [filesep '+'])) || ~isempty(strfind(fullfile(pathstr), [filesep '@']))
                [pathstr, name, ext] = fileparts(pathstr);
            end
            if strncmp(name, '@', 1) || strncmp(name, '+', 1)
                fprintf(f, '%s\n', ['-I "' fullfile(pathstr) '"']);
            else                
                fprintf(f, '%s\n', ['-I "' fullfile(mp{:}) '"']);
            end
        end
        if UseMatlabPath
            fprintf(f, '%s', ['-I "' strrep(matlabpath, pathsep, sprintf('"\n-I "')) sprintf('"\n')]);
        end
        fprintf(f, '%s', mccdeps);
        fprintf(f, '\n');
        fclose(f);
        [status, mccresult] = system(mcccmd);
        delete('mccpath');
        if status~=0
            if strcmp(mccresult, 'bad allocation')
                % Workaround
                MCCStandAlone = false;
            else
                errormsg = ['Error in compiling ' name ': errormessage=' mccresult ', errorcode=' num2str(status) '.'];
                throw(MException('TECHILA:localcompile', '%s', errormsg));
            end
        end
    end
    if ~MCCStandAlone
        mccdeps={};
        for pidx=1:length(paramDependencies)
            [pathstr, name, ext]=fileparts(paramDependencies{pidx});
            if ~isempty(strfind(pathstr, [filesep '+'])) || ~isempty(strfind(pathstr, [filesep '@'])) || strncmp(name, '+', 1) || strncmp(name, '@', 1)
                continue
            end
            paramdep = paramDependencies{pidx};
            if strncmp(paramdep, '#', 1)
                paramdep=['-a "' paramdep(2:end) '"'];
            end
            mccdeps = [mccdeps {paramdep}];
        end
        if ~UseJVM
            if ~MultiThreading
                mcc('-m', '-d', cmptmpdir, '-w', 'disable:all_warnings', '-I', cmptmpdir, '-R', '-nojvm', '-R', '-singleCompThread', peachclientfun.file, fun.file, mccdeps{:});
            else
                mcc('-m', '-d', cmptmpdir, '-w', 'disable:all_warnings', '-I', cmptmpdir, '-R', '-nojvm', peachclientfun.file, fun.file, mccdeps{:});
            end
        else
            if ~MultiThreading
                mcc('-m', '-d', cmptmpdir, '-w', 'disable:all_warnings', '-I', cmptmpdir, '-R', '-singleCompThread', peachclientfun.file, fun.file, mccdeps{:});
        else
                mcc('-m', '-d', cmptmpdir, '-w', 'disable:all_warnings', '-I', cmptmpdir, peachclientfun.file, fun.file, mccdeps{:});
            end
        end
    end
    if PeachClient
        if exist([cmptmpdir '/peachclient'], 'file')
            zipfiles = [zipfiles, {'peachclient'}];
        end
        if exist([cmptmpdir '/peachclient.exe'], 'file')
            zipfiles = [zipfiles, {'peachclient.exe'}];
        end
        if exist([cmptmpdir '/peachclient.ctf'], 'file')
            zipfiles = [zipfiles, {'peachclient.ctf'}];
        end
        if exist([cmptmpdir '/peachclient.app'], 'dir')
            zipfiles = [zipfiles, {'peachclient.app'}];
        end
    else
        if exist([tmpdir '/' name], 'file')
            zipfiles = [zipfiles, {name}];
        end
        if exist([tmpdir '/' name '.exe'], 'file')
            zipfiles = [zipfiles, {[name '.exe']}];
        end
        if exist([tmpdir '/' name '.ctf'], 'file')
            zipfiles = [zipfiles, {[name '.ctf']}];
        end
        if exist([tmpdir '/' name '.app'], 'dir')
            zipfiles = [zipfiles, {[name '.app']}];
        end
    end
else
    cmpfiles=dir(cmptmpdir);
    for fileid=1:length(cmpfiles)
        if ~cmpfiles(fileid).isdir
            zipfiles = [zipfiles, {cmpfiles(fileid).name}];
        end
    end
end
% Compress the compilations into zip file
if PeachClient
    outfile = strrep([ tmpdir '/peachclient_for_' platform{1} '_' platform{2} '.zip' ], ' ', '_');
else
    outfile = strrep([ tmpdir '/' name '_for_' platform{1} '_' platform{2} '.zip' ], ' ', '_');
end
zip(outfile, zipfiles, cmptmpdir);
[status, message, messageid] = rmdir(cmptmpdir, 's');
[major, minor, point] = mcrversion;
version=[num2str(major) num2str(minor)];
if point>0
    version = [version num2str(point)];
end
if Messages
    fprintf('Compiled in %1.3f seconds.\n', toc(compiletime));
end
compilation = {{outfile, platform{1}, platform{2}, version }};
end



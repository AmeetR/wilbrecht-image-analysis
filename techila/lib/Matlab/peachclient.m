% Peach (Parallel each) wrapper for the computation.

% Copyright 2010-2017 Techila Technologies Ltd.

function peachclient(varargin)
global TechilaPeach
global TechilaJobId
global TechilaSnapshot
global TechilaSnapshotInterval
global TechilaSnapshotDelay
global TechilaSnapshotTic
global TECHILAPARAMETERS
global TECHILACALLEXITINEND
if isempty(TECHILACALLEXITINEND)
    TECHILACALLEXITINEND=true;
end
try    
    TECHILAPARAMETERS=varargin;
    if nargin == 0
        jobidx = 1;
    else
        jobidx = varargin{1};
    end
    origdir = cd();

    jobidx = str2num(num2str(jobidx));
    
    TechilaJobId = jobidx;
    TechilaPeach = true;
    
    TechilaLogFile = 'TechilaLog.txt';
    
    running = true;
    
    while running
        if exist(TechilaLogFile, 'file')
            delete(TechilaLogFile);
        end
        running = false;
        
    %% Initialize random number generators
    seed = rem(rem(now*10000,1)*1000*jobidx, 2^32);
    if (exist('RandStream', 'class') == 8)
        stream=RandStream('mt19937ar', 'seed', seed);
        if ismethod(stream, 'setGlobalStream')
            RandStream.setGlobalStream(stream);
        else
            RandStream.setDefaultStream(stream);
        end
    else
        rand('state', seed);
        randn('state', seed);
    end
    
    %% Initialize snapshot timer
    TechilaSnapshot = false;
    TechilaSnapshotInterval = 3600;
    TechilaSnapshotDelay = 3600;
    TechilaSnapshotTic = 0;
    TechilaProfile = false;
    TechilaProfileLevel = 1;
    TechilaProfileMem = 1;
    TechilaProfileTimer = 1;
    TechilaProfileHistory = 1;
    TechilaProfileHistorySize = 1000000;
        TechilaStatefulProject = false;
        TechilaLogging = false;
        TechilaCatchErrors = false;
    
    SnapshotFiles = '';
    Snapshot = false;
        
        TechilaSerialized = false;
        
        if exist('./techila_peach_inputdata.mat', 'file')
            eval('load(''techila_peach_inputdata.mat'');');
        elseif exist('./techila_peach_inputdata.ser', 'file')
            tpifid = fopen('./techila_peach_inputdata.ser', 'r');
            tpidata = fread(tpifid);
            fclose(tpifid);
            try
                tpistruct = hlp_deserialize(tpidata);
            catch E
                fprintf(['Invalid serialized data: ' tpidata '\n']);
                rethrow(E)
            end
            tpifields = fields(tpistruct);
            for tpiid = 1:length(tpifields)
                eval([tpifields{tpiid} '=tpistruct.(tpifields{tpiid});']);
            end
            if ~exist('params', 'var') && exist('parameters', 'var')
                % workaround for a reserved word in some languages
                params = parameters;
            end
        else
            error('Unable to find input file ''techila_peach_inputdata.mat''');
        end
    if (Snapshot)
        % Only support loadSnapshot/saveSnapshot with the default filename
        if ~strcmp(SnapshotFiles, 'snapshot.mat')
            warning('Snapshot is supported only with filename snapshot.mat');
        else
            TechilaSnapshot = true;
            % Convert SnapshotInterval from minutes to seconds and use half of
            % the value
            TechilaSnapshotInterval = 30 * str2num(num2str(SnapshotInterval));
            % But not less than 60 seconds
            if TechilaSnapshotInterval < 60
                TechilaSnapshotInterval = 60;
            end
            % The first delay is 30 seconds shorter
            TechilaSnapshotDelay = TechilaSnapshotInterval - 30;
            TechilaSnapshotTic = tic;
        end
    end
    
        if TechilaLogging
            echo on
            echo on all
            diary(TechilaLogFile);
        end
        
    %% Construct command to start computation
    cmd=[funcname '('];
    for i=1:length(params)
        if ischar(params{i}) && length(params{i})>6 && strcmp(params{i}(1:6),'<param')
            if strcmp(params{i}(1:7),'<param>')
                if isempty(peachvector)
                    cmd=[cmd 'jobidx'];
                else
                    cmd=[cmd 'peachvector(jobidx)'];
                end
            else
                [start_idx, end_idx, extents, matches, tokens, names, splits] = regexpi(params{i}, '<param([0-9]+)>');
                if ~isempty(tokens)
                    paramidx = cell2mat(tokens{1});
                    cmd=[cmd 'peachvector{jobidx}{' paramidx '}'];
                else
                    cmd=[cmd 'params{' num2str(i) '}'];
                end
            end
        else
            cmd=[cmd 'params{' num2str(i) '}'];
        end
        if (i<length(params))
            cmd=[cmd ','];
        end
    end
    cmd=[cmd ');'];
    
        funexist = exist(funcname);
        if funexist < 2 || funexist > 6
            error(['Unable to find function ''' funcname '''']);
        end
        
    %% Start the computation
    parcount = nargout(funcname);
    if TechilaProfile
        callstats('history', TechilaProfileHistory);
        callstats('timer', TechilaProfileTimer);
        callstats('memory', TechilaProfileMem);
        callstats('historysize', TechilaProfileHistorySize);
        callstats('reset');
        callstats('resume');
    end
        
        try
    if parcount == 0
        eval(cmd);
    elseif parcount == 1
        result=eval(cmd);
    else
        % For computations with multiple result values, read the results
        % into a cell array
        result=cell(1,parcount);
        parcmd = '[';
        for i=1:parcount
            parcmd = [parcmd 'result{' num2str(i) '} '];
        end
        parcmd = [parcmd ']=' cmd];
        cd(origdir);
        eval(parcmd);
    end
        catch ME
            if TechilaCatchErrors
                TechilaException = ME;
            else
                rethrow(ME)
            end
        end
        
    if TechilaProfile
        callstats('stop');
        [ft,fh,cp,name,cs,~,overhead] = callstats('stats');
        for ftid=1:length(ft)
            ft(ftid).FileName=regexprep(ft(ftid).FileName, '.*peachclient\', '');
        end
            TechilaStats.FunctionTable = ft;
            TechilaStats.FunctionHistory = fh;
            TechilaStats.ClockPrecision = cp;
            TechilaStats.ClockSpeed = cs;
            TechilaStats.Name = name;
            TechilaStats.Overhead = overhead;
        end

        diary off
        if TechilaLogging
            if exist(TechilaLogFile, 'file')
                TechilaLog = fileread(TechilaLogFile);
            else
                TechilaLog = '';
            end
    end

    %% Save results
        if TechilaSerialized
            if TechilaProfile
                resultstruct.TechilaStats = TechilaStats;
            end
            if TechilaLogging
                resultstruct.TechilaLog = TechilaLog;
            end
            if exist('TechilaException', 'var')
                resultstruct.TechilaException = TechilaException;
            end
            if exist('resultstruct', 'var')
                if exist('result', 'var')
                    resultstruct.TechilaResult = result;
                end
                result = resultstruct;
            end
            SerializedResults = hlp_serialize(result);
            resultfid = fopen('result.mat', 'w');
            fwrite(resultfid, SerializedResults);
            fclose(resultfid);
        else
    if parcount > 0
        cd(origdir);
                if exist('result', 'var')
        save('result.mat', 'result');
    end
            end
    if TechilaProfile
                save('result.mat', 'TechilaStats', '-append');
            end
            if TechilaLogging
                if exist('TechilaLog', 'var')
                    save('result.mat', 'TechilaLog', '-append');
                end
            end
            if exist('TechilaException', 'var')
                save('result.mat', 'TechilaException', '-append');
            end
        end
        if TechilaStatefulProject
            running = true;
            jobidx = changeJob;
            TechilaJobId = jobidx;
            if TechilaJobId < 0
                running = false;
            end
        end
    end
catch ME1
    %% Handle errors
%    ME1 = lasterror;
    msg=parseME(ME1);
    fprintf('%s\n', msg);
    if TECHILACALLEXITINEND
        exit(99);
    end
end
%% Cleanup
if TECHILACALLEXITINEND
    quit force
end
end
function msg=parseME(ME1)    
    msg = sprintf('%s: %s\n', ME1.identifier, ME1.message);
    msg = [ msg sprintf('%s\n', 'Stack:') ];
    if ~isempty(ME1.stack)
        for me=1:size(ME1.stack,1)
            msg = [msg sprintf('  %s, %s:%d\n', ME1.stack(me).name, ME1.stack(me).file, ME1.stack(me).line)];
        end
    end
    if ~isempty(ME1.cause)
        msg = [msg sprintf('%s\n', 'Cause:') ];
        for c=1:size(ME1.cause,1)
            msg=[msg parseME(ME1.cause{c})];
        end
    end
end
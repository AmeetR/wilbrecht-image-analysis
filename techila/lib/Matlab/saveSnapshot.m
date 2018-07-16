% Save given variables into snapshot file.
% Usage: saveSnapshot('var1', 'var2', ...)
%
% Optional parameters:
% -donotappend     = always create a new file
% -file:<filename> = use <filename> instead of snapshot.mat
% -debug           = debug printing
% -entry:<id>      = identifier for the saved variables (default is got from function stacktrace)
% SEE ALSO loadSnapshot

% Copyright 2010-2012 Techila Technologies Ltd.

function result = saveSnapshot( varargin )
result = false;
append = true;
debug = false;
structname='';
file = 'snapshot.mat';
global TechilaSnapshot TechilaSnapshotTic TechilaSnapshotInterval TechilaSnapshotDelay TechilaDoSnapshot TechilaPeach TechilaDebug;
if isempty(TechilaSnapshot)
    TechilaSnapshot = false;
end
if isempty(TechilaDoSnapshot)
    TechilaDoSnapshot = false;
end
if isempty(TechilaPeach)
    TechilaPeach = false;
end
if isempty(TechilaSnapshotTic)
    TechilaSnapshotTic = tic;
end
if isempty(TechilaSnapshotDelay)
    TechilaSnapshotDelay = 600;
end
if isempty(TechilaSnapshotInterval)
    TechilaSnapshotInterval = 600;
end
if isempty(TechilaDebug)
    TechilaDebug = false;
end
for i=1:nargin
    if (strcmpi(varargin{i}, '-debug'))
        debug = true;
    elseif strcmpi(varargin{i}, '-donotappend')
        append = false;
    elseif strncmpi(varargin{i}, '-file:', 6)
        file = varargin{i}(7:end);
    elseif strncmpi(varargin{i}, '-entry:', 7)
        structname = varargin{i}(8:end);
    end
end
if TechilaDebug
    debug = true;
end
if debug
    fprintf('DEBUG - SaveSnapshot executed at %s\n', datestr(now));
end
if ~TechilaPeach || (TechilaSnapshot && (TechilaDoSnapshot || (isa(TechilaSnapshotTic,'uint64') && toc(TechilaSnapshotTic) >= TechilaSnapshotDelay)))
    try
        ST = dbstack;
        if isempty(structname)
            tracestring = '';
            for i=3:length(ST)
                tracestring = [tracestring ', ' ST(i).name ':' num2str(ST(i).line)];
            end
        else
            tracestring = structname;
        end
        checksum = adler32(tracestring);
        entry = ['snapshot_' num2str(checksum)];
        eval([entry '=struct();']);
        
        eval([entry '.stacktrace=ST;']);
        for i=1:nargin
            arg = varargin{i};
            if ~strcmp(arg(1), '-')
                eval([entry '.' arg '=evalin(''caller'', varargin{i});']);
                if debug
                    fprintf('DEBUG - SaveSnapshot saving field %s\n', arg);
                end
            end
        end
        if exist(file, 'file') && append
            if debug
                fprintf('DEBUG - SaveSnapshot appending file %s\n', file);
            end
            snapshotdata=load(file);
            eval(['snapshotdata. ' entry '=' entry ';']);
            save(file, '-struct', 'snapshotdata');
            result = true;
        else
            if debug
                fprintf('DEBUG - SaveSnapshot creating file %s\n', file);
            end
            save(file, entry);
            result = true;
        end
    catch ME1
        warning(['Error in saving snapshot: ' ME1.message]);
        result = false;
    end
    TechilaSnapshotDelay = TechilaSnapshotInterval;
    TechilaSnapshotTic = tic;
end
end


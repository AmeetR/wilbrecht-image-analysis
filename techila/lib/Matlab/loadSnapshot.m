% Check if the snapshot file exists and load it into caller workspace.
% Usage: loadSnapshot()
%
% Optional parameters:
% -file:<filename> = use <filename> instead of snapshot.mat
% -debug           = debug printing
% -entry:<id>      = identifier for the saved variables (default is got from function stacktrace)
% SEE ALSO saveSnapshot

% Copyright 2010-2012 Techila Technologies Ltd.

function result = loadSnapshot(varargin)
result = false;
debug = false;
structname = '';
file = 'snapshot.mat';
global TechilaSnapshot TechilaPeach TechilaDebug;
if isempty(TechilaPeach)
    TechilaPeach = false;
end
if isempty(TechilaSnapshot)
    TechilaSnapshot = false;
end
if isempty(TechilaDebug)
    TechilaDebug = false;
end
for i=1:nargin
    if (strcmpi(varargin{i}, '-debug'))
        debug = true;
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
    fprintf('DEBUG - LoadSnapshot executed at %s\n', datestr(now));
end
if ~TechilaPeach || TechilaSnapshot
    if exist(file, 'file') == 2
        if debug
            fprintf('DEBUG - LoadSnapshot found %s\n', file);
        end
        try
            if isempty(structname)
                tracestring = '';
                ST = dbstack;
                for i=3:length(ST)
                    tracestring = [tracestring ', ' ST(i).name ':' num2str(ST(i).line)];
                end
            else
                tracestring = structname;
            end
            checksum = adler32(tracestring);
            load(file);
            entry = ['snapshot_' num2str(checksum)];
            if exist(entry, 'var')
                eval (['data=' entry ';']);
                if isstruct(data)
                    fields = fieldnames(data);
                    if debug
                        fprintf('DEBUG - LoadSnapshot loading field %s\n', fields{:});
                    end
                    for i=1:length(fields)
                        field = fields{i};
                        if ~strcmp(field, 'stacktrace')
                            assignin('caller', field, getfield(data, field));
                        end
                    end
                    result = true;
                end
            end
        catch ME1
            error=dir(file)
            warning(['Unable to read snapshot: ' ME1.message]);
            result = false;
        end
    else
        if debug
            fprintf('DEBUG - LoadSnapshot didn''t find snapshot file.\n');
        end
    end
end
end


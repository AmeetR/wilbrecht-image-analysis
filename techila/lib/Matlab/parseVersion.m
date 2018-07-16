% Parse MCR version out of compilation log or readme.txt.

% Copyright 2010-2016 Techila Technologies Ltd.

function mcrversion = parseVersion(tmpdir, zipfile)
mcrversion='0';
[status, message, messageid]=mkdir([tmpdir '/unzip']);
unzip(zipfile, [tmpdir '/unzip/']);
if exist([tmpdir '/unzip/readme.txt'], 'file')
    mcrversion = parseReadme([tmpdir '/unzip/readme.txt']);
end
if strcmp(mcrversion, '0') && exist([tmpdir '/unzip/log'], 'file')
    mcrversion = parseLog([tmpdir '/unzip/log']);
end
[status, message, messageid]=rmdir([tmpdir '/unzip'], 's');
if strcmp(mcrversion, '0')
    error('Techila:Compilation', 'Unknown version of Matlab Compiler');
end
end

function mcrversion = parseReadme(readmefile)
mcrversion='0';
f = fopen(readmefile);
if f>0
    line = fgetl(f);
    while ischar(line)
            match=regexp(line, '.*installed version ([0-9]*).([0-9]*).([0-9]*).*', 'tokens');
        if ~isempty(match)
            mcrversion=[match{:}{:}];
            break;
        end
        line = fgetl(f);
    end
    fclose(f);
end
end

function mcrversion = parseLog(logfile)
mcrversion='0';
f = fopen(logfile);
if f>0
    line = fgetl(f);
    while ischar(line)
        match=regexp(line, '.*Compiler version: [0-9].([0-9]*).*', 'tokens');
        if ~isempty(match)
            prever=str2num(match{:}{:});
            if prever>17
                mcrversion=num2str(parseNewVersion(line));
            else
                mcrversion=num2str(str2num(['7' match{:}{:}]));
            end
            break;
        end
        line = fgetl(f);
    end
    fclose(f);
end
end

function mcrversion = parseNewVersion(line)
match=regexp(line, '.*Compiler version: [0-9].([0-9]*).([0-9]*).*', 'tokens');
ver1=str2num(match{:}{1});
ver2=str2num(match{:}{2});
mcrversion=0;
if (ver1==18)
    mcrversion=80;
    if ~isempty(ver2)
        mcrversion=mcrversion+ver2;
    end
end
end

% Return the file's timestamp.

% Copyright 2010-2012 Techila Technologies Ltd.

function result = getdatenum(file)
if isfield(file, 'datenum')
    result=file.datenum;
else
    result=datenum(file.date);
end
end

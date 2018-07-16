%getLogicalValue
% Parses numeric (~0|0) and string ('true', 'on', 'yes', '1'|<something
% else>) values into logical values (true|false)

% Copyright 2010-2012 Techila Technologies Ltd.

function ret = getLogicalValue(value)
if islogical(value)
    ret=value;
elseif isnumeric(value)
    if (value==0)
        ret=false;
    else
        ret=true;
    end
elseif ischar(value)
    if (strcmpi(value, 'true') || ...
            strcmpi(value, 'on') || ...
            strcmpi(value, 'yes') || ...
            strcmp(value, '1'))
        ret=true;
    else
        ret=false;
    end
else
    ret=false;
end
end

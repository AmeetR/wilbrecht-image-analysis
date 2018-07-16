% Compares cells

% Copyright 2010-2012 Techila Technologies Ltd.

function [ result ] = cellcmp(a,b)
result = false;
if length(a) ~= length(b)
    return;
end
if iscell(a) ~= iscell(b)
    return;
end
if ~iscell(a)
    if isstr(a)
        if isstr(b)
            result = strcmp(a,b);
        end
        return;
    end
    if isstruct(a)
        if isstruct(b)
            result=cellcmp(struct2cell(a), struct2cell(b));
        end
        return;
    end
    if isnumeric(a)
        if isnumeric(b)
            result = min(a==b);
        end
        return;
    end
    return;
end
for l=1:length(a)
    if ~cellcmp(a{l}, b{l})
        return
    end
end
result = true;
return
end


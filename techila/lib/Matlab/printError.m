% printError    Prints the error message and the location into the log or
% console
%
% printError(ME) prints the message of the exception ME on the console with
% the location where the exception was thrown.

% Copyright 2010-2012 Techila Technologies Ltd.

function printError(ME1)
msg=sprintf('error: %s\n', ME1.message);
msg = [ msg sprintf('%s\n', 'Stack:') ];
for me=1:size(ME1.stack,1);
    msg = [msg sprintf('  %s, %s:%d\n', ME1.stack(me).name, ME1.stack(me).file, ME1.stack(me).line)];
end
global TECHILA_SUPPORT;
if ~isempty(TECHILA_SUPPORT)
    TECHILA_SUPPORT.log('SEVERE', msg);
else
    fprintf('%s\n', msg);
end
end

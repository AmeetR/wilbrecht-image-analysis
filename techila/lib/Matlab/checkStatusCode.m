% Function to check the status of the Techila function calls. In case of
% error, throws an exception with the error message.
% In normal cases this toolbox function does not need to be modified.

% Copyright 2010-2012 Techila Technologies Ltd.

function checkStatusCode(code)

global TECHILA_SUPPORT;
global OK;

if (code ~= OK)
    msg = TECHILA_SUPPORT.describeStatusCode(code);
    le = TECHILA_SUPPORT.getLastErrorMessage();
    errormsg=['Error: ' char(msg) '(' num2str(code) '). Last error in log: ' char(le)];
    if exist('MException', 'file')
        me = MException('TECHILA:error', '%s', errormsg);
        throw(me);
    else
        error('TECHILA:error', errormsg);
    end
end
end

% Execute callback method for the results.

% Copyright 2010-2012 Techila Technologies Ltd.

function result = execCallbackCommand(CallbackMethod, CallbackParams, resultfile)
cmd='CallbackMethod(';
% If the callback parameters are not defined, try to call method with
% the filename of the result.
if isempty(CallbackParams)
    cmd=[ cmd '''' char(resultfile) ''');'];
    
else
    readresultfile = false;
    % Parse the callback parameters. All the '<x>' parameters are changed
    % to be read from result struct, like 'struct.x'. The special parameter
    % '<*>' is replaced with the whole result struct. All the other
    % parameters are defined with the caller values.
    for i=1:length(CallbackParams)
        if (i > 1)
            cmd=[cmd ','];
        end
        if (strcmp(CallbackParams{i},'<*>'))
            cmd=[cmd 'clientres' ];
            readresultfile = true;
        elseif (strcmp(CallbackParams{i}(1),'<'))
            cmd=[cmd 'clientres.' CallbackParams{i}(2:length(CallbackParams{i})-1)];
            readresultfile = true;
        elseif (strcmp(CallbackParams{i},'{resultfile}'))
            cmd=[cmd '''' char(resultfile) ''''];
        else
            cmd=[cmd 'CallbackParams{' num2str(i) '}'];
        end
    end
    cmd=[cmd ');'];
    if readresultfile
        clientres=load(char(resultfile), '-mat');
    end
end
parcount = nargout(CallbackMethod);
if parcount == 0
    eval(cmd);
    result = {};
elseif parcount == 1
    result=eval(cmd);
else
    result=cell(1,parcount);
    parcmd = '[';
    for i=1:parcount
        parcmd = [parcmd 'result{' num2str(i) '} '];
    end
    parcmd = [parcmd ']=' cmd];
    eval(parcmd);
end
end

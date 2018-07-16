% addToJavaPath Adds techila.jar into javapath.
% Changing javapath makes global
% variables to vanish, so we save them before changing javapath and reload
% afterwards.

% Copyright 2010-2012 Techila Technologies Ltd.

function addToJavaPath( techilajar )
if sum(strcmp(techilajar, javaclasspath)) == 0
    globals = whos('global');
    for i=1:length(globals)
        cmd=['global ' globals(i).name ';'];
        eval(cmd);
    end
    oldstate=warning('off', 'MATLAB:save:illegalDataForMATFile');
    warning('off', 'MATLAB:unassignedOutputs');
    warning('off', 'MATLAB:javaclasspath:duplicateEntry');
    warning('off', 'MATLAB:Java:DuplicateClass');
    warning('off', 'MATLAB:cellRefFromNonCell');
    warning('off', 'MATLAB:Java:ConvertFromOpaque');
    save('workspaceGlobalTemp.mat', globals([globals.bytes]>0).name)
    %[x,y]=lastwarn
    javaaddpath(techilajar);
    load('workspaceGlobalTemp.mat');
    %[x,y]=lastwarn
    warning(oldstate);
    delete('workspaceGlobalTemp.mat');
end
end


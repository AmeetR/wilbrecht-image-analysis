% Finds toolbox folder name for product name

% Copyright 2014 Techila Technologies Ltd.
function [ output_args ] = findToolboxNames( input_args )
res=[];
list=dir(toolboxdir(''));
w=warning('off', 'MATLAB:ver:ProductNameDeprecated');
for a=1:size(list,1)
    tb=strtrim(list(a).name);
    b=ver(tb);
    if ~isempty(b) && ~strcmp(b.Name, 'MATLAB')
        res=[res setfield(b,'ToolBox',tb)];
    end
end
warning(w);
[a,b,c]=intersect(lower(input_args), lower({res.Name}));
output_args={res(c).ToolBox};
end


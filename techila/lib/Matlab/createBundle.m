% createBundle creates a new bundle
% handle        = techila handle
% bundleprefix  = prefix for bundle name (<prefix>.<username>.<bundlename>)
% bundlename    = bundle's name (see above)
% description   = description for bundle
% bundleversion = version in format x.y.z (eg. 0.0.1)
% imports       = list of components (bundles) imported by this bundle
% exports       = list of components exported by this bundle
% categoryname  = category
% resources     = resources offered by this bundle
% executor      = project executor bundle in this bundle tree
% extraparams   = additional control parameters
% fileparams    = files included in this bundle

% Copyright 2010-2012 Techila Technologies Ltd.

function status=createBundle(handle, bundleprefix, bundlename, description, ...
    bundleversion, imports, exports, categoryname, resources, executor, extraparams, fileparams, varargin)

%% Initialize control parameters
createsignedbundles=true;
approve=true;

%% Parse optional control parameters
for i=1:2:length(varargin)
    if strcmpi(varargin{i},'alwayssign')
        createsignedbundles=getLogicalValue(varargin{i+1});
    elseif strcmpi(varargin{i},'approve')
        approve=getLogicalValue(varargin{i+1});
    end
end

%% Check file and extra parameters
global TECHILA_BUNDLES;
if ((~iscell(fileparams) && ~strcmp(fileparams,'')))
    %    throw(MException('TECHILA:error', 'Error in createBundle: fileparams has to be in cells'));
    error('Error in createBundle: fileparams has to be in cells');
end

if ((~iscell(extraparams) && ~strcmp(extraparams,'')))
    %    throw(MException('TECHILA:error', 'Error in createBundle: extraparams has to be in cells'));
    error('Error in createBundle: extraparams has to be in cells');
end

%% Converts file parameters to Java Hashtable
htfiles = java.util.Hashtable();
for i = 1:length(fileparams)
    fileparam=fileparams{i}{1};
    filename=fileparams{i}{2};
    if ~exist(filename, 'file')
        error(['Error in CreateSignedBundle: Unable to find file ' filename]);
    end
    htfiles.put(java.lang.String(fileparam), java.lang.String(filename));
end

%% Create bundle, signed or unsigned
if createsignedbundles
    %% Converts extra parameters to Java Hashtable
    htextras = java.util.Hashtable();
    for i = 1:length(extraparams)
        param=extraparams{i}{1};
        value=extraparams{i}{2};
        htextras.put(java.lang.String(param), java.lang.String(value));
    end
    %% Create and upload bundle
    if isempty(bundleprefix)
        fullbundlename = bundlename;
    else
        fullbundlename = [bundleprefix '.{user}.' bundlename];
    end
    if TECHILA_BUNDLES.bundleVersionExists(fullbundlename, bundleversion)
        keys = java.util.Vector;
        values = java.util.Vector;
        keys.add('name');
        values.add(['^' fullbundlename '$']);
        versions = TECHILA_BUNDLES.getBundles('bundleVersion', true, 1, 0, keys, values);
        if isempty(versions) || versions.size() == 0
            error(['Bundle ''' fullbundlename ':' bundleversion ''' already exists']);
        else
            version = versions.get(0);
            error(['Bundle ''' fullbundlename ''' already exists. The latest version is ''' version.get('version') '''']);
        end
    end
    status=TECHILA_BUNDLES.createSignedBundle(handle, fullbundlename, description, bundleversion, imports, exports, '', categoryname, resources, '', executor, htextras, htfiles);
    checkStatusCode(status);
    % Uploads the binary bundle to the server.
    checkStatusCode(TECHILA_BUNDLES.uploadBundle(handle));
    % Tells the server, that no more binary bundles are uploaded. Server checks
    % the prerequisites and the signatures of the uploaded bundles.
    if approve
    checkStatusCode(TECHILA_BUNDLES.approveUploadedBundles(handle));
    end
else
    %% Converts extra parameters to Java Vector
    vextras = java.util.Vector();
    for i = 1:length(extraparams)
        if length(extraparams{i}) == 2
            param=extraparams{i}{1};
            value=extraparams{i}{2};
            vextras.add([param ': ' value]);
        else
            vextras.add(extraparams{i});
        end
    end
    %% Create bundle on server
    status=TECHILA_BUNDLES.createBundle(handle, bundleprefix, bundlename, description, bundleversion, imports, exports, categoryname, resources, executor, vextras, htfiles);
    checkStatusCode(status);
end


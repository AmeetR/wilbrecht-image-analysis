function plugin = getplugin(pluginname, location)
global TECHILA
if nargin==1
    location=[];
end
plugin=[];
if isempty(location)
try
    plugin = TECHILA.getPlugin(pluginname);
catch
end
end
if isempty(plugin)
    pluginconf = TECHILA.getPluginConf(pluginname);
    if isempty(location)
    if isempty(pluginconf)
        error(['Unable to find configuration for plugin ''' pluginname '''']);
    end
    location=pluginconf.get('location');
    end
    if isempty(location) || ~exist(location, 'file')
        error(['Unable to find location for plugin ''' pluginname '''']);
    end
    url = java.io.File(location).toURL;
    jl = com.mathworks.util.jarloader.JarLoader(location);
    cl = jl.getLoader;
    classes=javaArray('java.lang.Class', 1);
    classes(1)=url.getClass;
    extcl = cl.getSystemClassLoader.getParent;
    addExtURL = extcl.getClass.getDeclaredMethod('addExtURL', classes);
    addExtURL.setAccessible(true);
    addExtURL.invoke(extcl, url);
    jf = java.util.jar.JarFile(location);
    je = jf.getJarEntry('plugin.desc');
    if ~isempty(je) 
        rs = jf.getInputStream(je);
    else
    rs=cl.getResourceAsStream('plugin.desc');
    end
    br = java.io.BufferedReader(java.io.InputStreamReader(rs));
    classname = [];
    while true
        line = br.readLine;
        if isempty(line)
            break;
        end
        pos = line.indexOf('=');
        if pos == -1
            continue;
        end
        key = line.substring(0, pos);
        value = line.substring(pos + 1);
        if key.equals('class')
            classname=char(value);
        end
    end
    if isempty(classname)
        error(['Unable to find classname for plugin ''' pluginname '''']);
    end
    cl.loadClass(char(classname));
    TECHILA.registerPlugin(classname, pluginname);
    plugin=TECHILA.getPlugin(pluginname);
end

end


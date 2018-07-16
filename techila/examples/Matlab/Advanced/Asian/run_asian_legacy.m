function run_asian_legacy()
% Local Control code. This function is executed locally on the End-Users
% computer. The function will initialize the Techila environment,
% compile the computing intensive Asian routine in 'asian_legacy_wrapper.m' and create
% a computational Project. The Project will compute the Asian routine
% and results will be visualised by plotting them on a graph.
%
% To run the example, use command:
% run_asian_legacy
fprintf('Execution started!\n');

% initial stock price, linspace from, to, step
S0x1 = 45;
S0x2 = 47;
S0n = 9;
S0 = linspace(S0x1,S0x2,S0n);

% initial volatility of stock return, linspace from, to, step
sigma0x1 = 0.35;
sigma0x2 = 0.4;
sigma0n = 9;
sigma0 = linspace(sigma0x1, sigma0x2, sigma0n);

%The parameters of stock price diffusion
M = 20000; %The number of trajectories
jobs = sigma0n*S0n;
N = 365; %The number of data points in year
nn=1;    % number of time steps per sample point

%The parameters of volatility diffusion
rho=-0.5; %The correlation between the increments of stock price and volatility
kappa=0.1; %The speed of revision
psi=0.5; %The standard deviation of volatility

%Other parameters
E=70; %Exercise price
T=1; %Maturity time
r = 0.05; % Interest rate

% Root directory of the SDK
fprintf('Initializing!\n');

%Initialize the toolbox function techilainit()
status = techilainit();

%Defines the TechilaManager, bundle, and result management interface
%variables TECHILA, TECHILA_BUNDLES, TECHILA_PROJECTS and TECHILA_RESULTS as global,
%the management interfaces has been assigned in the techilainit() toolbox
%function.
global TECHILA;
global TECHILA_BUNDLES;
global TECHILA_PROJECTS;
global CLEANUP_MODE_ALL;

try %Try – catch block to trace back possible errors and their locations.

    %Checks the status of the initialization using toolbox function
    %checkStatusCode(). If any errors have occurred, the exception is
    %thrown and the catch block will print out the error to the console.
    checkStatusCode(status);

    %Opens a project handle for a new project. The purpose for the
    %handle is to be an identifier in the Management Interface. It is
    %used to bind together bundle and project related information between
    %function calls.
    handle = TECHILA.open();

    %Defines the name of the bundle which will contain the executable
    %binary of the distributed Asian routine compiled in the helper function
    %createBinaryBundleOfAsian().
    bundleName = '{user}.legacy.Asian';

    %The version of the binary bundle.
    %•  If any changes are made to the distributed Asian routine in the  •
    %•   'asian_legacy_wrapper.m' file, this version number has to be increased.  •
    %The version number is in format x.y.z, where each of the parts (x,y,z)
    %can be any whole number. The using of the parts is not fixed anyway,
    %but the newer version of the bundle must have greater number.
    %For example 0.1.0 is greater than 0.0.1000. Good way to use the format
    %is to increase the value of z for minor changes, the value of y for
    %major changes and the value of x for the bigger releases.
    bundleVersion = '1.0.0';

    %The method bundleVersionExist()is used to check if the binary bundle
    %with the specified version is already compiled and committed to the
    %Techila server.
    %If the bundle does not exist on the server, the separated helper
    %function createBinaryBundleOfAsian() is called to compile the binary
    %and create the binary bundle.
    if ~TECHILA_BUNDLES.bundleVersionExists(bundleName, bundleVersion);
        createBinaryBundleOfAsian(handle, bundleName, bundleVersion);
    end

    %Binds the binary bundle to be the base for the project to be created.
    checkStatusCode(TECHILA_BUNDLES.useBundle(handle, bundleName));

    %Priority of the project executed in the Techila environment.
    %4 is normal priority, 7 is the lowest and 1 is the highest.
    projectPriority = 4;

    projectDescription = 'Asian calculation';

    %Create a new project based on the bundle using toolbox function
    %createProject().
    checkStatusCode(createProject(handle, projectPriority, projectDescription, ...
        {{'jobs', jobs}, ...
         {'S0x1', S0x1}, ...
         {'S0x2', S0x2}, ...
         {'S0n', S0n}, ...
         {'sigma0x1', sigma0x1}, ...
         {'sigma0x2', sigma0x2}, ...
         {'sigma0n', sigma0n}, ...
         {'M', M}, ...
         {'nn', nn}, ...
         {'r', r}, ...
         {'N', N}, ...
         {'rho', rho}, ...
         {'kappa', kappa}, ...
         {'psi', psi}, ...
         {'E', E}, ...
         {'T', T}, ...
        }));


    %Get the id of the created project and write it to the console. This
    %information is also used in the output filename.
    projectid = TECHILA_PROJECTS.getProjectId(handle);
    fprintf('Project created with id: %i\n', projectid);

    %Waits the completion of the project using toolbox function
    %waitAndRetrieveResults(). The toolbox function writes the progress of
    %the project as percent value to the console. When the project is
    %finished, the compressed result file is downloaded and extracted to
    %partial result files. The names of the result files are returned.
    resultfiles = waitAndRetrieveResults(handle);

    price = zeros(sigma0n,S0n);

    %Loops for the number of the partial result files, loads a partial
    %result files to the Matlab environment and reads the content of the
    %variables indexj, indexi and jobresult (which are read from the
    %partial result file) and places jobresult to the given point in the
    %price matrix.
    for p=1:size(resultfiles,1)
        load(char(resultfiles(p)), '-mat')
        price(indexj, indexi) = jobprice;
    end

    %Create a figure, create a meshgrid, draw price values in a surface,
    %and define labels for the figure.
    figure;
    [S,sigma]=meshgrid(S0, sigma0);
    surf(S,sigma,price);
    xlabel('Initial stock price'),ylabel('Initial volatility'),zlabel('Price of Asian Call')
    title('Plot generated by the distributed version (legacy)')

    %Get and print some statistics about the project.
    cputime = TECHILA_PROJECTS.getUsedCpuTime(handle);
    realtime = TECHILA_PROJECTS.getUsedTime(handle);

    fprintf('CPU time used %i d %i h %i m %i s.\n', ...
        floor(cputime/3600/24), ...
        floor(cputime/3600 - floor(cputime/3600/24)*24), ...
        floor(cputime/60 - floor(cputime/3600)*60), ...
        floor(cputime - floor(cputime/60)*60));
    fprintf('Real time used %i d %i h %i m %i s.\n', ...
        floor(realtime/3600/24), ...
        floor(realtime/3600 - floor(realtime/3600/24)*24), ...
        floor(realtime/60 - floor(realtime/3600)*60), ...
        floor(realtime - floor(realtime/60)*60));

    %Removes the temporary files etc. created by the Techila interface.
    TECHILA.cleanup(handle, CLEANUP_MODE_ALL);

    TECHILA.close(handle); %Closes the project handle.

%Catches any possible exceptions caused by any error during the
%execution and prints out the error message to console using toolbox
%function printError().
catch
    printError(lasterror);
end

%Unloads the Techila interface and removes the temp. directories.
TECHILA.unload(true, true);

end


function createBinaryBundleOfAsian(handle, bundleName, bundleVersion)
% This function is a helper routine for compiling the distributed Asian
% routine in the 'asian_legacy_wrapper.m' file that will be executed in the
% Techila environment.
%
% Parameters are:
% handle = the project handle,
% bundleName = the name of the binary bundle
% bundleVersion = the version of the binary bundle
%Since this may take a while, inform the user.
fprintf('Compiling binary...\n');

tmpdir='output';

% Create temporary directory if it does not exist
if (exist(tmpdir, 'dir') == 0)
    mkdir(tmpdir)
end

%Matlab MCC compiler is used to to compile the distributed Monte Carlo
%routine in the asian_legacy_wrapper.m file as a executable binary 'asian_legacy_wrapper.exe'
%and 'asian_legacy_wrapper.ctf' file.
[mcrmajor,mcrminor]=mcrversion();
if (mcrmajor >= 8 || (mcrmajor==7 && mcrminor >= 8))
    mcc('-m', '-C', '-d', tmpdir, '-R', '-nojvm', 'asian_legacy_wrapper.m');
else
    mcc('-m', '-d', tmpdir, '-R', '-nojvm', 'asian_legacy_wrapper.m');
end

fprintf('Binary compilation done.\n');

bundleDescription = 'Asian binary';

%The binary is now compiled and it needs to be moved in the Techila
%enviroment. Next part will explain how the binary is made as a bundle.

if (strcmp(char(java.lang.System.getProperty('os.name')), 'Linux'))
   exename='asian_legacy_wrapper';
else
   exename='asian_legacy_wrapper.exe';
end
%The name of the binary compiled above, the supported processor
%architecture and the supported Operating System are described here.
%In this example to different suported Operating Systems are defined:
%Windows XP and Windows Vista. They are separeted with comma (,).
natives = 'asian_legacy_wrapper.exe;osname=Windows XP;processor=x86,asian_legacy_wrapper.exe;osname=Windows Vista;processor=x86,asian_legacy_wrapper.exe;osname=Windows 7;processor=x86,asian_legacy_wrapper;osname=Linux;processor=i386';

%extraparams are used as a definitions for compiled binary bundle.
%Â•  Copy = Files included in the bundle to be copied to the execution
%directory. This contains the files included in the binary bundle which
%are needed for the execution of the binary. This contains at least the
%.exe and .ctf files in case when Matlab is used in Windows
%environment. Only the files that are not mentioned in the Executable
%or Parameters are needed to be included to this definition. The files
%mentioned in the Executable or Parameters are copied automatically.
%Â•  InternalResources = The files included in the binary bundle that
%can be referenced in the Executable or Parameters. This contains at
%least the binary executable compiled aboce, but optionally also input
%files etc. that can be used in Parameters.
%Â•  Executable = The resource of the binary file to be executed on the
%Techila workers. This file is copied automatically to the execution
%directory.
%Â•  OutputFiles = The files that are written out from the binary and
%whose content should be sent to the server as the result.
%Â•  Parameters Â– Command line arguments for the binary.
extraparams = {
    {'Copy', 'asian_legacy_wrapper.ctf'}, ...
    {'InternalResources', ['asian_legacy_wrapper.ctf, asian_legacy_wrapper;file=' exename]}, ...
    {'Executable', '%I(asian_legacy_wrapper)'}, ...
    {'OutputFiles', 'output;file=result.mat'}, ...
    {'Parameters', '%P(jobidx) %P(S0x1) %P(S0x2) %P(S0n) %P(sigma0x1) %P(sigma0x2) %P(sigma0n) %P(M) %P(nn) %P(r) %P(N) %P(rho) %P(kappa) %P(psi) %P(E) %P(T) %O(output)'}};

%fileparams are used to describe the resource names and locations of
%the files to be included in the binary. These are the same names that
%were defined in the InternalResources above. The file locations must
%contain the _full_path_ to the files if they are not located in the
%same directory as the Matlab file.
fileparams = {
    {exename, [ tmpdir '/' exename ]}, ...
    {'asian_legacy_wrapper.ctf', [ tmpdir '/asian_legacy_wrapper.ctf' ]}};

%A new signed bundle is made of the compiled binary using toolbox
%method createSignedBundle() with the parameters define above.
createSignedBundle(handle, bundleName, bundleDescription, ...
    bundleVersion, natives, extraparams, fileparams);

end



// Copyright 2008-2013 Techila Technologies Ltd.
/**
 * @file Techila.h Techila Management C API.
 */
#include "jni.h"
#ifdef __cplusplus
extern "C" {
#endif

#ifndef LPSTR
typedef char *LPSTR;
#endif

#ifdef WIN32
  #include <ole2.h>
#else
  #if !(defined(_SIZE_T) || defined(_SIZE_T_DEFINED))
    #define _SIZE_T
    #define _SIZE_T_DEFINED
    typedef unsigned int size_t; // -D_GCC_SIZE_T
  #endif
#endif

enum {
  CLEANUP_MODE_ALL             = 0,
  CLEANUP_MODE_RESULT_FILE     = 1,
  CLEANUP_MODE_UNZIP_FILES     = 2,
  CLEANUP_MODE_DOWNLOAD_DIR    = 4,
  CLEANUP_MODE_UNZIP_DIR       = 8,
  CLEANUP_MODE_CREATED_BUNDLES = 16,
  CLEANUP_MODE_ERROR_FILES     = 32
};

int techila_actionWait(long timeout);
int techila_addUserClientsToProject(int handle);
int techila_approveUploadedBundles(int handle);
int techila_bundleExists(LPSTR bundleName);
int techila_bundleVersionExists(LPSTR bundleName, LPSTR bundleVersion);
int techila_bundleWithPrefixExists(LPSTR bundlePrefix, LPSTR bundleName);
int techila_cleanup(int handle, int mode);
int techila_close(int handle);
int techila_createBundle(int handle, LPSTR bundleprefix, LPSTR bundlename,
                 LPSTR description, LPSTR bundleversion,
                 LPSTR imports, LPSTR exports, LPSTR categoryname,
                 LPSTR resources, LPSTR executor,
                 int extracount, int filecount, ...);
int techila_createEmptyProject(int handle, int priority, LPSTR description);
int techila_createCachedJob(int handle, int paramcount, ...);
int techila_createJob(int handle, int paramcount, ... );
int techila_createProject(int handle, int priority, LPSTR description, int paramcount, ...);
int techila_createProjectJobs(int handle, int paramcount, ... );
int techila_createSignedBundle(int handle, LPSTR bundlename, LPSTR description,
                       LPSTR bundleversion, LPSTR imports, LPSTR exports,
                       LPSTR natives, LPSTR categoryname, LPSTR resources,
                       LPSTR activator, LPSTR executor,
                       LPSTR bundlefile, int extracount, int filecount, ...);
int techila_describeStatusCode(int code, LPSTR description, size_t *len);
int techila_downloadResult(int handle);
int techila_downloadPartialResult(int handle);
int techila_flushCachedJobs(int handle);
int techila_getBundleId(int handle);
int techila_getLastCreatedBundleName(int handle, LPSTR bundlename, size_t *len);
int techila_getLastError(int handle);
int techila_getLastErrorMessage(LPSTR msg, size_t *len);
int techila_getProjectDescription(int handle, LPSTR desc, size_t *len);
int techila_getProjectId(int handle);
int techila_getProjectParamCount(int handle);
int techila_getProjectParamName(int handle, int *index, LPSTR paramname, size_t *len);
int techila_getProjectParamValue(int handle, LPSTR paramname, LPSTR paramvalue, size_t *len);
int techila_getProjectStatistic(int handle, LPSTR paramname, LPSTR paramvalue, size_t *len);
int techila_getProjectStatus(int handle);
int techila_printStatistics(int handle);
int techila_getStatisticsString(int handle, LPSTR statsstr, size_t *len);
int techila_getResultDirectory(int handle, LPSTR dir, size_t *len);
int techila_getResultFile(int handle, LPSTR file, size_t *len);
int techila_getResultFiles(int handle, int *index, LPSTR filename, size_t *len);
int techila_getStreamedResultFiles(int handle, int *index, LPSTR filename, size_t *len);
int techila_getStreamedResultFilesCount(int handle);
long techila_getUsedCpuTime(int handle);
long techila_getUsedTime(int handle);
int techila_getUserLogin(LPSTR login, size_t *len);
int techila_init();
int techila_initFile(LPSTR filename);
int techila_initFileWithPassword(LPSTR filename, LPSTR password);
int techila_initJava();
int techila_initWithoutFile(LPSTR keystore, LPSTR alias, LPSTR password, LPSTR hostname, int port, LPSTR tempdir, LPSTR logfilename, int logfilesize, int logfilecount, LPSTR fileloglevel, LPSTR consoleloglevel);
int techila_isCompleted(int handle);
int techila_isFailed(int handle);
int techila_isJobCompleted(int handle, long jobid);
int techila_markAllJobsCreated(int handle);
int techila_open();
int techila_peach(int paramcount, ...);
int techila_peachDone(int peachhandle);
int techila_peachNextFile(int peachhandle, LPSTR file, size_t *len);
int techila_ready(int handle);
int techila_removeProject(int handle);
int techila_setBundleId(int handle, int bundleId);
int techila_setDownloadDir(int handle, LPSTR dir);
int techila_setLogLevel(LPSTR level);
int techila_setProjectId(int handle, int projectId);
int techila_setProjectParams(int handle, int paramcount, ...);
int techila_setStreamResults(int handle, unsigned char streamResults);
int techila_setUnzipDir(int handle, LPSTR dir);
int techila_signJar(LPSTR infile, LPSTR outfile);
int techila_startProject(int handle);
int techila_stopProject(int handle);
int techila_stopWaitingBG(int handle);
int techila_unload(unsigned char removeTempDir);
int techila_unzip(int handle);
int techila_unzipFile(LPSTR filename, LPSTR destdir, LPSTR options);
int techila_uploadBundle(int handle);
int techila_uploadBundleWithName(int handle, LPSTR bundlefile);
int techila_useBundle(int handle, LPSTR bundleName);
int techila_useBundleWithPrefix(int handle, LPSTR bundlePrefix, LPSTR bundleName);
int techila_waitCompletion(int handle);
int techila_waitCompletionBG(int handle);

int techila_sendJobPostParameter(int handle, long long jobid, LPSTR command);

// char** variants
int techila_createSignedBundle3(int handle, LPSTR bundlename, LPSTR description,
                        LPSTR bundleversion, LPSTR imports, LPSTR exports,
                        LPSTR natives, LPSTR categoryname, LPSTR resources,
                        LPSTR activator, LPSTR executor, LPSTR bundlefile,
                        int extracount, int filecount, char** param);
int techila_createProjectJobs3(int handle, int paramcount, char** param);
int techila_createProject3(int handle, int priority, LPSTR description, int paramcount, char** param);
int techila_createCachedJob3(int handle, int paramcount, char** param);
int techila_createJob3(int handle, int paramcount, char** param);
int techila_createBundle3(int handle, LPSTR bundleprefix, LPSTR bundlename,
                  LPSTR description, LPSTR bundleversion,
                  LPSTR imports, LPSTR exports, LPSTR categoryname,
                  LPSTR resources, LPSTR executor,
                  int extracount, int filecount, char** param);
int techila_setProjectParams3(int handle, int paramcount, char** param);
int techila_peach3(int paramcount, char** param);
int techila_getPlugin(LPSTR plugin, jobject* value);
jclass techila_getPluginClass(LPSTR plugin);
int techila_getPluginConf(LPSTR plugin, LPSTR key, LPSTR msg, size_t *len);
JNIEnv* techila_getJNIEnv();
JavaVM* techila_getJavaVM();

  // ---

  /**
   * Unload the library, close the session
   * @param removeTempDir remove tempdir
   * @param recursive remove recurively
   * @return status code
   */
  int techila_unload2(unsigned char removeTempDir, unsigned char recursive);


  /**
   * Get the session specific temporary directory.
   * @param dir buffer for the temp dir
   * @param len length of the buffer
   * @return status
   */
  int techila_getTempDir(LPSTR dir, size_t *len);


  /**
   * Get Java System property value. Equals to System.getProperty(name).
   * @return status code
   */
  int techila_getJavaSystemProperty(LPSTR name, LPSTR value, size_t *len);

// peach
  /**
   * Get a handle for the Peach object. This must be called first before
   * using other peach_ -functions.
   * @return peach handle to be used when calling other functions
   */
  int techila_peach_handle();

  /**
   * Set the peach name.
   * @param handle the peach handle
   * @param name the name
   */
  int techila_peach_setName(int handle, LPSTR name);

  /**
   * Set the the directory where peach state files are to be stored.
   * @param handle the peach handle
   * @param name the directory
   */
  int techila_peach_setStateDir(int handle, LPSTR name);

  /**
   * Set the description.
   * @param handle the peach handle
   * @param description description
   */
  int techila_peach_setDescription(int handle, LPSTR description);

  /**
   * Enable messages printing.
   * @param handle the peach handle
   * @param messages true or false
   */
  int techila_peach_setMessages(int handle, unsigned char messages);

  /**
   * Set the project priority as integer, valid values
   * 1 (highest) - 7 (lowest).
   * @param handle the peach handle
   * @param priority
   */
  int techila_peach_setPriorityI(int handle, int priority);

  /**
   * Set the project priority in string format. Valid values are
   * "HIGHEST", "HIGH", "ABOVE_NORMAL", "NORMAL", "BELOW_NORMAL"
   * "LOW" ans "LOWEST".
   * @param handle the peach handle
   * @param priority Priority string
   */
  int techila_peach_setPriority(int handle, LPSTR priority);

  /**
   * Set project ID. Use for attaching to a previously created project.
   * @param handle the peach handle
   * @param projectid
   */
  int techila_peach_setProjectId(int handle, int projectid);

  /**
   * Set Result file. Use to process a previously downloaded result file.
   * @param handle the peach handle
   * @param resultfile the downloaded result file
   */
  int techila_peach_setResultFile(int handle, LPSTR resultfile);

  /**
   * Set number of jobs to be created.
   * @param handle the peach handle
   * @param jobs
   */
  int techila_peach_setJobs(int handle, int jobs);

  /**
   * Allow partial results in download. Ignored when streaming is enabled.
   * @param handle the peach handle
   * @param allowPartial
   */
  int techila_peach_setAllowPartial(int handle, unsigned char allowPartial);

  /**
   * Remove project after it is done (done within done()). Default true.
   * @see done()
   * @param handle the peach handle
   * @param remove
   */
  int techila_peach_setRemove(int handle, unsigned char remove);

  /**
   * Cleanup handle temporary files at done(). Default true.
   * @param handle the peach handle
   * @param cleanup
   */
  int techila_peach_setCleanup(int handle, unsigned char cleanup);

  /**
   * Close the handle at done(). Default true.
   * @param handle the peach handle
   * @param close
   */
  int techila_peach_setClose(int handle, unsigned char close);

  /**
   * Add a source file.
   * @param handle the peach handle
   * @param file source filename
   */
  int techila_peach_addSourceFile(int handle, LPSTR file);

  /**
   * Check if the source files have changed compared to saved state.
   * @param handle the peach handle
   * @return true if sources have changed
   */
  int techila_peach_sourcesChanged(int handle);

  /**
   * Store source extra parameters. Use for example compiler version,
   * 32/64 -bits, etc...
   * @param handle the peach handle
   * @param name name of the parameter
   * @param value vale of the parameter
   */
  int techila_peach_putSourceExtras(int handle, LPSTR name,  LPSTR value);

  /**
   * Use a precreated executor bundle.
   * @param handle the peach handle
   * @param name name of the bundle
   */
  int techila_peach_setExeBundleName(int handle, LPSTR name);

  /**
   * Set the executable. This can be used the executable is not within the
   * executor bundle but already exists on the worker. E.g. %L(resource) can
   * be used here or a reference to a preinstalled binary, or %A(feature)
   * to use a feature configured for the worker.
   * @param handle the peach handle
   * @param executable
   */
  int techila_peach_setExecutable(int handle, LPSTR executable);

  /**
   * Set the skip digest bit for the executor bundle.
   * @param handle the peach handle
   * @param skipDigest
   */
  int techila_peach_setExeSkipDigest(int handle, unsigned char skipDigest);

  /**
   * Add a file into the Executor bundle with given parameters. Use
   * "exe" as resource name for the actual executable to be run, for
   * other files the resource can be anything.
   * @param handle the peach handle
   * @param res resource name
   * @param file the file name (with path)
   * @param osname osname
   * @param processor processor architechture
   */
  int techila_peach_addExeFile(int handle, LPSTR res, LPSTR file, LPSTR osname, LPSTR processor);

  /**
   * Put a value into the Executor bundles extra parameters.
   * @param handle the peach handle
   * @param name
   * @param value
   */
  int techila_peach_putExeExtras(int handle, LPSTR name, LPSTR value);

  /**
   * Add an import for the Executor bundle.
   * @param handle the peach handle
   * @param importName
   */
  int techila_peach_addExeImport(int handle, LPSTR importName);

  /**
   * Add an outpuf file definition, eg. "output;file=outputfile.dat".
   * If no output files are defined the default
   * "output;file=techila_peach_outputfile.dat" is used.
   * @param handle the peach handle
   * @param def
   */
  int techila_peach_addOutputFile(int handle, LPSTR def);

  /**
   * Start defining a new data bundle. This must be called first before
   * any other data bundle related commands.
   * @param handle the peach handle
   */
  int techila_peach_newDataBundle(int handle);

  /**
   * Use a named databundle that already exists on the server... 
   * adding files to this has no effect. Bundles can be created with for
   * example bundle creater tool or createSignedBundle -function.
   * @param handle the peach handle
   * @param name
   */
  int techila_peach_newDataBundleWithName(int handle, LPSTR name);

  /**
   * Set the skip digest bit for current data bundle. Setting this to true
   * will skip generating digests of files added to the bundle. Only
   * affect files added after changing the bit.
   * @param handle the peach handle
   * @param skipDigest
   */
  int techila_peach_setDataSkipDigest(int handle, unsigned char skipDigest);

  /**
   * Add a file into the current data bundle.
   * @param handle the peach handle
   * @param file
   */
  int techila_peach_addDataFile(int handle, LPSTR file);

  /**
   * Add a file from a directory into the current data bundle.
   * @param handle the peach handle
   * @param dir the directory where the file is
   * @param file filename
   */
  int techila_peach_addDataFileWithDir(int handle, LPSTR dir,  LPSTR file);

  /**
   * Put a value into the current data bundles extra parameters.
   * @param handle the peach handle
   * @param name
   * @param value
   */
  int techila_peach_putDataExtras(int handle, LPSTR name,  LPSTR value);

  /**
   * Set the bundle files copy parameter. When true (1) (default) the files
   * in the data bundle are copied into the working directory (execution
   * directory). When false (0) the files are not copied and can be referenced
   * by using %L(peach_datafiles_X) where X is the index of the data bundle.
   * @param handle the peach handle
   * @param copy
   */
  int techila_peach_setDataCopy(int handle, unsigned char copy);

  /**
   * Set the skip digest bit for job input bundle.
   * @param handle the peach handle
   * @param skipDigest skip (0 or 1)
   */
  int techila_peach_setJobSkipDigest(int handle, unsigned char skipDigest);

  /**
   * Set job input file names. This will clear all previously
   * added / set names.
   * @param handle the peach handle
   * @param paramcount number of file names to add
   * @param ...
   */
  int techila_peach_setJobFileNames(int handle, int paramcount, ...);
  int techila_peach_setJobFileNames3(int handle, int paramcount, char** params);

  /**
   * Add files to be included in the Job Input Bundle.
   * @param handle the peach handle
   * @param paramcount number of files to add
   * @param ... The names of the files
   */
  int techila_peach_addJobFile(int handle, int paramcount, ...);
  int techila_peach_addJobFile3(int handle, int paramcount, char** params);

  /**
   * Add files from a directory to be included in the Job Input Bundle.
   * @param handle the peach handle
   * @param dir The directory where the file is
   * @param paramcount number of files
   * @param ... The names of the files
   */
  int techila_peach_addJobFileWithDir(int handle, LPSTR dir,  int paramcount, ...);
  int techila_peach_addJobFileWithDir3(int handle, LPSTR dir,  int paramcount, char** params);

  /**
   * Put a value into the Job Input Bundle extra parameters.
   * @param handle the peach handle
   * @param name
   * @param value
   */
  int techila_peach_putJobExtras(int handle, LPSTR name,  LPSTR value);

  /**
   * Set the Parameter bundle skip digest bit.
   * @param handle the peach handle
   * @param skipDigest (0 or 1)
   */
  int techila_peach_setParamSkipDigest(int handle, unsigned char skipDigest);

  /**
   * Add a file into the parameter bundle.
   * @param handle the peach handle
   * @param file The file
   */
  int techila_peach_addParamFile(int handle, LPSTR file);

  /**
   * Add file into parameter bundle from a given directory.
   * @param handle the peach handle
   * @param dir
   * @param file
   */
  int techila_peach_addParamFileWithDir(int handle, LPSTR dir,  LPSTR file);

  /**
   * Add a file into the parameter bundle and specify target name.
   * @param handle the peach handle
   * @param file the file
   * @param targetName target file name in the bundle
   */
  int techila_peach_addParamFileWithTarget(int handle, LPSTR file,  LPSTR targetName);

  /**
   * Put a value into the parameter bundles extra parameters.
   * @param handle the peach handle
   * @param name
   * @param value
   */
  int techila_peach_putParamExtras(int handle, LPSTR name,  LPSTR value);

  /**
   * Add External Resource to Parameter Bundle.
   * @param handle the peach handle
   * @param res
   */
  int techila_peach_addParamExternalResource(int handle, LPSTR res);

  /**
   * Set the parameter bundle copy parameters.
   * @param handle the peach handle
   * @see setDataCopy(unsigned char)
   * @param copy 0 or 1
   */
  int techila_peach_setParamCopy(int handle, unsigned char copy);

  /**
   * Set a project parameter to a given value.
   * @param handle the peach handle
   * @param name parameter name
   * @param value parameter value
   */
  int techila_peach_putProjectParam(int handle, LPSTR name, LPSTR value);

  /**
   * Set streaming mode.
   * @param handle the peach handle
   * @param stream 0 or 1
   */
  int techila_peach_setStream(int handle, unsigned char stream);


  void* (*techila_peach_intermediate_callback_fun)(const char*) = NULL;

  int techila_peach_setIntermediateResultHandler(int handle, void* (*handler)(const char*));

  /**
   * Get the handle used for project commands.
   * @param handle the peach handle
   * @return the project handle
   */
  int techila_peach_getProjectHandle(int handle);

  /**
   * Get the project ID of the current project.
   * @param handle the peach handle
   * @return the project id or -1 if not yet set.
   */
  int techila_peach_getProjectId(int handle);

  /**
   * Run the Peach. This will create all bundles if necessary and then
   * create and start the project.
   * @param handle the peach handle
   * @return status code
   */
  int techila_peach_execute(int handle);

  /**
   * Get the result file. This will return 0 in len parameter if no
   * more files are available, i.e. the project is done or failed.
   * @param handle the peach handle
   * @param filename returned buffer for result filename
   * @param len returned length of filename, 0 if no more files available
   * @return status code
   */
  int techila_peach_nextFile(int handle, LPSTR filename, size_t *len);

  /**
   */
  int techila_peach_postProcessed(int handle, int post);

  /**
   * Mark Peach call as done. Remove and cleanup leftovers.
   * This must be called always.
   * @param handle the peach handle
   */
  int techila_peach_done(int handle);


#ifdef TECHILA_DEFINE_OLD_NAMES
// define old names to point to new names

#define actionWait techila_actionWait
#define addUserClientsToProject techila_addUserClientsToProject
#define approveUploadedBundles techila_approveUploadedBundles
#define bundleExists techila_bundleExists
#define bundleVersionExists techila_bundleVersionExists
#define bundleWithPrefixExists techila_bundleWithPrefixExists
#define cleanup techila_cleanup
#define techilaclose techila_close
#define createBundle techila_createBundle
#define createEmptyProject techila_createEmptyProject
#define createCachedJob techila_createCachedJob
#define createJob techila_createJob
#define createProject techila_createProject
#define createProjectJobs techila_createProjectJobs
#define createSignedBundle techila_createSignedBundle
#define describeStatusCode techila_describeStatusCode
#define downloadResult techila_downloadResult
#define downloadPartialResult techila_downloadPartialResult
#define flushCachedJobs techila_flushCachedJobs
#define getBundleId techila_getBundleId
#define getLastCreatedBundleName techila_getLastCreatedBundleName
#define getLastError techila_getLastError
#define getLastErrorMessage techila_getLastErrorMessage
#define getProjectDescription techila_getProjectDescription
#define getProjectId techila_getProjectId
#define getProjectParamCount techila_getProjectParamCount
#define getProjectParamName techila_getProjectParamName
#define getProjectParamValue techila_getProjectParamValue
#define getProjectStatistic techila_getProjectStatistic
#define getProjectStatus techila_getProjectStatus
#define getResultDirectory techila_getResultDirectory
#define getResultFile techila_getResultFile
#define getResultFiles techila_getResultFiles
#define getStreamedResultFiles techila_getStreamedResultFiles
#define getStreamedResultFilesCount techila_getStreamedResultFilesCount
#define getUsedCpuTime techila_getUsedCpuTime
#define getUsedTime techila_getUsedTime
#define getUserLogin techila_getUserLogin
#define init techila_init
#define initFile techila_initFile
#define initFileWithPassword techila_initFileWithPassword
#define initJava techila_initJava
#define initWithoutFile techila_initWithoutFile
#define isCompleted techila_isCompleted
#define isFailed techila_isFailed
#define isJobCompleted techila_isJobCompleted
#define markAllJobsCreated techila_markAllJobsCreated
#define techilaopen techila_open
#define peach techila_peach
#define peachDone techila_peachDone
#define peachNextFile techila_peachNextFile
#define ready techila_ready
#define removeProject techila_removeProject
#define setBundleId techila_setBundleId
#define setDownloadDir techila_setDownloadDir
#define setLogLevel techila_setLogLevel
#define setProjectId techila_setProjectId
#define setProjectParams techila_setProjectParams
#define setStreamResults techila_setStreamResults
#define setUnzipDir techila_setUnzipDir
#define signJar techila_signJar
#define startProject techila_startProject
#define stopProject techila_stopProject
#define stopWaitingBG techila_stopWaitingBG
#define unload techila_unload
#define unzip techila_unzip
#define unzipFile techila_unzipFile
#define uploadBundle techila_uploadBundle
#define uploadBundleWithName techila_uploadBundleWithName
#define useBundle techila_useBundle
#define useBundleWithPrefix techila_useBundleWithPrefix
#define waitCompletion techila_waitCompletion
#define waitCompletionBG techila_waitCompletionBG
#define createSignedBundle3 techila_createSignedBundle3
#define createProjectJobs3 techila_createProjectJobs3
#define createProject3 techila_createProject3
#define createCachedJob3 techila_createCachedJob3
#define createJob3 techila_createJob3
#define createBundle3 techila_createBundle3
#define setProjectParams3 techila_setProjectParams3
#define peach3 techila_peach3
#define getPlugin techila_getPlugin
#define getPluginClass techila_getPluginClass
#define getPluginConf techila_getPluginConf
#define getJNIEnv techila_getJNIEnv
#define getJavaVM techila_getJavaVM

#define peach_handle techila_peach_handle
#define unload2 techila_unload2
#define getTempDir techila_getTempDir
#define getJavaSystemProperty techila_getJavaSystemProperty
#define peach_handle techila_peach_handle
#define peach_setName techila_peach_setName
#define peach_setStateDir techila_peach_setStateDir
#define peach_setDescription techila_peach_setDescription
#define peach_setMessages techila_peach_setMessages
#define peach_setPriorityI techila_peach_setPriorityI
#define peach_setPriority techila_peach_setPriority
#define peach_setProjectId techila_peach_setProjectId
#define peach_setJobs techila_peach_setJobs
#define peach_setAllowPartial techila_peach_setAllowPartial
#define peach_setRemove techila_peach_setRemove
#define peach_setCleanup techila_peach_setCleanup
#define peach_setClose techila_peach_setClose
#define peach_addSourceFile techila_peach_addSourceFile
#define peach_sourcesChanged techila_peach_sourcesChanged
#define peach_putSourceExtras techila_peach_putSourceExtras
#define peach_setExeBundleName techila_peach_setExeBundleName
#define peach_setExecutable techila_peach_setExecutable
#define peach_setExeSkipDigest techila_peach_setExeSkipDigest
#define peach_addExeFile techila_peach_addExeFile
#define peach_putExeExtras techila_peach_putExeExtras
#define peach_addExeImport techila_peach_addExeImport
#define peach_addOutputFile techila_peach_addOutputFile
#define peach_newDataBundle techila_peach_newDataBundle
#define peach_newDataBundleWithName techila_peach_newDataBundleWithName
#define peach_setDataSkipDigest techila_peach_setDataSkipDigest
#define peach_addDataFile techila_peach_addDataFile
#define peach_addDataFileWithDir techila_peach_addDataFileWithDir
#define peach_putDataExtras techila_peach_putDataExtras
#define peach_setDataCopy techila_peach_setDataCopy
#define peach_setJobSkipDigest techila_peach_setJobSkipDigest
#define peach_setJobFileNames techila_peach_setJobFileNames
#define peach_setJobFileNames3 techila_peach_setJobFileNames3
#define peach_addJobFile techila_peach_addJobFile
#define peach_addJobFile3 techila_peach_addJobFile3
#define peach_addJobFileWithDir techila_peach_addJobFileWithDir
#define peach_addJobFileWithDir3 techila_peach_addJobFileWithDir3
#define peach_putJobExtras techila_peach_putJobExtras
#define peach_setParamSkipDigest techila_peach_setParamSkipDigest
#define peach_addParamFile techila_peach_addParamFile
#define peach_addParamFileWithDir techila_peach_addParamFileWithDir
#define peach_addParamFileWithTarget techila_peach_addParamFileWithTarget
#define peach_putParamExtras techila_peach_putParamExtras
#define peach_addParamExternalResource techila_peach_addParamExternalResource
#define peach_setParamCopy techila_peach_setParamCopy
#define peach_putProjectParam techila_peach_putProjectParam
#define peach_setStream techila_peach_setStream
#define peach_getProjectHandle techila_peach_getProjectHandle
#define peach_getProjectId techila_peach_getProjectId
#define peach_execute techila_peach_execute
#define peach_nextFile techila_peach_nextFile
#define peach_done techila_peach_done

#endif

#ifdef __cplusplus
}
#endif

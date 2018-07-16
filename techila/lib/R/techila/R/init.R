# Copyright (C) 2010-2015 Techila Technologies Ltd.

.heap <- new.env()
.heap$initialized <- FALSE
.heap$lib <- NULL

init <- function(sdkroot = NULL,
                 initFile = NULL,
                 password = NULL,
                 javaParameters = NULL,
                 ignoreServerErrors = FALSE) {
  #print("init called")
  if (!.heap$initialized) {

    #print("init")

    if (is.null(sdkroot)) {
      env_root <- Sys.getenv("TECHILA_SDKROOT")
      if (is.null(env_root)) {
        # backwards compatibility, deprecated
        env_root <- Sys.getenv("TECHILA_GMKROOT")
      }
      if (!is.null(env_root) && env_root != "") {
        sdkroot <- env_root
      } else {
        sdkroot <- getOption("techila.sdkroot")
      }
    }

    jarFile = paste(sdkroot, "/lib/techila.jar", sep="")

    if (!file.exists(jarFile)) {
      stop(paste(jarFile, " not found, set TECHILA_SDKROOT environment variable", sep=""))
    }

    if (is.null(javaParameters)) {
      opts <- getOption("java.parameters")
      if (!is.null(opts)) {
        javaParameters <- opts
      } else {
        javaParameters <- list("-Xms32m", "-Xmx128m")
      }
    }

    .jinit(parameters=javaParameters)

    .jaddClassPath(jarFile)

    .heap$ok<-.jfield("fi/techila/user/Support",,"OK")
    connfailed<-.jfield("fi/techila/user/Support",,"CONNECTION_FAILED")
    unknownhost<-.jfield("fi/techila/user/Support",,"UNKNOWN_HOST")
    accessfailed<-.jfield("fi/techila/user/Support",,"INIT_ACCESS_FAILED")

    lib <- .jcall("fi/techila/user/TechilaManagerFactory","Lfi/techila/user/TechilaManager;", "getTechilaManager")

    .heap$support <- .jcall(lib, "Lfi/techila/user/Support;", "support")

    if (is.null(initFile)) {
      initFile <- .jnull("java/lang/String")
    }
    if (is.null(password)) {
      password <- .jnull("java/lang/String")
    }

    sc <- .jcall(lib, "I", "initFile", initFile, password)

    if (sc != .heap$ok) {
      if (!ignoreServerErrors || (sc != connfailed && sc != unknownhost && sc != accessfailed)) {
      msg <- .jcall(.heap$support, "S", "describeStatusCode", sc);
      stop(paste("Init failed: ", msg, " (", sc, ")", sep=""))
    }
    }

    .heap$lib <- lib

    .heap$bm <- .jcall(lib, "Lfi/techila/user/BundleManager;", "bundleManager")
    .heap$pm <- .jcall(lib, "Lfi/techila/user/ProjectManager;", "projectManager")

    .heap$initialized <- TRUE
  }
}

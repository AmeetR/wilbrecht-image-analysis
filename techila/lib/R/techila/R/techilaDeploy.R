techilaDeploy <- function(funcname = NULL,
                  files = NULL,
                  description = NULL,
                  datafiles = NULL,
                  messages = TRUE,
                  sdkroot = NULL,
                  gmkroot = NULL,
                  filehandler = NULL,
                  initFile = NULL,
                  password = NULL,
                  ProjectParameters = NULL,
                  BundleParameters = NULL,
                  BinaryBundleParameters = NULL,
                  close = TRUE,
                  imports = NULL,
                  databundles = NULL,
                  outputfiles = NULL,
                  snapshot = FALSE,
                  snapshotfiles = "snapshot.rda",
                  snapshotinterval = 15,
                  RVersion = NULL,
                  runAsR = NULL,
                  packages = NULL,
				  deployName = NULL,
				  deployVersion = NULL
                  ) {

  if (is.null(funcname)) {
    stop("funcname must be defined")
  }

  # Init
  if (!.heap$initialized) {
    init(sdkroot=sdkroot, initFile=initFile, password=password)
  }

  inputdataname <- NULL
  localfiles <- NULL

  inputdataname <- paste("techila_peach_inputdata_", as.numeric(Sys.time()), "_", trunc(runif(1,0,10000)), sep="")

  if (!is.null(files) && length(files) > 0) {
    localfiles <- vector("list", length(files))
    for(i in 1:length(files)) {
      f <- files[[i]]
      files[[i]] <- basename(f)
      localfiles[[i]] <- f
    }
  }

  libraries <- packages;

  techila_funcname <- funcname
  techila_params <- NULL
  techila_peachvector <- NULL
  techila_files <- files
  techila_maxidx <- 1
  techila_steps <- 1
  techila_libraries <- libraries

  base::save(techila_funcname, techila_params, techila_files, techila_peachvector, techila_maxidx, techila_steps, techila_libraries, file=inputdataname);

  lib <- .heap$lib

  # Peach

  if (is.function(funcname)) {
    funcname <- "function"
  }

  peach <- .jcall(lib, "Lfi/techila/user/Peach;", "newPeach", funcname)

  if (!is.null(deployName)) {
    if (is.null(deployVersion)) {
	  deployVersion <- "0.0.1"
	}
	techilaBundles <- .jcall(lib, "Lfi/techila/user/BundleManager;", "bundleManager")
	if (.jcall(techilaBundles, "Z", "bundleVersionExists", deployName, deployVersion)) {
	   stop(paste('Bundle "', deployName, '" already exists.', sep=''))
	}
  }
  
  # sets
  .jcall(peach, "V", "setMessages", messages)
  .jcall(peach, "V", "setClose", close)

  executesc = .heap$ok

  # sets

  # Data bundles
  if (!is.null(databundles) && length(databundles) > 0) {
    for(i in 1:length(databundles)) {
      databundle <- databundles[[i]]
      datadir <- "."
 
      if (!is.null(databundle$datadir)) {
        datadir <- databundle$datadir
      }
      .jcall(peach, "V", "newDataBundle");

      if (length(databundle$datafiles) > 0) {
        for(j in 1:length(databundle$datafiles)) {
          .jcall(peach, "V", "addDataFileWithDir", datadir, databundle$datafiles[[j]])
        }
      }

      dbparamnames <- names(databundle$parameters)
      if (length(dbparamnames) > 0) {
        for (j in 1:length(dbparamnames)) {
          .jcall(peach, "V", "putDataExtras", dbparamnames[[j]], databundle$parameters[[j]])
        }
      }
	  .jcall(peach, "V", "putDataExtras", "Bundle-Category", "TechilaPE-{user}")

      if (!is.null(databundle$libraryfiles) && databundle$libraryfiles) {
        .jcall(peach, "V", "setDataCopy", FALSE)
      }
    }
  }

  # Parameter Bundle

  .jcall(peach, "V", "addParamFile", inputdataname, "techila_peach_inputdata")
  .jcall(peach, "V", "putParamExtras", "Bundle-Category", "TechilaPE-{user}")
  .jcall(peach, "V", "setParamResource", "techila_peach_inputdata_1")
  if (!is.null(deployName)) {
    .jcall(peach, "V", "setParamBundleName", deployName)
	.jcall(peach, "V", "setExeBundleName", deployName)
    if (!is.null(deployVersion)) {
     .jcall(peach, "V", "setParamBundleVersion", deployVersion)
    }
  }

  if (!is.null(datafiles) && length(datafiles) > 0) {
    for(i in 1:length(datafiles)) {
      .jcall(peach, "V", "addParamFile", datafiles[[i]])
    }
  }

  if (!is.null(BundleParameters) && length(BundleParameters) > 0) {
    bpnames <- names(BundleParameters)
    if (length(bpnames) > 0) {
      for(i in 1:length(bpnames)) {
        .jcall(peach, "V", "putParamExtras", bpnames[[i]], BundleParameters[[i]])
      }
    }
  }
  
    # Executor <- wrapped into Parameter Bundle

  if (!is.null(localfiles) && length(localfiles) > 0) {
    for(i in 1:length(localfiles)) {
      resname <- files[[i]]
      .jcall(peach, "V", "addParamFileWithDir", dirname(localfiles[[i]]), basename(localfiles[[i]]))
    }
  }
  .jcall(peach, "V", "addParamFileWithDir", system.file("", package="techila"), "peachclient.r")


  paramoutputfiles <- "peachoutput;file=techila_peach_result.dat"

  if (!is.null(outputfiles) && length(outputfiles) > 0) {
    for (i in 1:length(outputfiles)) {
	  paramoutputfiles <- paste(paramoutputfiles, ",output", i, ";file=", outputfiles[[i]], sep="");
    }
  }

  .jcall(peach, "V", "putParamExtras", "OutputFiles", paramoutputfiles)

  
  if (!is.null(runAsR) && runAsR == TRUE) {
    .jcall(peach, "V", "putParamExtras", "Executable", "%A(r)")
    .jcall(peach, "V", "putProjectParam", "techila_worker_features", "(r=*)")

  } else {
    .jcall(peach, "V", "putParamExtras", "Executable", "%L(r)")

    if (is.null(RVersion)) {
      env_ver <- Sys.getenv("TECHILA_R_VERSION")

      if (!is.null(env_ver) && env_ver != "") {
        rver <- env_ver
      } else {
        rver <- gsub("[.]", "", paste(R.Version()$major,R.Version()$minor, sep=""))
      }
    } else {
      rver <- RVersion
    }
    rimport <- paste("fi.techila.grid.cust.common.library.gnur.v", rver, ".client", sep="")

    .jcall(peach, "V", "addParamImport", rimport)

    .jcall(peach, "V", "addParamExternalResource",  "rdir;resource=r;file=r,r;resource=r;file=r/bin/i386/Rterm.exe;osname=Windows;processor=x86,r;resource=r;file=r/bin/x64/Rterm.exe;osname=Windows;processor=amd64,r;resource=r;file=r/bin/exec/R;osname=Linux,r;resource=r;file=r/bin/exec/x86_64/R;osname=Mac OS X")

  }
  importnames <- list()
  for (package in packages) {
    if (!package %in% importnames) {
      imports <- c(imports, bundleit(package, sdkroot=conf$sdkroot, initFile=conf$initFile))
      importnames <- c(importnames, package)
      deps <- getLibDeps(package, list())
      for (dep in deps) {
        if (!dep %in% importnames) {
          imports <- c(imports, bundleit(dep, sdkroot=conf$sdkroot, initFile=conf$initFile))
          importnames <- c(importnames, dep)
        }
      }
    }
  }

  if (!is.null(imports) && length(imports) > 0) {
    for (i in 1:length(imports)) {
      .jcall(peach, "V", "addParamImport", imports[[i]])
    }
  }

  .jcall(peach, "V", "putParamExtras", "Executor", ".")
  .jcall(peach, "V", "putParamExtras", "Parameters", "-f peachclient.r --no-save --args %P(jobidx) %O(peachoutput)")
  .jcall(peach, "V", "putParamExtras", "Environment", "R_LIBS;value=\"%C(r_libs,PGET)\";appendDefault=true")

  if (snapshot) {
    .jcall(peach, "V", "putParamExtras", "SnapshotFiles", snapshotfiles)
    .jcall(peach, "V", "putParamExtras", "SnapshotInterval", as.character(snapshotinterval))
  }

  if (!is.null(BinaryBundleParameters) && length(BinaryBundleParameters) > 0) {
    bbpnames <- names(BinaryBundleParameters)
    if (length(bbpnames) > 0) {
      for(i in 1:length(bbpnames)) {
        .jcall(peach, "V", "putParamExtras", bbpnames[[i]], BinaryBundleParameters[[i]])
        }
      }
        }


  if (!is.null(description)) {
     .jcall(peach, "V", "setDescription", description)
  }

  if (!is.null(ProjectParameters) && length(ProjectParameters) > 0) {
    ppnames <- names(ProjectParameters)
    if (length(ppnames) > 0) {
      for(i in 1:length(ppnames)) {
        .jcall(peach, "V", "putProjectParam", ppnames[[i]], ProjectParameters[[i]])
      }
    }
  }

  executesc <- .jcall(peach, "I", "execute")

  unlink(inputdataname)
  
  if (executesc == .heap$ok) {
    deployName <- .jcall(peach, "Ljava/lang/String;", "getParamBundleName")
  }

  .jcall(peach, "V", "setMessages", FALSE)
  .jcall(peach, "V", "done");

  unload(TRUE, TRUE)

  if (executesc != .heap$ok) {
    msg <- .jcall(.heap$support, "S", "describeStatusCode", executesc);
    stop(paste("Deploy execute failed: ", msg, " (", executesc, ")", sep=""))
  }

  deployName
}
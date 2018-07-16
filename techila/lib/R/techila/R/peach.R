# Copyright (C) 2010-2017 Techila Technologies Ltd.

peach <- function(funcname = NULL,
                  params = NULL,
                  files = NULL,
                  peachvector = NULL,
                  jobs = NULL,
                  description = NULL,
                  datafiles = NULL,
                  messages = TRUE,
                  priority = 4,
                  sdkroot = NULL,
                  gmkroot = NULL,
                  stream = FALSE,
                  callback = NULL,
                  filehandler = NULL,
                  initFile = NULL,
                  password = NULL,
                  ProjectParameters = NULL,
                  BundleParameters = NULL,
                  BinaryBundleParameters = NULL,
                  donotwait = FALSE,
                  donotuninit = FALSE,
                  removeproject = FALSE,
                  close = TRUE,
                  imports = NULL,
                  databundles = NULL,
                  jobinputfiles = NULL,
                  outputfiles = NULL,
                  snapshot = FALSE,
                  snapshotfiles = "snapshot.rda",
                  snapshotinterval = 15,
                  RVersion = NULL,
                  runAsR = NULL,
                  projectid = -1,
                  steps = 1,
                  packages = NULL,
                  intermediate_callback = NULL
                  ) {

  if (donotwait) {
    removeproject <- FALSE
  }

  if (is.null(funcname) && projectid == -1) {
    stop("funcname or projectid must be defined")
  }

  # Init

  douninit <- FALSE

  if (!.heap$initialized) {
    douninit <- TRUE

    init(sdkroot=sdkroot, initFile=initFile, password=password)
  }

  if (donotuninit) {
    douninit <- FALSE
  }

  inputdataname <- NULL
  localfiles <- NULL

  if (projectid == -1) {
    if (!is.null(peachvector)) {
      maxidx <- length(peachvector)
    } else {
      maxidx <- jobs
    }

    # skip this if project id is set

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
    techila_params <- params
    techila_files <- files
    techila_peachvector <- peachvector
    techila_maxidx <- maxidx
    techila_steps <- steps
    techila_libraries <- libraries

    base::save(techila_funcname, techila_params, techila_files, techila_peachvector, techila_maxidx, techila_steps, techila_libraries, file=inputdataname);

  }

  lib <- .heap$lib

  # Peach

  if (is.null(funcname)) {
    funcname <- .jnull("java/lang/String")
  }

  if (is.function(funcname)) {
    funcname <- "function"
  }

  peach <- .jcall(lib, "Lfi/techila/user/Peach;", "newPeach", funcname)

  # sets
  .jcall(peach, "V", "setMessages", messages)
  .jcall(peach, "V", "setStream", stream)
  .jcall(peach, "V", "setRemove", removeproject)
  .jcall(peach, "V", "setClose", close)

  executesc = .heap$ok
  if (projectid > 0) {
    .jcall(peach, "V", "setProjectId", as.integer(projectid))
  } else {

    # sets

    if (is.numeric(priority)) {
      .jcall(peach, "V", "setPriority", as.integer(priority))
    } else {
      .jcall(peach, "V", "setPriority", priority)
    }

    # Executor

    if (!is.null(localfiles) && length(localfiles) > 0) {
      for(i in 1:length(localfiles)) {
        resname <- files[[i]]
        .jcall(peach, "V", "addExeFile", resname, localfiles[[i]])
      }
    }
    .jcall(peach, "V", "addExeFile", "peachclient.r", system.file("peachclient.r", package="techila"))

    .jcall(peach, "V", "addOutputFile", "peachoutput;file=techila_peach_result.dat")

    if (!is.null(outputfiles) && length(outputfiles) > 0) {
      for (i in 1:length(outputfiles)) {
        .jcall(peach, "V", "addOutputFile", paste("output", i, ";file=", outputfiles[[i]], sep=""))
      }
    }

    if (!is.null(runAsR) && runAsR == TRUE) {
      .jcall(peach, "V", "setExecutable", "%A(r)")
      .jcall(peach, "V", "putProjectParam", "techila_worker_features", "(r=*)")

    } else {
      .jcall(peach, "V", "setExecutable", "%L(r)")

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

      .jcall(peach, "V", "addExeImport", rimport)

      .jcall(peach, "V", "putExeExtras", "ExternalResources", "rdir;resource=r;file=r,r;resource=r;file=r/bin/i386/Rterm.exe;osname=Windows;processor=x86,r;resource=r;file=r/bin/x64/Rterm.exe;osname=Windows;processor=amd64,r;resource=r;file=r/bin/exec/R;osname=Linux,r;resource=r;file=r/bin/exec/x86_64/R;osname=Mac OS X")

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
        .jcall(peach, "V", "addExeImport", imports[[i]])
      }
    }

    .jcall(peach, "V", "putExeExtras", "Parameters", "-f %I(peachclient.r) --no-save --args %P(jobidx) %O(peachoutput)")
    .jcall(peach, "V", "putExeExtras", "Environment", "R_LIBS;value=\"%C(r_libs,PGET)\";appendDefault=true")

    if (snapshot) {
      .jcall(peach, "V", "putExeExtras", "SnapshotFiles", snapshotfiles)
      .jcall(peach, "V", "putExeExtras", "SnapshotInterval", as.character(snapshotinterval))
    }

    if (!is.null(BinaryBundleParameters) && length(BinaryBundleParameters) > 0) {
      bbpnames <- names(BinaryBundleParameters)
      if (length(bbpnames) > 0) {
        for(i in 1:length(bbpnames)) {
          .jcall(peach, "V", "putExeExtras", bbpnames[[i]], BinaryBundleParameters[[i]])
        }
      }
    }

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

        if (!is.null(databundle$libraryfiles) && databundle$libraryfiles) {
          .jcall(peach, "V", "setDataCopy", FALSE)
        }
      }
    }

    # Job input bundle
    if (!is.null(jobinputfiles) && !is.null(jobinputfiles$datafiles)) {
      if (length(jobinputfiles$datafiles) > 0) {
        for (i in 1:length(jobinputfiles$datafiles)) {

          datadir <- "."
          if (!is.null(jobinputfiles$datadir)) {
            datadir <- jobinputfiles$datadir
          }

          if (is.list(jobinputfiles$datafiles[[i]])) {
            arr <- .jarray(as.character(jobinputfiles$datafiles[[i]]), "[S")
          } else {
            arr <- .jarray(jobinputfiles$datafiles[[i]], "[S")
          }
          .jcall(peach, "V", "addJobFileWithDir", datadir, arr)
        }
      }

      if (!is.null(jobinputfiles$filenames) && length(jobinputfiles$filenames) > 0) {
        arr <- .jarray(as.character(jobinputfiles$filenames), "[S")
        .jcall(peach, "V", "setJobFileNames", arr)
      }

      jiparamnames <- names(jobinputfiles$parameters)
      if (length(jiparamnames) > 0) {
        for (j in 1:length(jiparamnames)) {
          .jcall(peach, "V", "putJobExtras", jiparamnames[[j]], jobinputfiles$parameters[[j]])
        }
      }
    }

    # Parameter Bundle

    .jcall(peach, "V", "addParamFile", inputdataname, "techila_peach_inputdata")

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


    # Project
    if (!is.null(peachvector)) {
      jobs <- as.integer(ceiling(length(peachvector) / steps))
    } else {
      jobs <- as.integer(ceiling(jobs / steps))
    }

    #message("setJobs(", jobs, ")")
    .jcall(peach, "V", "setJobs", jobs)

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

  }

  results <- NULL
  if (executesc == .heap$ok) {

    projecthandle <- .jcall(peach, "I", "getProjectHandle");

    if (donotwait) {
      # return project handle,
      # if the handle is closed, return projectid instead
      results <- projecthandle
    } else {

      # setup intermediate callback
      if (!is.null(intermediate_callback)) {
        #cat("setting intermediate callback\n")

        func <- function() {
          #print(techila_im_callback_filename)

          base::load(techila_im_callback_filename)

          tryCatch({
            intermediate_callback(techila_im_data)
          })
        }

        tryCatch({
          # start JRI
          .jengine(TRUE)

          # create a ref of the local function...
          funcref <- toJava(func)
          rirh <- .jnew("RIntermediateResultHandler")

          # and register it to be called as callback
          .jcall(rirh,, "register", funcref)

          # set peach to use callback
          irh <- .jcast(rirh, "fi/techila/user/IntermediateResultHandler")
          .jcall(peach,, "setIntermediateResultHandler", irh)
        }, error = function(e) {
          print(e)
        })

      }

      # Results
      results <- NULL

      tmpdir <- .jcall(lib, "S", "getTempDir")
      rnd <- floor(runif(1,0,65536))

      rpos <- 1
      while(!is.jnull(file <- .jcall(peach, "S", "nextFile"))) {

        zip <- FALSE
        filelist <- file
        unzipdir <- NULL

        if (!is.null(outputfiles) && length(outputfiles) > 0) {
          unzipdir <- paste(tmpdir, "/r_tmp_", rnd, "_", rpos, sep="")

          filelist <- unzip(file, exdir = unzipdir)
          zip <- TRUE
        }

        for (fp in 1:length(filelist)) {

          ufile <- filelist[[fp]]

          partialresults <- NULL
          pindex = 1
          firstindex <- 0

          if (!zip || regexpr("techila_peach_result.dat$", ufile) > 0) {
            #print(paste("loading", ufile))
            base::load(ufile)

            #print(pcresults)
            partialresults <- vector(typeof(techila_pcresults[[1]]$techila_result), length(techila_pcresults))

            for (pcresult in techila_pcresults) {
              #print(pcresult)
              idx <- pcresult$techila_idx
              if (firstindex == 0) {
                  firstindex = idx
              }
              result <- pcresult$techila_result

              if (!is.null(callback)) {
                result <- do.call(callback, list(result))
              }

              if (is.list(result) || length(result) > 1 || is.null(result)) {
                result <- list(result)
              }
              #results[idx] <- result
              partialresults[pindex] <- result
              pindex <- pindex + 1
            }
            results[firstindex : (firstindex + length(partialresults) - 1)] <- partialresults
          } else {
            if (!is.null(filehandler)) {
              do.call(filehandler, list(ufile))
            }

          }

          if (zip && file.exists(ufile)) {
            unlink(ufile)
          }
        }

        if (zip && file.exists(unzipdir)) {
          unlink(unzipdir, recursive=TRUE)
        }

        rpos <- rpos + 1
      }
    }

    if (donotwait) {
      if (close) {
        results <- getProjectId(projecthandle)
      }
    } else {
      # print statistics
      if (messages) {
        if (projecthandle == -1) {
          projecthandle <- .jcall(peach, "I", "getProjectHandle");
        }
        pm <- .heap$pm
        str <- .jcall(pm, "S", "getStatisticsString", projecthandle)
        str <- as.character(str)
        cat(str)
      }
    }
  }

  # finish, don't print statistics in done
  .jcall(peach, "V", "setMessages", FALSE)
  .jcall(peach, "V", "done");

  if (douninit) {
    unload(TRUE, TRUE)
  }

  if (executesc != .heap$ok) {
    msg <- .jcall(.heap$support, "S", "describeStatusCode", executesc);
    stop(paste("Peach execute failed: ", msg, " (", executesc, ")", sep=""))
  }

  # reshape to original shape if dim available
  if (!is.null(peachvector)) {
    pvdim = dim(peachvector)
    pvdimnames = dimnames(peachvector)
    if (!is.null(results) && !is.null(pvdim)) {
      attr(results, "dim") <- pvdim

      if (!is.null(pvdimnames)) {
        attr(results, "dimnames") <- pvdimnames
      }
    }
  }

  results
}

getLibDeps <- function(lib, deps) {
  # http://stat.ethz.ch/R-manual/R-devel/doc/html/packages.html
  standardLibs = list(
    "base",
    "boot",
    "class",
    "cluster",
    "codetools",
    "compiler",
    "datasets",
    "foreign",
    "graphics",
    "grDevices",
    "grid",
    "KernSmooth",
    "lattice",
    "MASS",
    "Matrix",
    "methods",
    "mgcv",
    "nlme",
    "nnet",
    "parallel",
    "rpart",
    "spatial",
    "splines",
    "stats",
    "stats4",
    "survival",
    "tcltk",
    "tools",
    "utils")

  pimports<-names(getNamespaceImports(lib))
  for (name in pimports) {
    if (!name %in% deps && !name %in% standardLibs) {
      deps<-c(deps, name)
      deps<-getLibDeps(name, deps)
    }
  }
  deps
}

# Copyright (C) 2010-2012 Techila Technologies Ltd.

bundleit <- function(package,
                     sdkroot = NULL,
                     initFile = NULL,
                     version = NULL,
                     allPlatforms = FALSE,
                     expiration = "7 d",
                     bundlename = NULL) {

  if (is.null(bundlename)) {
    rver <- gsub("[.]", "", paste(R.Version()$major,R.Version()$minor, sep=""))

    if (is.null(version)) {
      version <- paste("v", gsub("[.]", "", packageVersion(package)), sep="")
    }

    bundlename <- paste("{user}.R.v",rver, ".package.", package, ".", version, sep="")
  }

  douninit <- FALSE
  if (!.heap$initialized) {
    douninit <- TRUE
    init(sdkroot, initFile)
  }
  bm <- .heap$bm
  r <- .jcall(bm, "Z", "bundleExists", bundlename)
  if (r) {
    lib <- .heap$lib
    login <- .jcall(lib, "S", "getUserLogin")
    if (douninit) {
      unload(TRUE, TRUE)
    }
    return(gsub("\\{user\\}", login, bundlename))
  }

  #print(bundlename)

  dir <- system.file(package=package)
  #print(dir)

  files <- dir(path = dir,
               all.files = TRUE,
               full.names = TRUE,
               recursive = TRUE)
  #print(files)

  bfiles<-substring(files, nchar(dir) - nchar(package) + 1, 10000000L)
  #print(bfiles)

  environment <- paste("IGNORE_093843485;value=\"%C(r_libs,%L(", bundlename, "),path.separator,PROPGET,|,r_libs,PGET,ISNULL,,r_libs,PGET,IF,|,PSET)\"", sep="")
  #print(environment)

  osname <- .jcall("java/lang/System", "S", "getProperty", "os.name")
  processor <- .jcall("java/lang/System", "S", "getProperty", "os.arch")

  OK <- FALSE
  natives <- ""
  if (!allPlatforms) {
    samplefile <- bfiles[1]
    if (pmatch("Windows", osname, FALSE)) {
      natives <- paste(samplefile, ";osname=WindowsXP;processor=", processor, ",",
                       samplefile, ";osname=Windows 2000;processor=", processor, ",",
                       samplefile, ";osname=Windows Vista;processor=", processor, ",",
                       samplefile, ";osname=Windows 7;processor=", processor, ",",
                       samplefile, ";osname=Windows Server 2008;processor=", processor, ",",
                       samplefile, ";osname=Windows Server 2008 R2;processor=", processor,
                       sep="")

      OK <- TRUE
    } else if (pmatch("Linux", osname, FALSE)) {
      natives <- paste(samplefile, ";osname=Linux;processor=", processor, sep="")
      OK <- TRUE
    } else {
      warning(paste("Unsupported OS: ", osname))
    }

  } else {
    OK <- TRUE
  }
  #print(osname)
  #print(processor)

  #print(natives)

  externalresources <- paste(bundlename, ";resource=", bundlename, sep="")
  #print(externalresources)

  ret <- NULL
  if (OK) {
    if (length(files) > 0) {
      filesht <- .jnew("java/util/Hashtable")
      for(i in 1:length(files)) {
        J(filesht, "put", bfiles[[i]], files[[i]])
      }
      #print(.jcall(hash, "S", "toString"))
    }

    extrasht <- .jnew("java/util/Hashtable")
    J(extrasht, "put", "ExternalResources", externalresources)
    J(extrasht, "put", "Environment", environment)
    J(extrasht, "put", "ExpirationPeriod", expiration)

    ret <- createSignedBundle(bundlename,
                              paste("bundled R package: ", package, sep=""),
                              "0.0.1",
                              bundlename,
                              bundlename,
                              natives,
                              "",
                              bundlename,
                              "",
                              extrasht,
                              filesht)
  }

  if (douninit) {
    unload(TRUE, TRUE)
  }

  ret
}

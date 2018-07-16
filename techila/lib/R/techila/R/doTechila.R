#
# Copyright (c) 2008-2009, REvolution Computing, Inc.
# Copyright (c) 2014-2016, Techila Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# this explicitly registers a Techila parallel backend
registerDoTechila <- function(...) {

  suppressPackageStartupMessages(library(iterators))
  suppressPackageStartupMessages(library(foreach))

  options <- list(...)
  setDoPar(doTechila, options, info)
}

# passed to setDoPar via registerDoTechila, and called by getDoParWorkers, etc
info <- function(data, item) {
  switch(item,
         workers = 0,
         name = 'doTechila',
         version = packageDescription('doTechila', fields='Version'),
         NULL)
}

doTechila <- function(obj, expr, envir, data) {
  # set the default peach options
  messages <- TRUE
  steps <- 1
  packages <- NULL
  imports <- NULL
  sdkroot <- NULL
  RVersion <- NULL

  if (!inherits(obj, 'foreach')) {
    stop('obj must be a foreach object')
  }

  it <- iter(obj)
  argsList <- as.list(it)
  accumulator <- makeAccum(it)

  options <- obj$options

  if (!is.null(options) && !is.null(data)) {
    aplfun <- function(n, a, b) {
      ae <- a[[n]]
      be <- b[[n]]

      if (is.null(ae) || is.null(be) || typeof(ae) == 'list') {
        c(ae, be)
      } else {
        ae
      }
    }

    options <- sapply(unique(names(c(options, data))), aplfun, options, data, simplify = FALSE)
  }

  if (!is.null(options)) {
    if (!is.null(options$messages)) {
      if (!is.logical(options$messages) || length(options$messages) != 1) {
        warning('messages must be logical value', call.=FALSE)
      } else {
        if (obj$verbose) {
          cat(sprintf('setting messages option to %d\n', options$messages))
        }
        messages <- options$messages
      }
      obj$options$messages <- NULL
    }

    if (!is.null(options$steps)) {
      if (obj$verbose) {
        cat(sprintf('setting steps option to %d\n', options$steps))
      }
      steps <- options$steps
      obj$options$steps <- NULL
    }

    if (!is.null(options$imports)) {
      if (obj$verbose) {
        cat(sprintf('setting imports option to %s\n', options$imports))
      }
      imports <- options$imports
      obj$options$imports <- NULL
    }

    if (!is.null(options$sdkroot)) {
      if (obj$verbose) {
        cat(sprintf('setting sdkroot option to %s\n', options$sdkroot))
      }
      sdkroot <- options$sdkroot
      obj$options$sdkroot <- NULL
    }

    if (!is.null(options$RVersion)) {
      if (obj$verbose) {
        cat(sprintf('setting RVersion option to %s\n', options$RVersion))
      }
      RVersion <- options$RVersion
      obj$options$RVersion <- NULL
    }

    if (!is.null(options$packages)) {
      if (obj$verbose) {
        cat(sprintf('setting packages option to %s\n', options$packages))
      }
      packages <- options$packages
      obj$options$packages <- NULL
    }
  }

  packages <- c(packages, obj$packages)

  if (obj$verbose) {
    cat(sprintf('packages = %s\n', packages))
    cat(sprintf('imports = %s\n', imports))
  }

  # make sure all of the necessary libraries have been loaded
  for (p in packages) {
    library(p, character.only=TRUE)
  }

  # function to be run on workers
  FUN <- function(expr, args, envir) {
    expr <- substitute(list(expr))
    eval(expr, envir=args, enclos=envir)
  }

  if (exists('do.ply', envir)) {
    plyenv <- environment(envir$do.ply)
    if (exists('.fun', plyenv)) {
      funenv <- environment(plyenv$.fun)
      if (exists('flat', funenv)) {
        funignore <- funenv$flat
      }
    }
  }
  if (exists('...', envir)) {
    paramignore<-evalq(list(...), envir)
  }

  if (identical(envir, globalenv())) {
    envir<-new.env()
    for(n in ls(globalenv(), all.names=TRUE)) {
        assign(n, get(n, globalenv()), envir)
    }
  } else {
    for(n in ls(envir, all.names=TRUE)) {
      if (n != "...") {
        get(n, envir)
      }
    }
  }

  # Now run the code in Techila
  results <- do.call(peach, c(list(funcname = FUN,
                   params = list(expr, '<param>', envir),
                   peachvector = argsList,
                   messages = messages,
                   sdkroot = sdkroot,
                   packages = packages,
                   imports = imports,
                   stream = TRUE,
                   RVersion = RVersion,
                   steps = steps
                   ), obj$options))

  # peel of one layer of lists
  results <- unlist(results, recursive = FALSE)
  # call the accumulator with all of the results
  tryCatch(accumulator(results, seq(along=results)), error=function(e) {
    cat('error calling combine function:\n')
    print(e)
    NULL
  })

  # check for errors
  errorValue <- getErrorValue(it)
  errorIndex <- getErrorIndex(it)

  # throw an error or return the combined results
  if (identical(obj$errorHandling, 'stop') && !is.null(errorValue)) {
    msg <- sprintf('task %d failed - "%s"', errorIndex,
                   conditionMessage(errorValue))
    stop(simpleError(msg, call=expr))
  } else {
    getResult(it)
  }
}

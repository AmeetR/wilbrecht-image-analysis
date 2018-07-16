# Copyright (C) 2012-2015 Techila Technologies Ltd.

cloudfor <- function(...,

                     .variables = NULL,
                     .description = NULL,
                     .datafiles = NULL,
                     .messages = TRUE,
                     .priority = 4,
                     .sdkroot = NULL,
                     .gmkroot = NULL,
                     .stream = FALSE,
                     .callback = NULL,
                     .filehandler = NULL,
                     .initFile = NULL,
                     .password = NULL,
                     .ProjectParameters = NULL,
                     .BundleParameters = NULL,
                     .BinaryBundleParameters = NULL,
                     .donotwait = FALSE,
                     .donotuninit = FALSE,
                     .removeproject = FALSE,
                     .close = TRUE,
                     .imports = NULL,
                     .databundles = NULL,
                     .jobinputfiles = NULL,
                     .outputfiles = NULL,
                     .snapshot = FALSE,
                     .snapshotfiles = "snapshot.rda",
                     .snapshotinterval = 15,
                     .RVersion = NULL,
                     .runAsR = NULL,
                     .projectid = -1,
                     .steps = NULL,
                     .estimateTarget = 20,
                     .estimateMinimum = 1,
                     .packages = NULL
                     ) {

  l <- substitute(list(...))[-1]

  lnames <- names(l)

  names(l) <- ""

  cf = list(
    vec = l,
    vecnames = lnames,

    variables = .variables,
    description = .description,
    datafiles = .datafiles,
    messages = .messages,
    priority = .priority,
    sdkroot = .sdkroot,
    gmkroot = .gmkroot,
    stream = .stream,
    callback = .callback,
    filehandler = .filehandler,
    initFile = .initFile,
    password = .password,
    ProjectParameters = .ProjectParameters,
    BundleParameters = .BundleParameters,
    BinaryBundleParameters = .BinaryBundleParameters,
    donotwait = .donotwait,
    donotuninit = .donotuninit,
    removeproject = .removeproject,
    close = .close,
    imports = .imports,
    databundles = .databundles,
    jobinputfiles = .jobinputfiles,
    outputfiles = .outputfiles,
    snapshot = .snapshot,
    snapshotfiles = .snapshotfiles,
    snapshotinterval = .snapshotinterval,
    RVersion = .RVersion,
    runAsR = .runAsR,
    projectid = .projectid,
    steps = .steps,
    estimateTarget = .estimateTarget,
    estimateMinimum = .estimateMinimum,
    packages = .packages
    )
}

getvariables <- function(block) {
  fun <- function(v) {
    if (is.symbol(v)) {
      as.character(v)
    }
    else if (is.call(v)) {
      getvariables(v)
    }
    else {
      NULL
    }
  }
  v <- unlist(lapply(block, fun))
  v
}

getv <- function(expr, env, rl = NULL, kl = NULL) {
  vl <- getvariables(expr)

  for (vn in vl) {
    if (vn == "" || vn == "{" || vn == "+" || vn == "-" || vn == "*" || vn == "/" || vn == "^" || vn == "<-" || vn == "(" || vn == "<" || vn == ":" || vn == "[" || vn == "Class") {
      next
    }

    if (is.element(vn, kl) || is.element(vn, rl)) {
      next
    }

    #message("vn = ", vn)

    if (exists(vn, where=env, mode="function", inherits = FALSE)) {
      rl <- append(rl, vn)
      f <- get(vn, mode="function")
      v <- getv(f, env, rl, kl)
      rl <- v$rl
      kl <- v$kl
    }
    else if (exists(vn, where=env, inherits = TRUE)) {
      rl <- append(rl, vn)
    }
    else {
      kl <- append(kl, vn)
    }
  }
  list(rl=rl, kl=kl)
}

ind2sub <- function(d, ind) {
  dlen <- length(d)

  subi <- NULL
  subi[1] <- (ind - 1) %% d[1] + 1

  i <- 2
  while (i <= dlen) {
    subi[i] <- floor((ind - 1) / prod(d[1:i-1])) %% d[i] + 1
    i <- i + 1
  }
  subi
}

estimate <- function(block,
                     env,
                     d,
                     vectors,
                     jobs,
                     target=20,
                     minimum=1) {
  #require(R.utils)

  message("Estimating steps per worker...")

  if (!is.numeric(minimum) || is.nan(minimum) || minimum < 0.1) {
    minimum = 0.1
  }
  if (!is.numeric(target) || is.nan(target) || target < 1) {
    target = 1
  }

  timeout = target
  if (timeout < minimum) {
    timeout = minimum
  }

  t0 <- proc.time()

  l <- jobs

  idx <- 0
  t <- 0
  fail <- FALSE
  while (!fail && t < minimum && idx < l) {
    idx <- idx + 1

    subi <- ind2sub(d, idx)

    for (si in 1:length(subi)) {
      vi <- subi[[si]]
      vn <- names(vectors)[[si]]
      vv <- vectors[[si]][[vi]]
      assign(vn, vv, pos=env)
    }

    r <- tryCatch({

      if (is.name(formals(evalWithTimeout)$expr)) {
        # modify the evalWithTimeout function by removing
        # the extra substitute command
        # This was introduced in newer versions of R.utils
        a <- deparse(evalWithTimeout)
        a[grep("substitute", a)] <- ""
        evalWithTimeout <- eval(parse(text = a))
      }

      val <- evalWithTimeout(block, envir = env, timeout = timeout)
      list(fail = FALSE, val = val)
    }, TimeoutException=function(ex) {
      list(fail = FALSE)
    }, error=function(ex2){
      warning(ex2)
      list(fail = TRUE)
    })

    # workaround for "reached elapsed time limit", reset time limits
    setTimeLimit(cpu = Inf, elapsed = Inf, transient = TRUE)

    fail <- r$fail

    t1 <- proc.time()
    td <- t1 - t0
    t <- td[["elapsed"]]
  }

  if (!fail) {
    rate <- t / idx

    steps <- ceiling(target / rate)

    if (is.nan(steps)) {
      steps <- 1
    }

    if (is.infinite(steps)) {
      steps <- jobs
    }

    message("Executed ", idx, " loops in ", round(t, 3), " seconds. ",
            "Will perform max ", steps, " iterations per job")
  } else {
    steps <- 1
    warning("Defaulting to steps = 1")
  }

  return(steps)
}

"%to%" <- function(a, b) {
  r <- NULL
  if (is.list(a) && !is.null(a$vec)) {
    r <- list(a, b)
  } else {
    r <- append(a, list(b))
  }
  r
}


"%t%" <- function(cf, block) {

  if (is.list(cf) && !is.null(cf$vec)) {
    # single loop, not nested
    cf <- list(cf)
  }

  # create peachvector
  jobs <- 1

  vectors <- NULL

  conf <- NULL
  i <- 1
  for (cfelem in cf) {
    conf <- cfelem

    vec <- lapply(cfelem$vec, function(x) {
      eval(x, envir = parent.frame(3))
    })
    vec <- vec[[1]]
    vecname <- cfelem$vecnames[1]

    vectors[[i]] <- vec
    names(vectors)[i] <- vecname

    len <- length(vec)
    jobs <- jobs * len

    i <- i + 1
  }

  # reverse the innermost loop to first
  vectors <- rev(vectors)

  d <- NULL
  for (v in vectors) {
    d <- c(d, length(v))
  }

  #  message("%t%")

  #print(cf)

  env <- new.env(parent = baseenv())

  #message("a")

  variablelist = conf$variables

  #message("b", variablelist)

  sblock <- substitute(block)

  #message("c")

  if (is.null(variablelist)) {
      message("Building dependency tree...")
      vl <- getv(sblock, parent.frame())
      variablelist <- vl$rl
  }

  #message("e")

  #print(variablelist)

  #message("f")

  # Assign required variables into env
  if (!is.null(variablelist) && length(variablelist) > 0) {
    #message("g")
    for (vname in variablelist) {
      #message(vname)
      assign(vname, get(vname, envir = parent.frame()), pos = env)
    }
  }

  #message("h")

  #print(ls(envir=env))

  if (!is.null(variablelist) && length(variablelist) > 0) {
    cat("Copying variables and functions to worker:", paste(variablelist), "\n")
  }

  #return(NULL)

  # estimate steps
  if (is.null(conf$steps)) {
    if (!is.null(conf$jobinputfiles)) {
      stop('Cannot use estimator when jobinputfiles is defined, define steps')
    }

    s <- estimate(sblock,
                  env,
                  d,
                  vectors,
                  jobs,
                  conf$estimateTarget,
                  conf$estimateMinimum)
    conf$steps <- s
  }

  # run peach
  results <- peach(funcname = "techila_for",
                   files = system.file("techila_for.r", package="techila"),
                   params = list('<vecidx>', vectors, sblock, env),
                   jobs = jobs,
                   description = conf$description,
                   datafiles = conf$datafiles,
                   messages = conf$messages,
                   priority = conf$priority,
                   sdkroot = conf$sdkroot,
                   gmkroot = conf$gmkroot,
                   stream = conf$stream,
                   callback = conf$callback,
                   filehandler = conf$filehandler,
                   initFile = conf$initFile,
                   password = conf$password,
                   ProjectParameters = conf$ProjectParameters,
                   BundleParameters = conf$BundleParameters,
                   BinaryBundleParameters = conf$BinaryBundleParameters,
                   donotwait = conf$donotwait,
                   donotuninit = conf$donotuninit,
                   removeproject = conf$removeproject,
                   close = conf$close,
                   imports = conf$imports,
                   databundles = conf$databundles,
                   jobinputfiles = conf$jobinputfiles,
                   outputfiles = conf$outputfiles,
                   snapshot = conf$snapshot,
                   snapshotfiles = conf$snapshotfiles,
                   snapshotinterval = conf$snapshotinterval,
                   RVersion = conf$RVersion,
                   runAsR = conf$runAsR,
                   projectid = conf$projectid,
                   steps = conf$steps,
                   packages = conf$packages
                   )

  if (!is.null(results) && prod(d) == length(results)) {
    attr(results, "dim") <- d
  }

  results
}



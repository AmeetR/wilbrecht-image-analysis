# Copyright (C) 2010-2012 Techila Technologies Ltd.

uninit <- function(p1 = TRUE, p2 = TRUE) {
  unload(p1, p2)
}

unload <- function(p1 = TRUE, p2 = TRUE) {
  #print("unload called")
  if (.heap$initialized) {
    #print("unload")

    lib <- .heap$lib

    .jcall(lib, "I", "unload", p1, p2)

    .heap$initialized <- FALSE
    .heap$lib <- NULL
  }
}

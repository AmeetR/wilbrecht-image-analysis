# Copyright (C) 2010 Techila Technologies Ltd.

getProjectId <- function(handle) {
  pid <- -1
  if (.heap$initialized) {
    pm <- .heap$pm
    pid <- .jcall(pm, "I", "getProjectId", as.integer(handle))
  }
  pid
}

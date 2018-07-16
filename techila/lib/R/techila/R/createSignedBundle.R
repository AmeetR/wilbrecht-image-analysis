# Copyright (C) 2010-2012 Techila Technologies Ltd.

createSignedBundle <- function(name,
                               description = "",
                               version = "0.0.1",
                               imports = "",
                               exports = "",
                               natives = "",
                               category = "",
                               resource = "",
                               executor = "",
                               extras = NULL,
                               files = NULL) {

  bundlename <- NULL

  if (.heap$initialized) {
    lib <- .heap$lib
    bm <- .heap$bm

    handle <- .jcall(lib, "I", "open")

    r <- .jcall(bm, "I", "createSignedBundle",
                handle,
                name,
                description,
                version,
                imports,
                exports,
                natives,
                category,
                resource,
                "",
                executor,
                extras,
                files)

    if (r != .heap$ok) {
      warning("Failed creating bundle")
    }

    tmpbundlename <- .jcall(bm, "S", "getLastCreatedBundleName", handle)

    if (r == .heap$ok) {
      r <- .jcall(bm, "I", "uploadBundle", handle)

      if (r != .heap$ok) {
        warning("Failed uploading bundle")
      }
    }
    if (r == .heap$ok) {
      r <- .jcall(bm, "I", "approveUploadedBundles", handle)
      if (r != .heap$ok) {
        warning(paste("Failed approving bundle (bundle \"",
                      tmpbundlename,
                      "\" might exist already)", sep=""))
      }
    }

    if (r == .heap$ok) {
      bundlename <- tmpbundlename
    }

    .jcall(lib, "I", "close", as.integer(handle))

  }
  bundlename
}

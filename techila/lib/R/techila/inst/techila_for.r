# Copyright (C) 2012-2017 Techila Technologies Ltd.

techila_for <- function(idx, vectors, block, env) {
  sblock <- substitute(block)

  result <- NULL

  d <- NULL
  for (v in vectors) {
    d <- c(d, length(v))
  }

  subi <- ind2sub(d, idx)

  i <- 1
  for (i in 1:length(subi)) {
    vi <- subi[[i]]
    vn <- names(vectors)[[i]]
    vv <- vectors[[i]][[vi]]
    assign(vn, vv, pos=env)
  }


  techilafnlist <- list("techila.get_jobcount",
                        "techila.get_jobid",
                        "techila.ic.cloudbc",
                        "techila.ic.cloudop",
                        "techila.ic.cloudsum",
                        "techila.ic.connect",
                        "techila.ic.disconnect",
                        "techila.ic.init",
                        "techila.ic.read_int",
                        "techila.ic.read_short",
                        "techila.ic.recv_data_from_job",
                        "techila.ic.send_data_to_job",
                        "techila.ic.wait_for_others",
                        "techila.ic.write_int",
                        "techila.ic.write_short",
                        "techila.smph.release",
                        "techila.smph.reserve",
                        "techila.serialize",
                        "techila.serialize_scalar",
                        "techila.serialize_string",
                        "techila.serialize_logical",
                        "techila.serialize_numeric_simple",
                        "techila.serialize_numeric",
                        "techila.serialize_struct",
                        "techila.serialize_cell",
                        "class2tag",
                        "techila.deserialize_value",
                        "techila.deserialize_scalar",
                        "techila.deserialize_string",
                        "techila.deserialize_char",
                        "techila.deserialize_logical",
                        "techila.deserialize_numeric_simple",
                        "techila.deserialize_complex",
                        "techila.deserialize_sparse",
                        "techila.deserialize_struct",
                        "techila.deserialize_cell"
                        )
  for (techilafn in techilafnlist) {
      assign(techilafn, get(techilafn, pos = parent.frame(2)), pos = env)
  }

  for (vn in ls(env)) {
    vv <- get(vn, envir=env)
    assign(vn, vv, pos = .GlobalEnv)
  }

  eval(sblock, envir=env, enclos=.GlobalEnv)

}

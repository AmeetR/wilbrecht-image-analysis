# Copyright (C) 2010-2017 Techila Technologies Ltd.

## Interconnect

.techila.ic <- new.env()
.techila.ic$initialized <- FALSE
.techila.ic$socket <- NULL

.techila.ic$GETPROJECTID <- 0x0001L
.techila.ic$GETJOBID <- 0x0002L
.techila.ic$GETJOBCOUNT <- 0x0003L
.techila.ic$INITIALIZE <- 0x0100L
.techila.ic$SENDDATATOJOB <- 0x0101L
.techila.ic$READDATA <- 0x0102L
.techila.ic$READDATAFROMJOB <- 0x0103L
.techila.ic$WAITFOROTHERS <- 0x0104L
.techila.ic$READDATAIFEXIST <- 0x0105L
.techila.ic$SENDDATATOJOBSYNC <- 0x0106L
.techila.ic$SEMAPHORELOCALREQ <- 0x0501L
.techila.ic$SEMAPHORELOCALREL <- 0x0502L
.techila.ic$SEMAPHOREGLOBALREQ <- 0x0503L
.techila.ic$SEMAPHOREGLOBALREL <- 0x0504L
.techila.ic$SEMAPHORELOCALREQTO <- 0x0505L
.techila.ic$SEMAPHOREGLOBALREQTO <- 0x0506L
.techila.ic$REGISTERJOBID <- 0x1001L
.techila.ic$UNREGISTERJOBID <- 0x1002L
.techila.ic$QUERYJOBID <- 0x1003L
.techila.ic$REQUESTSLOT <- 0x1004L
.techila.ic$REQUESTACCEPTED <- 0x1005L
.techila.ic$BLOCKREACHED <- 0x1006L
.techila.ic$PING <- 0x1103L
.techila.ic$PONG <- 0x1104L
.techila.ic$SENDIMDATA <- 0x2001L
.techila.ic$SENDIMDATAFILE <- 0x2002L
.techila.ic$EXECCMD <- 0x2101L
.techila.ic$ABORT <- 0x3001L


techila.ic.init <- function(timeout = 30000, autoinitialize = TRUE) {
  myjobid <- Sys.getenv("TECHILA_JOBID_IN_PROJECT")
  port <- Sys.getenv("TECHILA_ICPORT")
  jobcount <- Sys.getenv("TECHILA_JOBCOUNT")

  .techila.ic$myjobid <- as.integer(myjobid)
  .techila.ic$port <- as.integer(port)
  .techila.ic$jobcount <- as.integer(jobcount)

  if (is.na(.techila.ic$myjobid) || is.na(.techila.ic$port)) {
    stop("Worker-to-Worker communication not supported. Probably all the required components are not installed into Techila environment.")
  }

  techila.ic.connect(timeout, autoinitialize)

  .techila.ic$initialized <- TRUE
}

techila.ic.read_short <- function() {
  return(readBin(.techila.ic$socket, integer(), n = 1, size = 2, endian = "big"))
}

techila.ic.read_int <- function() {
  return(readBin(.techila.ic$socket, integer(), size = 4, endian = "big"))
}

techila.ic.write_short <- function(data) {
  writeBin(as.integer(data), .techila.ic$socket, size = 2, endian = "big")
}

techila.ic.write_int <- function(data) {
  writeBin(as.integer(data), .techila.ic$socket, size = 4, endian = "big")
}

techila.ic.connect <- function(timeout = 30000, autoinitialize = TRUE) {

  if (!.techila.ic$initialized || is.null(.techila.ic$socket)) {
    socket <- socketConnection(host = "localhost", port = .techila.ic$port, blocking = TRUE, open = "r+b")

    .techila.ic$socket <- socket
  }

  if (autoinitialize) {

      techila.ic.write_short(.techila.ic$INITIALIZE)
      techila.ic.write_int(timeout)

      cmdid <- techila.ic.read_short()
      status <- techila.ic.read_short()

      if (cmdid != .techila.ic$INITIALIZE) {
        techila.ic.disconnect()
        stop(paste("cmdid mismatch, expected ", .techila.ic$INITIALIZE, ", got ", cmdid, sep = ""))
      }

      if (status != 0) {
        techila.ic.disconnect()
        stop(paste("status not ok, got ", status, sep = ""))
      }

  }

}

techila.ic.disconnect <- function() {
  if (!is.null(.techila.ic$socket)) {
    close(.techila.ic$socket)
    .techila.ic$socket <- NULL
  }
  .techila.ic$initialized <- FALSE
}


techila.get_jobid <- function() {
  if (!.techila.ic$initialized) {
    stop("Interconnect not initialized")
  }

  return(.techila.ic$myjobid)
}

techila.get_jobcount <- function() {
  if (!.techila.ic$initialized) {
    stop("Interconnect not initialized")
  }

  return(.techila.ic$jobcount)
}

techila.ic.send_data_to_job <- function(jobid, data) {
  serdata <- serialize(data, NULL)

  techila.ic.write_short(.techila.ic$SENDDATATOJOB)
  techila.ic.write_int(jobid)
  techila.ic.write_int(length(serdata))

  writeBin(serdata, .techila.ic$socket)
}

techila.ic.recv_data_from_job <- function(jobid) {
  techila.ic.write_short(.techila.ic$READDATAFROMJOB)
  techila.ic.write_int(jobid)

  cmdid <- techila.ic.read_short()
  src <- techila.ic.read_int()
  datalen <- techila.ic.read_int()

  if (cmdid != .techila.ic$READDATA) {
    stop(paste("cmdid mismatch, expected ", .techila.ic$READDATA, ", got ", cmdid, sep = ""))
  }
  if (src != jobid) {
    stop(paste("source mismatch, expected ", jobid, ", got ", src, sep = ""))
  }

  serdata <- readBin(.techila.ic$socket, raw(), n = datalen, endian = "big")

  data <- unserialize(serdata)
  return(data)
}

techila.ic.wait_for_others <- function() {

  techila.ic.write_short(.techila.ic$WAITFOROTHERS)

  cmdid <- techila.ic.read_short()
  status <- techila.ic.read_short()

  if (cmdid != .techila.ic$WAITFOROTHERS) {
    stop(paste("cmdid mismatch, expected ", .techila.ic$WAITFOROTHERS, ", got ", cmdid, sep = ""))
  }
  if (status != 0) {
    stop(paste("status not ok, got ", status, sep = ""))
  }
}

techila.ic.cloudop <- function(op, data, target = 0) {
  jobid <- .techila.ic$myjobid
  jobs <- .techila.ic$jobcount

  if (target > jobs) {
    stop("invalid target specified")
  }

  if (jobs / jobid >= 2) {
    recv <- techila.ic.recv_data_from_job(jobid * 2)
    data <- do.call(op, list(data, recv))

    if (jobs / jobid > 2) {
      recv <- techila.ic.recv_data_from_job(jobid * 2 + 1)
      data <- do.call(op, list(data, recv))
    }
  }

  if (jobid > 1) {
    techila.ic.send_data_to_job(as.integer(jobid / 2), data)
    if (target == 0) {
      result <- techila.ic.recv_data_from_job(as.integer(jobid / 2))
    } else if (target == jobid) {
      result <- techila.ic.recv_data_from_job(1)
    } else {
      result <- NULL
    }
  } else {
    result <- data
  }

  if (target == 0) {
    if (jobs / jobid >= 2) {
      techila.ic.send_data_to_job(jobid * 2, result)
      if (jobs / jobid > 2) {
        techila.ic.send_data_to_job(jobid * 2 + 1, result)
      }
    }
  } else if (jobid == 1 && target != 1) {
    techila.ic.send_data_to_job(target, result)
    result <- NULL
  }

  return(result)
}

techila.ic.cloudbc <- function(data, srcid = 1) {
  jobid <- .techila.ic$myjobid
  jobs <- .techila.ic$jobcount

  if (srcid > 1) {
    if (jobid == 1) {
      result <- techila.ic.recv_data_from_job(srcid)
    } else if (srcid == jobid) {
      techila.ic.send_data_to_job(1, data)
    }
  } else {
    result <- data
  }

  if (jobid > 1) {
    result <- techila.ic.recv_data_from_job(as.integer(jobid / 2))
  }

  if (jobs / jobid >= 2) {
    techila.ic.send_data_to_job(jobid * 2, result)
    if (jobs / jobid > 2) {
      techila.ic.send_data_to_job(jobid * 2 + 1, result)
    }
  }

  return(result)
}

techila.ic.cloudsum <- function(data, target = 0) {
  sum2 <- function(a, b) {
    return(a + b)
  }
  techila.ic.cloudop(sum2, data)
}

## Semaphores

techila.smph.reserve <- function(name, isglobal = FALSE, timeout = -1, ignoreerror = FALSE) {
  techila.ic.init(autoinitialize = FALSE);
  if (isglobal) {
    if (timeout < 0) {
      techila.ic.write_short(.techila.ic$SEMAPHOREGLOBALREQ)
    } else {
      techila.ic.write_short(.techila.ic$SEMAPHOREGLOBALREQTO)
      techila.ic.write_int(timeout)
    }
  } else {
    if (timeout < 0) {
      techila.ic.write_short(.techila.ic$SEMAPHORELOCALREQ)
    } else {
      techila.ic.write_short(.techila.ic$SEMAPHORELOCALREQTO)
      techila.ic.write_int(timeout)
    }
  }
  techila.ic.write_short(nchar(name))

  writeChar(name, .techila.ic$socket, eos=NULL)
  cmdid <- techila.ic.read_short()
  result <- techila.ic.read_short()
  if (result == 0) {
    return(TRUE)
  } else if (result == 255) {
    if (ignoreerror) {
      return(FALSE)
    } else {
      stop(paste("Error in requesting semaphore '", name, "'. Make sure the semaphore exists and the scope (local/global) is correct.", sep = ""))
    }
  } else if (result == 254) {
    if (ignoreerror) {
      return(FALSE)
    } else {
      stop(paste("Timeout in requesting semaphore '", name, "'.", sep = ""))
    }
  } else {
    stop(paste("Unknown result code from semaphore request: ", result, sep = ""))
  }
  return(FALSE)
}

techila.smph.release <- function(name, isglobal = FALSE) {
  if (!is.null(.techila.ic$socket)) {
    if (isglobal) {
      techila.ic.write_short(.techila.ic$SEMAPHOREGLOBALREL)
    } else {
      techila.ic.write_short(.techila.ic$SEMAPHORELOCALREL)
    }
    techila.ic.write_short(nchar(name))

    writeChar(name, .techila.ic$socket, eos=NULL)
    cmdid <- techila.ic.read_short()
    result <- techila.ic.read_short()
  }
}

## Serialization/Deserialization

techila.serialize <- function(v) {
  if (is.numeric(v)) {
    data <- techila.serialize_numeric(v);
  } else if (is.character(v)) {
    data <- techila.serialize_string(v);
  } else if (is.list(v)) {
    if (is.null(names(v))) {
      data <- techila.serialize_cell(v)
    } else {
      data <- techila.serialize_struct(v)
    }
  } else if (is.logical(v)) {
    data <- techila.serialize_logical(v)
  } else if (is.data.frame(v)) {
    data <- techila.serialize_cell(v)
  }
  data
}

techila.serialize_scalar <- function(v) {
  data <- c(as.raw(class2tag(v)), writeBin(v, raw()))
  data
}

techila.serialize_string <- function(v) {
  if (length(v) == 1) {
    if (nchar(v) > 0) {
      predata <- writeBin(v, raw())
      data <- c(as.raw(0), writeBin(nchar(v), raw()), predata[1:nchar(v)])
    } else {
      data <- as.raw(200)
    }
  } else {
    dims <- dim(v)
    if (is.null(dims)) {
      if (length(v) > 1) {
        dims<-length(v);
      }
    }
    maxlen=0;
    if (length(v) >= 1) {
      for (id in 1:length(v)) {
        if (nchar(v[[id]]) > maxlen) {
          maxlen = nchar(v[[id]]);
        }
      }
      if (length(v) > 1) {
        for (id in 1:length(v)) {
          v[[id]]<-sprintf(paste('%', maxlen, 's', sep=''), v[[id]])
        }
      }
    }
    if (maxlen > 0) {
      dims<-c(maxlen, dims)
    }
    dim(v)<-NULL
    v2 <- matrix(unlist(sapply(v, charToRaw, USE.NAMES = FALSE, simplify=FALSE)), nrow=length(v))
    data <- c(as.raw(132), as.raw(length(dims)), writeBin(as.integer(dims), raw()), writeBin(as.integer(v2), raw(), size=1))
  }
  data
}

techila.serialize_logical <- function(v) {
  if (is.null(dim(v))) {
    len<-length(v)
    if (len == 0) {
      dims<-c(0,0)
    } else {
      dims<-c(length(v), 1)
    }
  } else {
    dims<-dim(v)
    dim(v)<-NULL
  }
  data <- c(as.raw(133), as.raw(length(dims)), writeBin(as.integer(dims), raw()), writeBin(v, raw(), size=1))
  data
}

techila.serialize_numeric_simple <- function(v) {
  if (is.null(dim(v))) {
    len<-length(v)
    if (len == 0) {
      dims<-c(0,0)
    } else {
      dims<-c(length(v), 1)
    }
  } else {
    dims<-dim(v)
    dim(v)<-NULL
  }
  data <- c(as.raw(16+class2tag(v)), as.raw(length(dims)), writeBin(as.integer(dims), raw()), writeBin(v, raw()))
  data
}

techila.serialize_numeric <- function(v) {
  if (is(v, 'sparseMatrix')) {
    library(Matrix)
    data <- c(as.raw(130), writeBin(as.integer(dim(v)), raw(), size=8))
    i <- which(v!=0, arr.ind=TRUE)[1,]
    j <- which(v!=0, arr.ind=TRUE)[2,]
    s <- v[which(v!=0)]
    data <- c(data, techila.serialize_numeric_simple(i), techila.serialize_numeric_simple(j), as.raw(1), techila.serialize_numeric_simple(s))
  } else if (is.complex(v)) {
    data <- c(as.raw(131), techila.serialize_numeric_simple(Re(v)), techila.serialize_numeric_simple(Im(v)))
  } else if (length(v) == 1) {
    data <- techila.serialize_scalar(v)
  } else {
    data <- techila.serialize_numeric_simple(v)
  }
  data
}

techila.serialize_struct <- function(v) {
  if (is.data.frame(v)) {
    dims<-c(dim(v)[1], 1)
    fieldNames = names(v)
  } else if (is.null(dim(v))) {
    if (is.null(names(v))) {
      dims<-c(length(v), 1)
    } else {
      dims<-c(1,1)
    }
    fieldNames = names(v)
  } else {
    dims<-dim(v)
    dim(v)<-NULL
    fieldNames = names(v[1])
  }
  fnLengths <- c(length(fieldNames), nchar(fieldNames))
  fnChars <- paste(fieldNames, collapse='')
  data <- c(as.raw(128), writeBin(as.integer(fnLengths), raw()), charToRaw(fnChars), writeBin(as.integer(length(dims)), raw()), writeBin(as.integer(dims), raw()))
  if (is.data.frame(v) || prod(dims) > length(fieldNames)) {
    # first field first for each element, etc.
    data <- c(data, as.raw(0))
    for (fn in fieldNames) {
      if (is.data.frame(v)) {
        data <- c(data, techila.serialize_cell(as.vector(v[[fn]])))
      } else {
        for (i in 1:prod(dims)) {
          data <- c(data, techila.serialize_cell(get(fn, v[[i]])))
        }
      }
    }
  } else {
    # all fields of first element, then next element
    data <- c(data, as.raw(1))
    if (prod(dims) == 1) {
      # only one element
      data <- c(data, techila.serialize_cell(v))
    } else {
      if (prod(dims) > 1) {
        for (i in 1:prod(dims)) {
          data <- c(data, techila.serialize_cell(v[[i]]))
        }
      }
    }
  }
  data
}

techila.serialize_cell <- function(v) {
  if (is.factor(v)) {
    v <- as.vector(v)
  }
  if (is.null(dim(v))) {
    len<-length(v)
    if (len == 0) {
      dims<-c(0,0)
    } else {
      dims<-c(length(v), 1)
    }
  } else {
    dims<-dim(v)
    dims <- c(dims, length(v[[1]]))
    dim(v)<-NULL
  }
  data <- c(as.raw(33), as.raw(length(dims)), writeBin(as.integer(dims), raw()))
  if (length(dims) == 2) {
    if (length(v) > 0) {
      for (i in 1:length(v)) {
        data <- c(data, techila.serialize(v[[i]]))
      }
    }
  } else {
    if (length(v) > 0) {
      for (j in 1:length(v)) {
        if (length(v[[j]]) > 0) {
          for (i in 1:length(v[[j]])) {
            data <- c(data, techila.serialize(v[[j]][[i]]))
          }
        }
      }
    }
  }
  data
}

class2tag <- function(obj) {
  if (is.character(obj)) {
    b = 0
  } else if (is.double(obj)) {
    b = 1
  } else if (is.integer(obj)) {
    b = 8
  }
}

techila.deserialize_value <- function(data, pos=1) {
  retpos=TRUE
  if (pos==1) {
    retpos=FALSE
  }
  tag = as.integer(data[pos])
  if (is.element(tag, c(0,200))) {
    value <- techila.deserialize_string(data, pos)
  } else if (is.element(tag, 128)) {
    value <- techila.deserialize_struct(data, pos)
  } else if (is.element(tag, c(33:39))) {
    value <- techila.deserialize_cell(data, pos)
  } else if (is.element(tag, c(1:10))) {
    value <- techila.deserialize_scalar(data, pos)
  } else if (is.element(tag, 133)) {
    value <- techila.deserialize_logical(data, pos)
  } else if (is.element(tag, c(151:153))) {
    value <- techila.deserialize_handle(data, pos)
  } else if (is.element(tag, c(17:26))) {
    value <- techila.deserialize_numeric_simple(data, pos)
  } else if (is.element(tag, 130)) {
    value <- techila.deserialize_sparse(data, pos)
  } else if (is.element(tag, 131)) {
    value <- techila.deserialize_complex(data, pos)
  } else if (is.element(tag, 132)) {
    value <- techila.deserialize_char(data, pos)
  } else if (is.element(tag, 134)) {
    value <- techila.deserialize_object(data, pos)
  } else {
    stop('Unknown class')
  }
  v <- value[[1]]
  pos <- value[[2]]
  if (retpos) {
    return(list(v,pos))
  } else {
    return(v)
  }
}

techila.deserialize_scalar <- function(data, pos) {
  classes <- c('double', 'double', 'integer', 'integer', 'integer', 'integer', 'integer', 'integer', 'integer', 'integer')
  signed <- c(TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE)
  sizes <- c(8,4,1,1,2,2,4,4,8,8)
  sz <- sizes[as.integer(data[pos])]
  v <- readBin(data[(pos+1):(pos+sz)], what=classes[as.integer(data[pos])], signed=signed[as.integer(data[pos])], size=sz)
  pos <- pos + 1 + sz
  list(v,pos)
}

techila.deserialize_string <- function(data, pos) {
  if (data[pos] == 0) {
    pos <- pos + 1
    nbytes <- readBin(data[pos:(pos+3)], what='integer')
    pos <- pos + 4
    v <- readBin(data[pos:(pos+nbytes-1)], what='character')
    pos <- pos + nbytes
  } else {
    v <- ''
    pos <- pos + 1
  }
  list(v,pos)
}

techila.deserialize_char <- function(data, pos) {
  pos <- pos + 1
  ndms <- as.integer(data[pos])
  pos <- pos + 1
  dms <- readBin(data[pos:(pos+ndms*4-1)], what='integer', n=ndms)
  pos <- pos + ndms * 4
  nbytes <- prod(dms)
  v <- readBin(data[pos:(pos+nbytes-1)], what='character')
  v <- unlist(strsplit(v, ''))
  pos <- pos + nbytes
  if (length(dms) > 0) {
  dim(v) <- dms
  }
  list(v,pos)
}

techila.deserialize_logical <- function(data, pos) {
  pos <- pos + 1
  ndms <- as.integer(data[pos])
  pos <- pos + 1
  dms <- readBin(data[pos:(pos+ndms*4-1)], what='integer', n=ndms)
  pos <- pos + ndms * 4
  nbytes <- prod(dms)
  v <- readBin(data[pos:(pos+nbytes-1)], what='logical', n=nbytes, size=1)
  pos <- pos + nbytes
  if (length(dms) > 0) {
  dim(v) <- dms
  }
  list(v,pos)
}

techila.deserialize_numeric_simple <- function(data, pos) {
  classes <- c('double', 'double', 'integer', 'integer', 'integer', 'integer', 'integer', 'integer', 'integer', 'integer')
  signed <- c(TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE)
  sizes <- c(8,4,1,1,2,2,4,4,8,8)
  clsid <- as.integer(data[pos]) - 16
  cls <- classes[clsid]
  sz <- sizes[clsid]
  pos <- pos + 1
  ndms <- as.integer(data[pos])
  pos <- pos + 1
  dms <- readBin(data[pos:(pos+ndms*4-1)], what='integer', n=ndms)
  pos <- pos + ndms * 4
  elems <- prod(dms)
  nbytes <- elems * sz
  v <- readBin(data[pos:(pos+nbytes-1)], what=cls, n=elems, signed=signed[clsid], size=sz)
  pos <- pos + nbytes
  if (length(dms) > 0) {
  dim(v) <- dms
  }
  list(v,pos)
}

techila.deserialize_complex <- function(data,pos) {
  pos <- pos + 1
  value <- techila.deserialize_numeric_simple(data, pos);
  re <- value[[1]]
  pos <- value[[2]]
  value <- techila.deserialize_numeric_simple(data, pos);
  im <- value[[1]]
  pos <- value[[2]]
  v <- complex(real=re, imaginary=im)
  list(v,pos)
}

techila.deserialize_sparse <- function(data,pos) {
  library('Matrix')
  pos <- pos + 1
  u <- readBin(data[pos:(pos+7)], what='integer', size=8)
  pos <- pos + 8
  v <- readBin(data[pos:(pos+7)], what='integer', size=8)
  pos <- pos + 8
  value <- techila.deserialize_numeric_simple(data, pos);
  i <- value[[1]]
  pos <- value[[2]]
  value <- techila.deserialize_numeric_simple(data, pos);
  j <- value[[1]]
  pos <- value[[2]]
  if (data[pos]) {
    pos <- pos + 1
    value <- techila.deserialize_numeric_simple(data, pos);
    s <- value[[1]]
    pos <- value[[2]]
  } else {
    pos <- pos + 1
    value <- techila.deserialize_numeric_simple(data, pos);
    re <- value[[1]]
    pos <- value[[2]]
    value <- techila.deserialize_numeric_simple(data, pos);
    im <- value[[1]]
    pos <- value[[2]]
    s <- complex(real = re, imaginary = im);
  }
  v <- sparseMatrix(i = i, j= j, x = s, dims = c(u, v))
  list(v,pos)
}

techila.deserialize_struct <- function(data, pos) {
  pos <- pos + 1
  nfields <- readBin(data[pos:(pos+3)], what='integer')
  pos <- pos + 4
  fnLengths <- readBin(data[pos:(pos+nfields*4-1)], what='integer', n=nfields*4)
  pos <- pos + nfields * 4
  fnChars <- NULL
  if (sum(fnLengths) > 0) {
    fnChars <- readBin(data[pos:(pos+sum(fnLengths) - 1)], what='character')
    pos <- pos + nchar(fnChars)
  }
  ndms <- readBin(data[pos:(pos+3)], what='integer')
  pos <- pos + 4
  dms <- readBin(data[pos:(pos+ndms*4-1)], what='integer', n=ndms)
  elems <- prod(dms)
  pos <- pos + ndms * 4
  fieldNames <- NULL
  splits <- 0
  if (length(fnLengths) > 0) {
    fieldNames <- character(length(fnLengths))
    splits <- c(0, cumsum(fnLengths))
  }
  if (length(fieldNames) > 0) {
    for (k in 1:length(fieldNames)) {
      fieldNames[k] <- substr(fnChars,splits[k]+1, splits[k+1])
    }
  }
  v <- list()
  if (data[pos]) {
    pos <- pos + 1
    if (elems > 0) {
      for (elemid in 1:elems) {
        value <- techila.deserialize_cell(data, pos)
        contents <- value[[1]]
        pos <- value[[2]]
        vtmp <- list()
        if (length(fieldNames) > 0) {
          for (fnid in 1:length(fieldNames)) {
            vtmp[[fieldNames[[fnid]]]] <- contents[[fnid]]
          }
        }
        if (elems == 1) {
          v <- vtmp
        } else {
          v[[elemid]] <- vtmp
        }
      }
    }
  } else {
    pos <- pos + 1
    if (length(fieldNames) > 0) {
      for (fnid in 1:length(fieldNames)) {
        value <- techila.deserialize_cell(data, pos)
        contents <- value[[1]]
        pos <- value[[2]]
        if (elems > 0) {
          for (elemid in 1:elems) {
            if (elems == 1) {
              v[[fieldNames[[fnid]]]] <- contents
            } else {
              if (length(v) < elemid) {
                v[[elemid]] <- list()
              }
              v[[elemid]][[fieldNames[[fnid]]]] <- contents[[elemid]]
            }
          }
        }
      }
    }
  }
  if (elems > 1) {
    if (length(dms) > 0) {
    dim(v) <- dms
  }
  }
  list(v,pos)
}

techila.deserialize_cell <- function(data, pos) {
  kind <- as.integer(data[pos])
  pos <- pos + 1
  if (kind == 33) {
    ndms <- as.integer(data[pos])
    pos <- pos + 1
    dms <- readBin(data[pos:(pos+ndms*4-1)], what='integer', n=ndms)
    pos <- pos + ndms * 4
    v <- array(list(), dms)
    if (prod(dms) > 0) {
      for (ii in 1:prod(dms)) {
        value <- techila.deserialize_value(data, pos)
        v[[ii]] <- value[[1]]
        pos <- value[[2]]
      }
    }
  } else if (kind == 34) {
    value <- techila.deserialize_value(data, pos)
    content <- value[[1]]
    pos <- value[[2]]
    v <- array(list(), dim(content))
    if (length(content) > 0) {
      for (k in 1:length(content)) {
        v[[k]] <- content[[k]]
      }
    }
  } else if (kind == 35) {
    value <- techila.deserialize_value(data, pos)
    content <- value[[1]]
    pos <- value[[2]]
    v <- array(list(), dim(content))
    if (length(content) > 0) {
      for (k in 1:length(content)) {
        v[[k]] <- content[[k]]
      }
    }
    value <- techila.deserialize_value(data, pos)
    reality <- value[[1]]
    pos <- value[[2]]
    # TODO: what to do with the reality values?
  } else if (kind == 36) {
    value <- techila.deserialize_string(data, pos)
    chars <- value[[1]]
    pos <- value[[2]]
    value <- techila.deserialize_numeric_simple(data, pos)
    lengths <- value[[1]]
    pos <- value[[2]]
    value <- techila.deserialize_logical(data, pos)
    empty <- value[[1]]
    pos <- value[[2]]
    v <- array(list(), dim(lengths))
    splits <- c(0, cumsum(lengths))
    if (length(lengths) > 0) {
      for (k in 1:length(lengths)) {
        v[[k]] <- substr(chars,splits[k]+1,splits[k+1])
      }
    }
    if (length(empty) > 0) {
      for (k in 1:length(empty)) {
        if (empty[[k]]) {
          v[[k]] <- ''
        }
      }
    }
  } else if (kind == 37) {
    tag = as.integer(data[pos]);
    pos <- pos + 1
    ndms <- as.integer(data[pos])
    pos <- pos + 1
    dms <- readBin(data[pos:(pos+ndms*4-1)], what='integer', n=ndms)
    pos <- pos + ndms * 4
    if (tag == 1) {
      v = array(double(), dms)
    } else if (tag == 33) {
      v = array(list(), dms)
    } else if (tag == 128) {
      v = array(list(), dms)
    } else {
      error('Unsupported type tag.')
    }
  } else if (kind == 38) {
    value <- techila.deserialize_value(data, pos)
    prot <- value[[1]]
    pos <- value[[2]]
    ndms <- as.integer(data[pos])
    pos <- pos + 1
    dms <- readBin(data[pos:(pos+ndms*4-1)], what='integer', n=ndms)
    pos <- pos + ndms * 4
    v <- array(prot, dms)
  } else if (kind == 39) {
    value <- techila.deserialize_logical(data, pos)
    content <- value[[1]]
    pos <- value[[2]]
    v <- array(list(), dim(content))
    if (length(content) > 0) {
      for (k in 1:length(content)) {
        v[[k]] <- content[[k]]
      }
    }
  }
  list(v,pos)
}

## Snapshot

saveSnapshot <- function(..., file="snapshot.rda") {
  base::save(..., file=file, envir=parent.frame(1))
}

loadSnapshot <- function(file="snapshot.rda") {
  if (file.exists(file)) {
    base::load(file=file, envir = parent.frame(1))
  }
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

# store original directory
techila_origdir <- getwd()

# Read seed and output file name from command line arguments
techila_args <- commandArgs(TRUE)
techila_jobidx <- as.numeric(techila_args[1])
techila_output <- techila_args[2]

techila_seed <- (as.numeric(Sys.time()) * techila_jobidx) %% 2^31

set.seed(techila_seed)

techila_inputdatafile<-"techila_peach_inputdata"
techila_inputdatafileser<-"techila_peach_inputdata.ser"
techila_TechilaSerialized <- FALSE
techila_inputfound <- FALSE

if (file.exists(techila_inputdatafile)) {
  techila_inputfound <- TRUE
  base::load(techila_inputdatafile)
}

if (file.exists(techila_inputdatafileser)) {
  techila_inputfound <- TRUE
  techila_inputdata<-techila.deserialize_value(readBin(techila_inputdatafileser, raw(), file.size(techila_inputdatafileser)))
  for (techila_inputparamname in names(techila_inputdata)) {
    assign(paste('techila_',techila_inputparamname,sep=''),techila_inputdata[[techila_inputparamname]])
  }
  if (exists('techila_parameters')) {
    techila_params <- techila_parameters
  }
}

if (!techila_inputfound) {
  stop(paste("Unable to load parameters: ", techila_inputdatafile, " does not exist", sep=""))
}

if (is.null(techila_params)) {
  techila_params <- list()
}

if (!is.null(techila_libraries) && length(techila_libraries) > 0) {
  for(techila_l in techila_libraries) {
    eval(call('library', techila_l))
  }
}

if (!is.null(techila_files) && length(techila_files) > 0) {
  for(techila_f in 1:length(techila_files)) {
    source(as.character(techila_files[techila_f]))
  }
}

techila_idxstart <- (techila_jobidx - 1) * techila_steps + 1
techila_idxend <- techila_idxstart + techila_steps - 1

if (techila_idxend > techila_maxidx) {
  techila_idxend <- techila_maxidx
}

message("idxstart = ", techila_idxstart, ", idxend = ", techila_idxend)

techila_itercount <- techila_idxend - techila_idxstart + 1
techila_pcresults <- vector('list', techila_itercount)

techila_idx <- techila_idxstart
while (techila_idx <= techila_idxend) {
  techila_cparams <- techila_params # clone

  if (length(techila_cparams) > 0) {
    for (techila_i in 1:length(techila_cparams)) {
      if (is.character(techila_cparams[[techila_i]])) {
        if (techila_cparams[techila_i] == "<param>") {
          techila_cparams[techila_i] <- techila_peachvector[techila_idx]
        }
        else if (techila_cparams[techila_i] == "<vecidx>") {
          techila_cparams[techila_i] <- techila_idx
        }
        else if (techila_cparams[techila_i] == "<jobidx>") {
          techila_cparams[techila_i] <- techila_jobidx
        }
      }
    }
  }

  # for each run, go to orig dir
  setwd(techila_origdir)

  techila_result <- do.call(techila_funcname, techila_cparams)
  techila_pcresult <- list(techila_idx=techila_idx, techila_result=techila_result)
  techila_pcresults[techila_idx - techila_idxstart + 1] <- list(techila_pcresult)

  techila_idx <- techila_idx + 1
}

# go to orig dir and store result
setwd(techila_origdir)
if (techila_TechilaSerialized) {
  if (length(techila_pcresults) == 1) {
    techila_serresult <- techila.serialize(techila_result)
  } else {
    techila_serresult <- techila.serialize(techila_pcresults)
  }
  writeBin(techila_serresult, techila_output)
} else {
  base::save(techila_pcresults, file=techila_output)
}

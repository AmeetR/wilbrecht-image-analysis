techilaExecute <- function(service,
                   funcname,
                   params=list(),
                   peachvector=list(),
                   sdkroot = NULL,
                   initFile = NULL,
                   password = NULL,
                   donotuninit = FALSE) {
  
  douninit <- FALSE
  
  if (!.heap$initialized) {
    douninit <- TRUE
    
    init(sdkroot=sdkroot, initFile=initFile, password=password)
  }
  
  if (donotuninit) {
    douninit <- FALSE
  }
  
  lib <- .heap$lib
  
  proxy <- .jcall(lib, 'Lfi/techila/user/ps/TechilaProxy;', 'registerProxy', service)
  paramdata <- techila.serialize(list(funcname=funcname, params=params, peachvector=peachvector, TechilaSerialized=as.integer(1)))
  results = tryCatch({
    .jcall(proxy, 'Ljava/util/Vector;', 'execute', paramdata)
  }, Exception = function(ex) {
    return(paste('Error: ', ex$jobj$toString()))
  }, error = function(e) {
    return(paste('Error: ', e$jobj$toString()))
  }, finally = {
    if (douninit) {
      unload(TRUE, TRUE)
    }
  })
  if (is.character(results)) {
     stop(results)
  }
  rescount <- .jcall(results, 'I', 'size') - 1
  for (resid in 0:rescount) {
    result <- .jcall(results, 'Ljava/lang/Object;', 'get', as.integer(resid))
    if (resid > 0) {
      resdata <- c(resdata, techila.deserialize_value(.jevalArray(result)))
    } else {
      resdata <- techila.deserialize_value(.jevalArray(result))
    }
  }
  return(resdata)
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
    if (length(dms) > 0) {
      dim(v) <- dms
    }
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

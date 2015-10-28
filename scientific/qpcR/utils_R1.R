# `baseline` customized by Xiaoqing Rong-Mullins. 2015-10-27.

######################################################################
## cbind modification without replication ############################
cbind.na <- function (..., deparse.level = 1) 
{
    na <- nargs() - (!missing(deparse.level))    
    deparse.level <- as.integer(deparse.level)
    stopifnot(0 <= deparse.level, deparse.level <= 2)
    argl <- list(...)   
    while (na > 0 && is.null(argl[[na]])) {
        argl <- argl[-na]
        na <- na - 1
    }
    if (na == 0) 
        return(NULL)
    if (na == 1) {         
        if (isS4(..1)) 
            return(cbind2(..1))
        else return(matrix(...))  ##.Internal(cbind(deparse.level, ...)))
    }    
    
    if (deparse.level) {       
        symarg <- as.list(sys.call()[-1L])[1L:na]
        Nms <- function(i) {
            if (is.null(r <- names(symarg[i])) || r == "") {
                if (is.symbol(r <- symarg[[i]]) || deparse.level == 
                  2) 
                  deparse(r)
            }
            else r
        }
    }   
    ## deactivated, otherwise no fill in with two arguments
    if (na == 0) {
        r <- argl[[2]]
        fix.na <- FALSE
    }
    else {
        nrs <- unname(lapply(argl, nrow))
        iV <- sapply(nrs, is.null)
        fix.na <- identical(nrs[(na - 1):na], list(NULL, NULL))
        ## deactivated, otherwise data will be recycled
        #if (fix.na) {
        #    nr <- max(if (all(iV)) sapply(argl, length) else unlist(nrs[!iV]))
        #    argl[[na]] <- cbind(rep(argl[[na]], length.out = nr), 
        #        deparse.level = 0)
        #}       
        if (deparse.level) {
            if (fix.na) 
                fix.na <- !is.null(Nna <- Nms(na))
            if (!is.null(nmi <- names(argl))) 
                iV <- iV & (nmi == "")
            ii <- if (fix.na) 
                2:(na - 1)
            else 2:na
            if (any(iV[ii])) {
                for (i in ii[iV[ii]]) if (!is.null(nmi <- Nms(i))) 
                  names(argl)[i] <- nmi
            }
        }
           
        ## filling with NA's to maximum occuring nrows
        nRow <- as.numeric(sapply(argl, function(x) NROW(x)))
        maxRow <- max(nRow, na.rm = TRUE)  
        argl <- lapply(argl, function(x)  if (is.null(nrow(x))) c(x, rep(NA, maxRow - length(x)))
                                          else rbind.na(x, matrix(, maxRow - nrow(x), ncol(x))))
        r <- do.call(cbind, c(argl[-1L], list(deparse.level = deparse.level)))
    }
    d2 <- dim(r)
    r <- cbind2(argl[[1]], r)
    if (deparse.level == 0) 
        return(r)
    ism1 <- !is.null(d1 <- dim(..1)) && length(d1) == 2L
    ism2 <- !is.null(d2) && length(d2) == 2L && !fix.na
    if (ism1 && ism2) 
        return(r)
    Ncol <- function(x) {
        d <- dim(x)
        if (length(d) == 2L) 
            d[2L]
        else as.integer(length(x) > 0L)
    }
    nn1 <- !is.null(N1 <- if ((l1 <- Ncol(..1)) && !ism1) Nms(1))
    nn2 <- !is.null(N2 <- if (na == 2 && Ncol(..2) && !ism2) Nms(2))
    if (nn1 || nn2 || fix.na) {
        if (is.null(colnames(r))) 
            colnames(r) <- rep.int("", ncol(r))
        setN <- function(i, nams) colnames(r)[i] <<- if (is.null(nams)) 
            ""
        else nams
        if (nn1) 
            setN(1, N1)
        if (nn2) 
            setN(1 + l1, N2)
        if (fix.na) 
            setN(ncol(r), Nna)
    }
    r
}

##############################################################
## rbind modification without replication ####################
rbind.na <- function (..., deparse.level = 1) 
{
    na <- nargs() - (!missing(deparse.level))
    deparse.level <- as.integer(deparse.level)
    stopifnot(0 <= deparse.level, deparse.level <= 2)
    argl <- list(...)
    while (na > 0 && is.null(argl[[na]])) {
        argl <- argl[-na]
        na <- na - 1
    }    
    if (na == 0) 
        return(NULL)
    if (na == 1) {
        if (isS4(..1)) 
            return(rbind2(..1))
        else return(matrix(..., nrow = 1)) ##.Internal(rbind(deparse.level, ...)))
    }
        
    if (deparse.level) {
        symarg <- as.list(sys.call()[-1L])[1L:na]
        Nms <- function(i) {
            if (is.null(r <- names(symarg[i])) || r == "") {
                if (is.symbol(r <- symarg[[i]]) || deparse.level == 
                  2) 
                  deparse(r)
            }
            else r
        }
    }
    
    ## deactivated, otherwise no fill in with two arguments
    if (na == 0) {
        r <- argl[[2]]
        fix.na <- FALSE
    }
    else {
        nrs <- unname(lapply(argl, ncol))
        iV <- sapply(nrs, is.null)
        fix.na <- identical(nrs[(na - 1):na], list(NULL, NULL))
        ## deactivated, otherwise data will be recycled
        #if (fix.na) {
        #    nr <- max(if (all(iV)) sapply(argl, length) else unlist(nrs[!iV]))
        #    argl[[na]] <- rbind(rep(argl[[na]], length.out = nr), 
        #        deparse.level = 0)
        #}
        if (deparse.level) {
            if (fix.na) 
                fix.na <- !is.null(Nna <- Nms(na))
            if (!is.null(nmi <- names(argl))) 
                iV <- iV & (nmi == "")
            ii <- if (fix.na) 
                2:(na - 1)
            else 2:na
            if (any(iV[ii])) {
                for (i in ii[iV[ii]]) if (!is.null(nmi <- Nms(i))) 
                  names(argl)[i] <- nmi
            }
        }
        
        ## filling with NA's to maximum occuring ncols
        nCol <- as.numeric(sapply(argl, function(x) if (is.null(ncol(x))) length(x)
                                                    else ncol(x)))
        maxCol <- max(nCol, na.rm = TRUE)  
        argl <- lapply(argl, function(x)  if (is.null(ncol(x))) c(x, rep(NA, maxCol - length(x)))
                                          else cbind(x, matrix(, nrow(x), maxCol - ncol(x))))  
        
        ## create a common name vector from the
        ## column names of all 'argl' items
        namesVEC <- rep(NA, maxCol)  
        for (i in 1:length(argl)) {
          CN <- colnames(argl[[i]])          
          m <- !(CN %in% namesVEC)
          namesVEC[m] <- CN[m]          
        }  
        
        ## make all column names from common 'namesVEC'
        for (j in 1:length(argl)) {    
          if (!is.null(ncol(argl[[j]]))) colnames(argl[[j]]) <- namesVEC
        }
        
        r <- do.call(rbind, c(argl[-1L], list(deparse.level = deparse.level)))        
    }
    
    d2 <- dim(r)
    
    ## make all column names from common 'namesVEC'
    colnames(r) <- colnames(argl[[1]])
    
    r <- rbind2(argl[[1]], r)
        
    if (deparse.level == 0) 
        return(r)
    ism1 <- !is.null(d1 <- dim(..1)) && length(d1) == 2L
    ism2 <- !is.null(d2) && length(d2) == 2L && !fix.na
    if (ism1 && ism2) 
        return(r)
    Nrow <- function(x) {
        d <- dim(x)
        if (length(d) == 2L) 
            d[1L]
        else as.integer(length(x) > 0L)
    }
    nn1 <- !is.null(N1 <- if ((l1 <- Nrow(..1)) && !ism1) Nms(1))
    nn2 <- !is.null(N2 <- if (na == 2 && Nrow(..2) && !ism2) Nms(2))
    if (nn1 || nn2 || fix.na) {
        if (is.null(rownames(r))) 
            rownames(r) <- rep.int("", nrow(r))
        setN <- function(i, nams) rownames(r)[i] <<- if (is.null(nams)) 
            ""
        else nams
        if (nn1) 
            setN(1, N1)
        if (nn2) 
            setN(1 + l1, N2)
        if (fix.na) 
            setN(nrow(r), Nna)
    }
    r
}

###############################################################
## data.frames with filled NA's
data.frame.na <- function (..., row.names = NULL, check.rows = FALSE, check.names = TRUE,
    stringsAsFactors = FALSE)
{
    data.row.names <- if (check.rows && is.null(row.names))
        function(current, new, i) {
            if (is.character(current))
                new <- as.character(new)
            if (is.character(new))
                current <- as.character(current)
            if (anyDuplicated(new))
                return(current)
            if (is.null(current))
                return(new)
            if (all(current == new) || all(current == ""))
                return(new)
            stop(gettextf("mismatch of row names in arguments of 'data.frame', item %d",
                i), domain = NA)
        }
    else function(current, new, i) {
        if (is.null(current)) {
            if (anyDuplicated(new)) {
                warning("some row.names duplicated: ", paste(which(duplicated(new)),
                  collapse = ","), " --> row.names NOT used")
                current
            }
            else new
        }
        else current
    }
    object <- as.list(substitute(list(...)))[-1L]
    mrn <- is.null(row.names)
    x <- list(...)
    n <- length(x)
    if (n < 1L) {
        if (!mrn) {
            if (is.object(row.names) || !is.integer(row.names))
                row.names <- as.character(row.names)
            if (any(is.na(row.names)))
                stop("row names contain missing values")
            if (anyDuplicated(row.names))
                stop("duplicate row.names: ", paste(unique(row.names[duplicated(row.names)]),
                  collapse = ", "))
        }
        else row.names <- integer(0L)
        return(structure(list(), names = character(0L), row.names = row.names,
            class = "data.frame"))
    }
    vnames <- names(x)
    if (length(vnames) != n)
        vnames <- character(n)
    no.vn <- !nzchar(vnames)
    vlist <- vnames <- as.list(vnames)
    nrows <- ncols <- integer(n)
    for (i in seq_len(n)) {
        xi <- if (is.character(x[[i]]) || is.list(x[[i]]))
            as.data.frame(x[[i]], optional = TRUE, stringsAsFactors = stringsAsFactors)
        else as.data.frame(x[[i]], optional = TRUE)
        nrows[i] <- .row_names_info(xi)
        ncols[i] <- length(xi)
        namesi <- names(xi)
        if (ncols[i] > 1L) {
            if (length(namesi) == 0L)
                namesi <- seq_len(ncols[i])
            if (no.vn[i])
                vnames[[i]] <- namesi
            else vnames[[i]] <- paste(vnames[[i]], namesi, sep = ".")
        }
        else {
            if (length(namesi))
                vnames[[i]] <- namesi
            else if (no.vn[[i]]) {
                tmpname <- deparse(object[[i]])[1L]
                if (substr(tmpname, 1L, 2L) == "I(") {
                  ntmpn <- nchar(tmpname, "c")
                  if (substr(tmpname, ntmpn, ntmpn) == ")")
                    tmpname <- substr(tmpname, 3L, ntmpn - 1L)
                }
                vnames[[i]] <- tmpname
            }
        }
        if (missing(row.names) && nrows[i] > 0L) {
            rowsi <- attr(xi, "row.names")
            nc <- nchar(rowsi, allowNA = FALSE)
            nc <- nc[!is.na(nc)]
            if (length(nc) && any(nc))
                row.names <- data.row.names(row.names, rowsi,
                  i)
        }
        nrows[i] <- abs(nrows[i])
        vlist[[i]] <- xi
    }
    nr <- max(nrows)
    for (i in seq_len(n)[nrows < nr]) {
        xi <- vlist[[i]]
        if (nrows[i] > 0L) {
            xi <- unclass(xi)
            fixed <- TRUE
            for (j in seq_along(xi)) {
                ### added NA fill to max length/nrow
                xi1 <- xi[[j]]
                if (is.vector(xi1) || is.factor(xi1))
                  xi[[j]] <- c(xi1, rep(NA, nr - nrows[i]))
                else if (is.character(xi1) && class(xi1) == "AsIs")
                  xi[[j]] <- structure(c(xi1, rep(NA, nr - nrows[i])),
                    class = class(xi1))
                else if (inherits(xi1, "Date") || inherits(xi1,
                  "POSIXct"))
                  xi[[j]] <- c(xi1, rep(NA, nr - nrows[i]))
                else {
                  fixed <- FALSE
                  break
                }
            }
            if (fixed) {
                vlist[[i]] <- xi
                next
            }
        }
        stop("arguments imply differing number of rows: ", paste(unique(nrows),
            collapse = ", "))
    }
    value <- unlist(vlist, recursive = FALSE, use.names = FALSE)
    vnames <- unlist(vnames[ncols > 0L])
    noname <- !nzchar(vnames)
    if (any(noname))
        vnames[noname] <- paste("Var", seq_along(vnames), sep = ".")[noname]
    if (check.names)
        vnames <- make.names(vnames, unique = TRUE)
    names(value) <- vnames
    if (!mrn) {
        if (length(row.names) == 1L && nr != 1L) {
            if (is.character(row.names))
                row.names <- match(row.names, vnames, 0L)
            if (length(row.names) != 1L || row.names < 1L ||
                row.names > length(vnames))
                stop("row.names should specify one of the variables")
            i <- row.names
            row.names <- value[[i]]
            value <- value[-i]
        }
        else if (!is.null(row.names) && length(row.names) !=
            nr)
            stop("row names supplied are of the wrong length")
    }
    else if (!is.null(row.names) && length(row.names) != nr) {
        warning("row names were found from a short variable and have been discarded")
        row.names <- NULL
    }
    if (is.null(row.names))
        row.names <- .set_row_names(nr)
    else {
        if (is.object(row.names) || !is.integer(row.names))
            row.names <- as.character(row.names)
        if (any(is.na(row.names)))
            stop("row names contain missing values")
        if (anyDuplicated(row.names))
            stop("duplicate row.names: ", paste(unique(row.names[duplicated(row.names)]),
                collapse = ", "))
    }
    attr(value, "row.names") <- row.names
    attr(value, "class") <- "data.frame"
    value
}
############################################################
## rescale function => all that use 'norm' #################
rescale <- function (x, tomin, tomax) 
{
    if (missing(x) | missing(tomin) | missing(tomax)) {
        stop(paste("Usage: rescale(x, tomin, tomax)\n", 
            "\twhere x is a numeric object and tomin and tomax\n is the range to rescale into", 
            sep = "", collapse = ""))        
    }
    if (is.numeric(x) && is.numeric(tomin) && is.numeric(tomax)) {        
        xrange <- range(x, na.rm = TRUE)
        if (xrange[1] == xrange[2]) return(x)
        mfac <- (tomax - tomin)/(xrange[2] - xrange[1])
        return(tomin + (x - xrange[1]) * mfac)
    }
    else {
        warning("Only numeric objects can be rescaled")
        return(x)
    }
}

##############################################################
## vector delete #############################################
delete <- function(x, pos, fill = FALSE) {
  xout <- x[-pos]
  if (fill) xout <- c(xout, rep(NA, length(pos)))
  return(xout)
}

###############################################################
## different mean measures ####################################
gmean <- function(x) prod(x, na.rm = TRUE)^(1/length(x[!is.na(x)]))
hmean <- function(x) length(x[!is.na(x)])/sum(1/x, na.rm = TRUE) 
cmean <- function(x, E) -log(mean(E^-x, na.rm = TRUE))/log(E)

################################################################
## double ordinate plot => plot.pcrfit, efficiency, meltcurve ##
xyy.plot <- function(x, y1, y2, y1.par = NULL, y2.par = NULL, 
                     first = NULL, y1.last = NULL, y2.last = NULL, ...)
{
  options(warn = -1)
  if (is.null(y1.par)) y1.par <- list()
  if (is.null(y2.par)) y2.par <- list()   
  par(mar = c(5, 4, 4, 5))   
  if (!is.null(first)) eval(first)
  do.call(plot, modifyList(list(x = x, y = y1, xlab = deparse(substitute(x)), 
         ylab = deparse(substitute(y1)), col = 1, ...), y1.par))
  if (!is.null(y1.last)) eval(y1.last)
  par(new = TRUE)
  do.call(plot, modifyList(list(x = x, y = y2, axes = FALSE, xlab = "", 
         ylab = "", col = 2), y2.par)) 
  do.call(axis, modifyList(list(side = 4, col = 2, col.ticks = 2, col.axis = 2), y2.par))
  do.call(mtext, modifyList(list(text = deparse(substitute(y2)), 
                   side = 4, line = 3, col = 2), y2.par))
  if (!is.null(y2.last)) eval(y2.last) 
}

############################################################
## loop counter ############################################
counter <- function(i) {
  if (i %% 10 == 0) cat(i) else cat(".")
  if (i %% 50 == 0) cat("\n")
  flush.console()
}

############################################################
## multivariate aq.plot from package 'mvoutlier' => MOD ####
aq.plot <- function (x, delta = qchisq(0.975, df = ncol(x)), quan = 1/2, alpha = 0.05, plot = TRUE) 
  {
  if (is.vector(x) == TRUE || ncol(x) == 1) stop("x must be at least two-dimensional")
  covr <- covMcd(x, alpha = quan)  
  dist <- mahalanobis(x, center = covr$center, cov = covr$cov)  
  s <- sort(dist, index = TRUE)
  z <- x
  
  if (ncol(x) > 2) {
    p <- princomp(x, covmat = covr)
    z <- p$scores[, 1:2]
    sdprop <- (p$sd[1] + p$sd[2])/sum(p$sd)
    cat("Projection to the first and second robust principal components.\n")
    cat("Proportion of total variation (explained variance):", sdprop, "\n")    
  }
  
  xarw <- arw(x, covr$center, covr$cov, alpha = alpha)
 
  if (plot) {    
    plot(z, col = 3, type = "p", pch = 16, main = paste("Outliers based on ", 
        100 * (pchisq(delta, df = ncol(x))), "% quantile", sep = ""), 
        xlab = "", ylab = "")
    text(z[, 1], z[, 2], rownames(z), col = 1, cex = 0.7, pos = 4)
    SEL <- which(dist > delta)
    if (length(SEL) > 0) points(z[SEL, 1], z[SEL, 2], col = 2, pch = 16)    
  }

    o <- (sqrt(dist) > max(sqrt(xarw$cn), sqrt(qchisq(0.975, dim(x)[2]))))
   
    list(outliers = o)
}

####################################################################
## Adaptive reweighted estimator from package 'mvoutlier' => aq.plot ### 
arw <- function (x, m0, c0, alpha, pcrit) 
{
  n <- nrow(x)
  p <- ncol(x)
  
  if (missing(pcrit)) {
    if (p <= 10) 
        pcrit <- (0.24 - 0.003 * p)/sqrt(n)
    if (p > 10) 
        pcrit <- (0.252 - 0.0018 * p)/sqrt(n)
  }
  
  if (missing(alpha)) delta <- qchisq(0.975, p) else delta <- qchisq(1 - alpha, p)
  d2 <- mahalanobis(x, m0, c0)
  d2ord <- sort(d2)
  dif <- pchisq(d2ord, p) - (0.5:n)/n
  i <- (d2ord >= delta) & (dif > 0)
    
  if (sum(i) == 0) alfan <- 0 else alfan <- max(dif[i])
  if (alfan < pcrit) alfan <- 0
  if (alfan > 0) cn <- max(d2ord[n - ceiling(n * alfan)], delta) else cn <- Inf
   
  w <- d2 < cn  
    
  if (sum(w, na.rm = TRUE) == 0) {
    m <- m0
    c <- c0
  }
  else {
    m <- apply(x[w, ], 2, mean)
    c1 <- as.matrix(x - rep(1, n) %*% t(m))
    c <- (t(c1) %*% diag(w) %*% c1)/sum(w)
  }
  list(m = m, c = c, cn = cn, w = w)
}

#######################################################################
######## parameters for KOD ##########################################   
parKOD = function(
eff = c("sliwin", "sigfit", "expfit"), train = TRUE, 
        alpha = 0.05, cp.crit = 10, cut = c(-6, 2)
)
{
  eff <- match.arg(eff)
  list(
  ## uni1 parameters
  eff = eff, train = train,  
  ## uni2 parameters
  cp.crit = cp.crit, 
  ## multi1 parameters
  cut = cut,
  ## general parameters
  alpha = alpha
  )
} 
 
#########################################################################
######### KOD1 as defined in Bar et al. (2003) ##################### 
uni1 <- function(object, eff, train, alpha, verbose = FALSE, ...) {
    
  ## initialize result matrix for efficiencies
  PAR <- matrix(nrow = length(object), ncol = 1)  
  
  ## iterate over all single runs
  if (verbose) cat("Calculating efficiencies...\n") 
     
  for (i in 1:length(object)) {
    counter(i)
    
    ## if it is a non-fitted run, skip
    if (object[[i]]$isFitted == FALSE) next
        
    EFF1 <- try(switch(eff, sliwin = sliwin(object[[i]], plot = FALSE, verbose = FALSE, ...)$eff,
                            sigfit = efficiency(object[[i]], plot = FALSE, ...)$eff,
                            expfit = expfit(object[[i]], plot = FALSE, ...)$eff), silent = TRUE)   
    
    if (inherits(EFF1, "try-error")) next
    PAR[i, ] <- EFF1
  }
  cat("\n")    
  
  baretal <- function(x, train = train, alpha = alpha) {
    if (verbose) cat("Calculating Z-Score...\n")
    if (!train) Z <- sapply(1:length(x), function(y) (x[y] - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE))
    else Z <- sapply(1:length(x), function(y) (x[y] - mean(x[-y], na.rm = TRUE))/sd(x[-y], na.rm = TRUE))
    if (verbose) cat("Calculating univariate outlier(s)...\n")    
    pval <- 2 * (1 - pnorm(abs(Z)))    
    which(pval < alpha)
  }
  
  SEL <- baretal(as.numeric(PAR), train = train, alpha = alpha)
  
  return(SEL)    
}    

#########################################################################
######### KOD2 as defined by A.N. Spiess ################################ 
uni2 <- function(object, cp.crit, verbose = FALSE,  ...) {
    
  ## initialize result matrix for cpD1/cpD2 difference and R-square
  PAR <- matrix(nrow = length(object), ncol = 1)
  
  ## iterate over all single runs
  if (verbose) cat("Calculating delta of first/second derivative maxima...\n")
     
  for (i in 1:length(object)) {
    counter(i)
  
    ## if it is a non-fitted run, skip
    if (object[[i]]$isFitted == FALSE) next
  
    EFF <- try(efficiency(object[[i]], plot = FALSE, ...), silent = TRUE)    
    if (inherits(EFF, "try-error")) next
    cpD2 <- EFF$cpD2
    cpD1 <- EFF$cpD1
    PAR[i, ] <- cpD1 - cpD2    
  }  
    
  cat("\n")
    
  TEST <- apply(PAR, 1, function(x) x > cp.crit) 
  SEL <- which(TEST == TRUE)
    
  return(SEL)    
}
        
#########################################################################
######### MOD1 as defined in Tichopad et al. (2010) ##################### 
multi1 <- function(object, cut, alpha, verbose = FALSE, ...) {
  
  ## initialize result matrix for cpD1 and cpD2
  PAR <- matrix(nrow = length(object), ncol = 2)
  
  ## iterate over all single runs
  if (verbose) cat("Calculating first and second derivative maxima...\n")
      
  for (i in 1:length(object)) {
    counter(i)   
  
    ## if it is a non-fitted run, skip
    if (object[[i]]$isFitted == FALSE) next   
   
    EFF1 <- try(efficiency(object[[i]], plot = FALSE, ...), silent = TRUE)  
    if (inherits(EFF1, "try-error")) next
    
    ## first  derivative maximum of complete data
    cpD1 <- EFF1$cpD1     
     
    ## reduce data within border
    UPPER <- floor(cpD1) + cut[2]
    LOWER <- floor(cpD1) + cut[1]
    allDATA <- object[[i]]$DATA    
    cutDATA <- try(allDATA[LOWER:UPPER, ], silent = TRUE)
    if (inherits(cutDATA, "try-error")) next
      
    ## new symmetric sigmoidal for reduced data
    newOBJ <- try(pcrfit(cutDATA, 1, 2, model = l4, verbose = FALSE), silent = TRUE)
    if (inherits(newOBJ, "try-error")) next
    EFF2 <- try(efficiency(newOBJ, plot = FALSE, ...), silent = TRUE)   
    if (inherits(EFF2, "try-error")) next
    ## get cpD1 and cpD2 for reduced data
    CP1 <- EFF2$cpD1
    CP2 <- EFF2$cpD2      
    PAR[i, ] <- c(CP1, CP2) 
  }  
    
  ## linear model between cpD1 and cpD2
  if (verbose) cat("\nMaking linear model between cpD1 and cpD2...\n")
  LM <- try(lm(PAR[, 2] ~ PAR[, 1]), silent = TRUE)  
  if (inherits(LM, "try-error")) stop("Linear regression failed. Please Use other outlier method!")
  ## residuals from fit (tau)
  tau <- residuals(LM)  
  ## Z-transformation of cpD1 and tau
  cpD1_norm <- scale(PAR[, 1])
  tau_norm <- scale(tau)  
  ## bring cpD1_norm and tau_norm to same length
  tau_norm2 <- rep(NA, length(cpD1_norm))
  tau_norm2[!is.na(cpD1_norm)] <- tau_norm

  return(cbind(cpD1_norm, tau_norm2))    
}    

#########################################################################
######### MOD2 as defined in Tichopad et al. (2010) ##################### 
multi2 <- function(object, verbose = FALSE, ...) {
  
  ## initialize result matrix for slope at cpD1 and Fmax
  PAR <- matrix(nrow = length(object), ncol = 2)
  
  ## iterate over all single runs
  if (verbose) cat("Calculating slope at first derivative maximum and Fmax...\n")
    
  for (i in 1:length(object)) {
    counter(i)
    EFF1 <- try(efficiency(object[[i]], plot = FALSE, ...), silent = TRUE)   
    if (inherits(EFF1, "try-error")) next
    ## first  derivative maximum of complete data
    cpD1 <- EFF1$cpD1
    ## slope at cpD1
    SLOPE <- object[[i]]$MODEL$d1(cpD1, t(coef(object[[i]])))
    ## Fmax => parameter d in all sigmoidal models
    FMAX <- coef(object[[i]])[["d"]]
    PAR[i, ] <- c(SLOPE, FMAX)
  } 
  cat("\n")
      
  return(PAR)    
}
    
#########################################################################
######### MOD3 as defined in Sisti et al. (2010) ##################### 
multi3 <- function(object, verbose = FALSE, ...) {
  
  ## initialize result matrix for Fmax, slope at first derivative maximum
  ## and F-value at first derivative maximum
  PAR <- matrix(nrow = length(object), ncol = 3)
  
  ## iterate over all single runs
  if (verbose) cat("Calculating Fmax and slope/F-value at first derivative maximum...\n")
    
  for (i in 1:length(object)) {
    counter(i)
    EFF1 <- try(efficiency(object[[i]], plot = FALSE, ...), silent = TRUE)   
    if (inherits(EFF1, "try-error")) next
    ## first  derivative maximum of complete data
    cpD1 <- EFF1$cpD1
    ## slope at cpD1
    SLOPE <- object[[i]]$MODEL$d1(cpD1, t(coef(object[[i]])))
    ## F-value at cpD1
    FVAL <- as.numeric(predict(object[[i]], newdata = data.frame(Cycles = cpD1), which = "y")) 
    ## Fmax => parameter d in all sigmoidal models
    FMAX <- coef(object[[i]])[["d"]]
    
    PAR[i, ] <- c(SLOPE, FVAL, FMAX)
  }       
  cat("\n")
  
  return(PAR)    
}

########################################################################
########## finds Tm values => meltcurve ################################
TmFind <- function(
TEMP = NULL,
FLUO = NULL,
span.smooth = NULL,
span.peaks = NULL,
is.deriv = FALSE,
Tm.opt = NULL)
{
  ### set dataframes to zero
  meltDATA <- NULL
  tempDATA  <- NULL
  derivDATA <- NULL
  
  ### cubic spline fitting and Friedman's Supersmoother
  ### on the first derivative curve
  SPLFN <- try(splinefun(TEMP, FLUO), silent = TRUE)
  if (inherits(SPLFN, "try-error")) return()
  seqTEMP <- seq(min(TEMP, na.rm = TRUE), max(TEMP, na.rm = TRUE), length.out = 10 * length(TEMP))
  meltDATA <- cbind(meltDATA, Fluo = SPLFN(seqTEMP))
  tempDATA <- cbind(tempDATA, Temp = seqTEMP)
  if (!is.deriv) derivVEC <- SPLFN(seqTEMP, deriv = 1) else derivVEC <- -SPLFN(seqTEMP, deriv = 0)
  SMOOTH <-  try(supsmu(seqTEMP, derivVEC, span = span.smooth), silent = TRUE)
  if (inherits(SMOOTH, "try-error")) return()
  derivDATA <- cbind(derivDATA, df.dT = -SMOOTH$y)
  
  ### find peaks in first derivative data
  PEAKS <- try(peaks(-SMOOTH$y, span = span.peaks)$x, silent = TRUE)
  if (inherits(PEAKS, "try-error")) return()
  TMs <- seqTEMP[PEAKS]
  TMs <- TMs[!is.na(TMs)]
  
  ### calculate difference to Tm.opt if given
  ### by residual sum-of-squares
  if (!is.null(Tm.opt)) {
    length(TMs) <- length(Tm.opt)
    RSS <- sum((Tm.opt - TMs)^2)
  } else RSS <- NA
  
  ### return data
  outDATA <- data.frame.na(tempDATA, meltDATA, derivDATA, Pars = c(span.smooth, span.peaks), RSS, Tm = TMs)
  return(outDATA)
}

#################################################################
####### peak area calculation => meltcurve #####################
peakArea <- function(x, y)
{
  ### define background slope fit
  x.first <- head(x, 1)
  x.last <- tail(x, 1)
  y.first <- head(y, 1)
  y.last <- tail(y, 1)
  x.pair <- c(x.first, x.last)
  y.pair <- c(y.first, y.last)
  LM <- lm(y.pair ~ x.pair)

  ### calculate background values for all x
  BASELINE <- predict(LM, newdata = data.frame(x.pair = x))
  
  ### baseline data
  y.base <- y - BASELINE

  ### calculate peak area
  SPLFN <- splinefun(x, y.base)
  AREA <- integrate(SPLFN, min(x, na.rm = TRUE), max(x, na.rm = TRUE))$value
  
  return(list(area = AREA, baseline = BASELINE))
}

#########################################################################
######### utility function for peakArea #################################
peaks <- function (series, span = 3, what = c("max", "min"), do.pad = TRUE, ...) 
{
    if ((span <- as.integer(span))%%2 != 1) 
        stop("'span' must be odd")
    if (!is.numeric(series)) 
        stop("`peaks' needs numeric input")
    what <- match.arg(what)
    if (is.null(dim(series)) || min(dim(series)) == 1) {
        series <- as.numeric(series)
        x <- seq(along = series)
        y <- series
    }
    else if (nrow(series) == 2) {
        x <- series[1, ]
        y <- series[2, ]
    }
    else if (ncol(series) == 2) {
        x <- series[, 1]
        y <- series[, 2]
    }
    if (span == 1) 
        return(list(x = x, y = y, pos = rep(TRUE, length(y))), 
            span = span, what = what, do.pad = do.pad)
    if (what == "min") 
        z <- embed(-y, span)
    else z <- embed(y, span)
    s <- span%/%2
    s1 <- s + 1
    v <- max.col(z, "first") == s1
    if (do.pad) {
        pad <- rep(FALSE, s)
        v <- c(pad, v, pad)
        idx <- v
    }
    else idx <- c(rep(FALSE, s), v)
    val <- list(x = x[idx], y = y[idx], pos = v, span = span, 
        what = what, do.pad = do.pad)
    val
}

#################################################################
###### get data from environments for fitting ###################
fetchData <- function(object)
{
  ### 'pcrfit' object
  if (class(object) == "pcrfit") DATA <- object$DATA
  
  ### any other object
  if (class(object$call$data) == "name") DATA <- eval(object$call$data)
  else if (class(object$call$data) == "data.frame"  || class(object$call$data) == "matrix") DATA <- object$call$data
  else if (is.null(object$call$data)) DATA <- as.data.frame(sapply(all.vars(object$call$formula), function(a) get(a, envir = .GlobalEnv)))
  
  ### get variables from formula
  VARS <- all.vars(object$call$formula)
  LHS <- VARS[1]
  RHS <- VARS[-1]
  
  ### get predictor and response positions
  PRED.pos <- match(RHS, colnames(DATA))  
  PRED.name <- RHS[which(!is.na(PRED.pos))]
  PRED.pos <- as.numeric(na.omit(PRED.pos))
  RESP.pos <- match(LHS, colnames(DATA))  
            
  return(list(data = DATA, pred.pos = PRED.pos, resp.pos = RESP.pos, pred.name = PRED.name))
}

#############################################################################
## create n-sequence (equidistant) with selected mean and s.d.  => refmean ##
makeStat <- function(n, MEAN, SD) 
{
  X <- 1:n
  Z <- (((X - mean(X, na.rm = TRUE))/sd(X, na.rm = TRUE))) * SD
  MEAN + Z  
}

#############################################################################
## bubble plot => pcropt
bubbleplot <- function(x, y, z, scale = NULL, ...){
  RADIUS <- sqrt(z/pi)
  RANK <- rank(z)
  COL <- rev(heat.colors(length(z)))
  symbols(x, y, circles = RADIUS, inches = scale, bg = COL[RANK], ...)
}

###########################################################################
## tmvrnorm (multivariate truncated normal distribution => propagate ######
tmvrnorm <- function(
n, 
mean = rep(0, nrow(sigma)), 
sigma = diag(length(mean)), 
lower = rep(-Inf, length = length(mean)), 
upper = rep(Inf, length = length(mean))
)
{
  ## taken from tmvtnorm:::rtmvnorm.rejection
  k <- length(mean)
  Y <- matrix(NA, n, k)
  D = diag(length(mean))
  numSamples <- n
  numAcceptedSamplesTotal <- 0
  
  while (numSamples > 0) {
    nproposals <- ifelse(numSamples > 1e+06, numSamples, 
                         ceiling(max(numSamples, 10)))
    X <- mvrnorm(n, mu = mean, Sigma = sigma, empirical = TRUE)
    X2 <- X %*% t(D)
    ind <- logical(nproposals)    
    for (i in 1:nproposals) {
      ind[i] <- all(X2[i, ] >= lower & X2[i, ] <= upper)
    }
    numAcceptedSamples <- length(ind[ind == TRUE])
    if (length(numAcceptedSamples) == 0 || numAcceptedSamples == 
      0) 
      next
    numNeededSamples <- min(numAcceptedSamples, numSamples)
    Y[(numAcceptedSamplesTotal + 1):(numAcceptedSamplesTotal + 
      numNeededSamples), ] <- X[which(ind)[1:numNeededSamples], 
                                ]
    numAcceptedSamplesTotal <- numAcceptedSamplesTotal + 
      numAcceptedSamples
    numSamples <- numSamples - numAcceptedSamples
  }
  Y 
}

############################################################################
## weighting function => pcrfit ############################################
wfct <- function(
expr, 
x, 
y, 
model = model,
start = start, 
offset = offset, 
verbose = TRUE) 
{
  ## calculate variances for response values if "error" is in expression
  if (length(grep("error", expr)) > 0) {
    ## test for replication
    if (length(x) == length(unique(x))) stop("No replicates available to calculate error from!")
    ## calcuate error (s.d)
    error <- tapply(y, x, function(e) sd(e, na.rm = TRUE))    
    ## convert to original repetitions     
    error <- rep(error, length(x)/length(unique(x)))        
  }
  
  ## calculate fitted or residual values if "fitted"/"resid" is in expression
  if (length(grep("fitted", expr)) > 0 || length(grep("resid", expr)) > 0) {    
    DATA <- data.frame(Cycles = x, Fluo = y)
    ## unweighted fitting
    MODEL <- pcrfit(DATA, 1, 2, model = model, start = start, offset = offset, verbose = verbose)
    fitted <- fitted(MODEL)      
    resid <- residuals(MODEL)      
  }
  
  ## return evaluation: vector of weights 
  OUT <- eval(parse(text = expr))  
  return(OUT)
}

############ Savitzky-Golay filter => smoothit #############################
## https://stat.ethz.ch/pipermail/r-help/2004-February/045568.html #########
savgol <- function(x, ...)
{
  DOTS <- list(...)
  if (is.null(DOTS$p)) p <- 3 else p <- DOTS$p
  if (is.null(DOTS$n)) n <- p + 3 - p %% 2 else n <- DOTS$n
  if (is.null(DOTS$d)) d <- 0 else d <- DOTS$d
  
  m <- length(x)
  d <- d + 1
  
  pinv <- function(A)
  {
    s <- svd(A)
    s$v %*% diag(1/s$d) %*% t(s$u)
  }
    
  ## calculate filter coefficients
  fc <- ceiling((n - 1)/2)
  X  <- outer(-fc:fc, 0:p, FUN = "^")
  Y  <- pinv(X)        
 
  ## filter via convolution and take care of the end points by padding n %/% 2
  PAD <- n %/% 2
  x2 <- as.numeric(c(head(x, PAD), x, tail(x, PAD)))
  CONV <- convolve(x2, rev(Y[d, ]), type = "f")    
  OUT <- CONV #[fc:(length(CONV) - fc)]
  
  return(OUT)
}

##################### Running mean => smoothit #################
runmean <- function(x, wsize = 3)
{
  PAD <- wsize %/% 2
  x <- x[!is.na(x)]
  x2 <- as.numeric(c(rep(x[1], PAD), x, rep(x[length(x)], PAD)))
  OUT <- sapply(1:length(x2), function(a) mean(x2[a:(a + wsize - 1)]))[1:length(x)]
  return(OUT)
}

############# Whittaker filter => smoothit ###################
############# taken from the 'ptw' package ###################
whittaker <- function(y, lambda)
{
  ny <- length(y)
  w = rep(1, ny)
  z <- d <- e <- rep(0, length(y))
  
  OUT <- .C("whittaker",
            w = as.double(w),
            y = as.double(y),
            z = as.double(z),
            lamb = as.double(lambda),
            mm = as.integer(length(y)),
            d = as.double(d),
            e = as.double(e),
            PACKAGE = "qpcR")$z
  
  return(OUT)  
}

############# EMA: exponential moving average ###################
EMA <- function(y, alpha)
{
  ny <- length(y)
  z <- numeric(ny)
  
  OUT <- .C("EMA",
            y = as.double(y),
            z = as.double(z),
            alph = as.double(alpha),
            ny = as.integer(ny),
            PACKAGE = "qpcR")$z  
  
  return(OUT)
}

##################################################
## smoothing function => modlist ##################
smoothit <- function(x, selfun, pars)
{
  pars <- as.numeric(pars)
      
  ## smoothing function definitions
  FCT <- switch(selfun, "lowess" = function(a, f = 0.1) lowess(a, f = f)$y,
                        "supsmu" = function(a, span = "cv") supsmu(1:length(a), a, span = span)$y,
                        "spline" = function(a, spar = NULL) smooth.spline(1:length(a), a, spar = spar)$y,
                        "savgol" = function(a) savgol(a),
                        "kalman" = function(a, order = c(3, 0, 0)) a - arima(a, order = order)$residuals,
                        "runmean" =  function(a, wsize = 3) runmean(a, wsize = wsize),
                        "whit" = function(a, lambda = 10) whittaker(a, lambda = lambda),
                        "ema" = function(a, alpha) EMA(a, alpha = alpha)
  )                
 
  ## apply on columns or return original, if error  
  if (length(pars) > 0) OUT <- try(FCT(x, pars), silent = TRUE)
  else OUT <- try(FCT(x), silent = TRUE)    
  if (inherits(OUT, "try-error")) OUT <- x
  
  return(OUT)
}

####################################################
###### baseline => modlist #########################
# customized by Xiaoqing Rong-Mullins. 2015-10-27.
baseline <- function(cyc = NULL, fluo = NULL, model = NULL,
                     baseline = NULL, basecyc = NULL, basefac = NULL) 
{  
  if (is.numeric(baseline) & length(baseline == 1)) BASE <- baseline
  if (baseline == "mean") BASE <- mean(fluo[basecyc], na.rm = TRUE) 
  if (baseline == "median") BASE <- median(fluo[basecyc], na.rm = TRUE) 
  
  if (baseline == "lin") {
    fluo2 <- fluo[basecyc]
    cyc2 <- cyc[basecyc]
    LM <- lm(fluo2 ~ cyc2)
    BASE <- predict(LM, newdata = data.frame(cyc2 = cyc))    
  }
  
  if (baseline == "quad") {
    fluo2 <- fluo[basecyc]
    cyc2 <- cyc[basecyc]
    LM <- lm(fluo2 ~ cyc2 + I(cyc2^2))
    BASE <- predict(LM, newdata = data.frame(cyc2 = cyc))    
  }
  
  if (baseline == "parm") {
    #BASE <- coef(model)["c"]    
    #newDATA <- model$DATA
    #newDATA[, 2] <- newDATA[, 2] - BASE
    # xqrm
    if (is.na(model)) {
      BASE <- coef(model)["c"]    
      newDATA <- model$DATA
      newDATA[, 2] <- newDATA[, 2] - BASE
    } else newDATA <- NA
    
    newMODEL <- try(pcrfit(cyc = 1, fluo = 2, data = newDATA, model = model$MODEL), silent = TRUE)
    if (inherits(newMODEL, "try-error")) return()    
  }
  BASE <- BASE * basefac  
  
  # xqrm
  output <- list('bl'=BASE)
  if (baseline != "parm") {
    output[['bl_subtracted']] <- fluo - BASE
  } else {
    output[['fitOBJ']] <- newMODEL }
  return(output)
}


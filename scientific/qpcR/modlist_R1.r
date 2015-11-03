# customized by Xiaoqing Rong-Mullins. 2015-10-27.
# all the ', silent = FALSE' were added by xqrm

modlist <- function(
  x, 
  cyc = 1, 
  fluo = NULL, 
  model = l4, 
  check = "uni2",
  checkPAR = parKOD(),
  remove = c("none", "fit", "KOD"),
  exclude = NULL,
  labels = NULL, 
  norm = FALSE,
  baseline = c("none", "mean", "median", "lin", "quad", "parm"),
  basecyc = 1:8,
  basefac = 1,
  smooth = NULL, 
  smoothPAR = NULL, 
  factor = 1,
  opt = FALSE,
  optPAR = list(sig.level = 0.05, crit = "ftest"),
  verbose = TRUE,
  ...
)
{
  options(expressions = 50000)  
  remove <- match.arg(remove) 
  if (!is.numeric(baseline)) baseline <- match.arg(baseline)  
  
  ## convert from single fit 
  if (class(x)[1] == "pcrfit") {
    model <- x$MODEL
    x <- x$DATA            
  }                         
  
  if (is.null(fluo)) fluo <- 2:ncol(x) 
  
  ## version 1.3-5: define label vector
  if (!is.null(labels)) {
    LABNAME <- deparse(substitute(labels))     
    LABELS <- labels
    if (length(LABELS) != length(fluo)) stop("Number of labels and runs do not match!")
  } else {
    LABELS <- 1:length(fluo)
    LABNAME <- "lab"
  }
  
  CYCLES <- x[, cyc]
  allFLUO <- x[, fluo, drop = FALSE]  
  NAMES <- colnames(x)[fluo]
  
  ## version 1.3-6: exclude columns with no (default) or specific column names
  if (!is.null(exclude)) {
    if (exclude == "") SEL <- which(NAMES == "") 
    else SEL <- grep(exclude, NAMES)  
    if (length(SEL) > 0) {
      allFLUO <- allFLUO[, -SEL]
      NAMES <- NAMES[-SEL]
    }
  }
  
  ## pre-allocate model list
  modLIST <- vector("list", length = ncol(allFLUO))
  
  # xrqm
  bl_list <- list()
  blcor_list <- list()
    
  for (i in 1:ncol(allFLUO)) {
    FLUO  <- allFLUO[, i]      
    NAME <- NAMES[i]
    
    ## version 1.4-0: baselining with first cycles using 'baseline' function
    if (baseline != "none" & baseline != "parm") { 
      FLUO <- baseline(cyc = CYCLES, fluo = FLUO, model = NULL, baseline = baseline, 
                       basecyc = basecyc, basefac = basefac)
      # xrqm
      # bl_out <- baseline(cyc = CYCLES, fluo = FLUO, model = NULL, baseline = baseline, 
                         # basecyc = basecyc, basefac = basefac)
      # FLUO <- bl_out[['bl_corrected']]
      blcor <- FLUO
    }
    
    ## normalization
    if (norm) FLUO <- rescale(FLUO, 0, 1)    
    
    ## version 1.3-8: smoothing
    if (!is.null(smooth)) {    
      smooth <- match.arg(smooth, c("lowess", "supsmu", "spline", "savgol", "kalman", "runmean", "whit", "ema"))
      FLUO <- smoothit(FLUO, smooth, smoothPAR)
    }
    
    ## changing magnitude
    if (factor != 1) FLUO <- FLUO * factor                
    
    # xqrm: when baseline == "parm", adjust fluorescence value if no value in FLUO > 0, so lm.fit won't fail on '0 (non-NA) cases'
    if (baseline == "parm" & all(FLUO <= 0)) FLUO <- FLUO - min(FLUO)
    
    ## fit model
    DATA <- data.frame(Cycles = CYCLES, Fluo = FLUO)    
    
    if (verbose) cat("Making model for ", NAME, " (", model$name, ")\n", sep= "")  
    flush.console()
    
    #fitOBJ <- try(pcrfit(DATA, 1, 2, model, verbose = FALSE, ...), silent = TRUE) # ori
    fitOBJ <- try(pcrfit(DATA, 1, 2, model, verbose = FALSE, ...), silent=FALSE) # xrqm
    
    ## version 1.4-0: baselining with 'c' parameter using 'baseline' function
    if (baseline == "parm") { #fitOBJ <- baseline(model = fitOBJ, baseline = baseline) # ori
      # xrqm
      bl_out <- baseline(model = fitOBJ, baseline = baseline)
      fitOBJ <- bl_out[['newMODEL']]
      blcor <- bl_out[['blcor']] }
    
    # xrqm
    # bl_list[[i]] <- unlist(bl_out['bl'])
    blcor_list[[i]] <- blcor
    
    ## tag names if fit failed
    if (inherits(fitOBJ, "try-error")) {  
      fitOBJ <- list()     
      if (verbose) cat(" => Fitting failed. Tagging name of ", NAME, "...\n", sep = "")  
      flush.console()
      NAME <- paste("*", NAME, "*", sep = "")                
      fitOBJ$DATA <- DATA
      fitOBJ$isFitted <- FALSE
      fitOBJ$isOutlier <- FALSE
      class(fitOBJ) <- "pcrfit"        
    } else {
      if (verbose) cat(" => Fitting passed...\n", sep = "")
      flush.console()
      fitOBJ$isFitted <- TRUE
      fitOBJ$isOutlier <- FALSE
    }
    
    ## optional model selection  
    if (opt) {
      fitOBJ2 <- try(mselect(fitOBJ, verbose = FALSE, sig.level = optPAR$sig.level, crit = optPAR$crit), silent = FALSE) # xqrm added ', silent = FALSE'             
      if (inherits(fitOBJ2, "try-error")) {
        if (verbose) cat(" => Model selection failed! Using original model...\n", sep = "")
        fitOBJ$isFitted <- TRUE
        fitOBJ$isOutlier <- FALSE
        flush.console()              
      } else {
        if (verbose) cat(" => Model selection passed...", sep = "")
        flush.console()
        fitOBJ <- fitOBJ2
        fitOBJ$isFitted <- TRUE
        fitOBJ$isOutlier <- FALSE
        if (verbose) cat(" => ", fitOBJ$MODEL$name, "\n", sep = "")
        flush.console()
      }
    }    
    
    if (verbose) cat("\n")    
    
    fitOBJ$call2$model <- fitOBJ$MODEL
    
    modLIST[[i]] <- fitOBJ
    modLIST[[i]]$names <- NAME    
  }  
  
  # xqrm
  well_names <- colnames(x)[2:ncol(x)]
  # bl_info <- do.call(cbind, bl_list)
  # colnames(bl_info) <- well_names
  bl_corrected <- do.call(cbind, blcor_list)
  try(colnames(bl_corrected) <- well_names, silent=FALSE)
  
  
  ## version 1.3-5: sigmoidal outlier detection by KOD
  ## version 1.3-8: turn off check with several models that are not sigmoid
  nsMODELS <- c("linexp", "mak2", "mak2i", "mak3", "mak3i", "lin2", "cm3", "spl3")
  if (model$name %in% nsMODELS) {
    isNS <- TRUE 
    cat("Model '", model$name, "' can not be checked by outlier methods. Setting 'check = NULL'...\n", sep = "")
  } else isNS <- FALSE
  
  if (!is.null(check) & !isNS) {
    class(modLIST) <- c("modlist", "pcrfit")
    OUTL <- KOD(modLIST, method = check, par = checkPAR, plot = FALSE)   
    modLIST <- OUTL
  }
  
  ## version 1.3-5: remove failed fits and update label vector
  if (remove != "none") {
    logVEC <- vector("numeric", length = length(modLIST))
    
    ## set failed fits to 1
    if (remove %in% c("fit", "KOD")) {
      SEL <- sapply(modLIST, function(x) x$isFitted)
      logVEC[SEL == FALSE] <- 1      
    }
    
    ## set KOD's to 1
    if (remove == "KOD") {      
      SEL <- sapply(modLIST, function(x) x$isOutlier)
      logVEC[SEL == TRUE] <- 1      
    }
    
    ## remove and update LABELS vector
    SEL <- which(logVEC == 1)
    
    if (length(SEL) > 0) {
      if (verbose) cat(" => Removing from fit:", NAMES[SEL], "... \n", sep = " ")
      flush.console()
      modLIST <- modLIST[-SEL]      
      if (verbose) cat(" => Updating", LABNAME, "and writing", paste(LABNAME, "_mod", sep = ""), "to global environment...\n\n", sep = " ")
      flush.console()    
      LABELS <- LABELS[-SEL]               
    } 
  }
  
  class(modLIST) <- c("modlist", "pcrfit")
  #invisible(modLIST) # ori
  # xqrm
  return(list('ori'=modLIST, 'bl_corrected'=bl_corrected)) # , 'bl_info'=bl_info))
}

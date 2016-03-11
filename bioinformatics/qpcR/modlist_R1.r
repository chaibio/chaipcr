# customized by Xiaoqing Rong-Mullins.
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
  fallback = c("none", "mean", "median", "lin", "quad"), # xqrm
  ...
)
{
  # xqrm: start counting for running time
  func_name <- 'modlist'
  start_time <- proc.time()[['elapsed']]
  
  if (fallback == 'parm') stop('`fallback` cannot be \'parm\'.') # xqrm
  
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
  # bl_list <- list()
  fluo_add_list <- list() # fluo value after addition to adjust negative values for baseline 'parm'
  blmod_list <- list()
  blcor_list <- list()
  
  for (i in 1:ncol(allFLUO)) {
    
    # xqrm: start counting for running time
    start_time_for <- proc.time()[['elapsed']]
    
    #FLUO  <- allFLUO[, i] # ori
    FLUO_ori <- allFLUO[, i] # xqrm
    NAME <- NAMES[i]
    
    # xqrm
    baseline_looped <- baseline # Within the 'for' loop, all `baseline` parameter after this point is changed to `baseline_looped` by xqrm
    
    while (TRUE) { # xqrm
      
      ## version 1.4-0: baselining with first cycles using 'baseline' function
      #if (baseline != "none" & baseline != "parm") { # ori
      if (baseline_looped != "parm") { # xqrm
        #FLUO <- baseline(cyc = CYCLES, fluo = FLUO, model = NULL, baseline = baseline, # ori
        
        # xqrm
        blmod <- NA # baseline subtraction is not thru 'parm', thus no sigmoid model to output
        
        # xqrm
        if (baseline_looped == "none") {
          FLUO <- FLUO_ori
        } else {
          FLUO <- baseline(cyc = CYCLES, fluo = FLUO_ori, model = NULL, baseline = baseline_looped, # xqrm
                           basecyc = basecyc, basefac = basefac) }
        # bl_out <- baseline(cyc = CYCLES, fluo = FLUO, model = NULL, baseline = baseline, 
                           # basecyc = basecyc, basefac = basefac)
        # FLUO <- bl_out[['bl_corrected']]
        blcor <- FLUO
        # message('\'', baseline_looped, '\'', ' was used as the final method for baseline subtraction.') # for testing
      
      } else { # if (baseline_looped == "parm")
        FLUO <- FLUO_ori }
      
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
      if (baseline == "parm" & all(FLUO <= 0)) {
        addition <- -min(FLUO)
        FLUO <- FLUO + addition
        message('\nFluorescence values are all negative, added ', 
                round(addition, 2), 
                ' before baseline subtraction by \'parm\'.')
        }
      fluo_add_list[[i]] <- FLUO
      
      ## fit model
      DATA <- data.frame(Cycles = CYCLES, Fluo = FLUO)    
      
      if (verbose) cat("Making model for ", NAME, " (", model$name, ")\n", sep= "")  
      flush.console()
      
      #fitOBJ <- try(pcrfit(DATA, 1, 2, model, verbose = FALSE, ...), silent = TRUE) # ori
      # xqrm
      t1 <- Sys.time() # time
      fitOBJ <- try(pcrfit(DATA, 1, 2, model, verbose = FALSE, ...), silent=FALSE)
      td <- Sys.time() - t1 # time
      message('First sigmoid fitting took ', round(as.numeric(td), digits=2), ' seconds. (prior to baseline subtraction for \'parm\', after for other options)') # time
      
      ## version 1.4-0: baselining with 'c' parameter using 'baseline' function
      if (baseline_looped == "parm") { #fitOBJ <- baseline(model = fitOBJ, baseline = baseline) # ori
        
        # if baseline == 'parm' (model automatically not NULL) and sigmoid fitting of pre-subtracted amplifcation data fails (determined by 'modlist_R1.r')
        
        # xqrm
        ori_dist2x <- median(FLUO) # define original distance to x-axis as the median of FLUO values across all the cycles
        fallback_conditions <- c(
                                 'fitting_failed' = (inherits(fitOBJ, "try-error")), # sigmoid fitting failed. `class(fitOBJ) == 'try-error'` was evaluated element-wise therefore cannot be used here.
                                 'b > 0' = try(coef(fitOBJ)[['b']] > 0), # fitted curve is downward
                                 'bad c' = try(abs(ori_dist2x - coef(fitOBJ)[['c']]) >= abs(ori_dist2x)) # subtracting 'c' from fluo values moved the curve further away from x-axis
                                 )
        
        # xqrm
        if (any(fallback_conditions)) {
          
          baseline_looped <- fallback
          message('Baseline subtraction method falls back from \'parm\' to \'', fallback, '\'.')
          message('Fallback reason:')
          
          if (fallback_conditions['fitting_failed']) {
            # reference in 'modlist_R1.r': 
              # line 117: fitOBJ <- try(pcrfit(DATA, 1, 2, model, verbose = FALSE, ...), silent=FALSE) # xqrm
              # line 120: if (baseline == "parm") { #fitOBJ <- baseline(model = fitOBJ, baseline = baseline)
            message('Sigmoid fitting failed for amplifcation data before baseline subtraction.') 
          } else if (fallback_conditions['b > 0']) {
            message('There is a downward trend for the fitted sigmoid curve on amplifcation data before baseline subtraction.')
          } else if (fallback_conditions['bad c']) {
            message('Subtracting \'c\' from fluo values moved the curve further away from x-axis.') }
          
          next }
        
        
        # xqrm
        blmod <- fitOBJ
        t1 <- Sys.time() # time
        bl_out <- baseline(model = fitOBJ, baseline = baseline_looped)
        td <- Sys.time() - t1 # time
        message('Baseline subtraction with \'parm\' took ', round(as.numeric(td), digits=2), ' seconds.') # time
        fitOBJ <- bl_out[['newMODEL']]
        blcor <- bl_out[['blcor']]
        # message('\'parm\' was used as the final method for baseline subtraction.') # for testing
        }
      
      break
      
    } # xqrm: end: while
    
    # xrqm
    # bl_list[[i]] <- unlist(bl_out['bl'])
    blmod_list[[i]] <- blmod
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
    
    ## optional model selection  # xqrm: use `mselect` to choose model for sigmoid fitting of amplification curve
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
    
    # xqrm: report time cost for this function
    end_time_for <- proc.time()[['elapsed']]
    message('iteration ', i, ' took ', round(end_time_for - start_time_for, 2), ' seconds.\n')
    
  } # xqrm: end: 'for' loop
  
  # xqrm
  well_names <- colnames(x)[2:ncol(x)]
  # bl_info <- do.call(cbind, bl_list)
  # colnames(bl_info) <- well_names
  
  # xqrm
  # fluo_add for adjusted fluo values when baseline == 'parm'
  if (length(fluo_add_list) > 0) {
    fluo_add <- do.call(cbind, fluo_add_list)
    colnames(fluo_add) <- well_names
  } else fluo_add <- NULL
  
  # xqrm
  # baseline corrected fluo values
  bl_corrected <- do.call(cbind, blcor_list)
  colnames(bl_corrected) <- well_names
  #try(colnames(bl_corrected) <- well_names, silent=FALSE) # old
  
  
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
  
  class(blmod_list) <- c("modlist", "pcrfit") # xqrm
  class(modLIST) <- c("modlist", "pcrfit")
  #invisible(modLIST) # ori
  
  # xqrm: report time cost for this function
  end_time <- proc.time()[['elapsed']]
  message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
  
  
  # xqrm
  return(list('ori'=modLIST, 
              'fluoa'=fluo_add, 'blmods'=blmod_list, 
              'bl_corrected'=bl_corrected)) # , 'bl_info'=bl_info))
}

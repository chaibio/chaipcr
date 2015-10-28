pcrbatch <- function(
x, 
cyc = 1, 
fluo = NULL, 
methods = c("sigfit", "sliwin", "expfit", "LRE"),
model = l4, 
check = "uni2",
checkPAR = parKOD(),
remove = c("none", "fit", "KOD"),
exclude = NULL, 
type = "cpD2",
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
group = NULL,
names = c("group", "first"),
plot = TRUE,
verbose = TRUE,
...) 
{
  remove <- match.arg(remove)
  names <- match.arg(names)
  if (!is.numeric(baseline)) baseline <- match.arg(baseline)  
      
  ## make initial 'modlist'
  if (class(x) != "modlist") {  
    if (names(x)[cyc] != "Cycles") stop("Column 1 should be named 'Cycles'!")
    modLIST <- try(modlist(x = x, cyc = cyc, fluo = fluo, model = model, check = check, checkPAR = checkPAR,
                           remove = remove, exclude = exclude, labels = labels, norm = norm, baseline = baseline,
                           basecyc = basecyc, basefac = basefac, smooth = smooth, smoothPAR = smoothPAR, 
                           factor = factor, opt = opt, optPAR = optPAR, verbose = verbose, ...), silent = TRUE)   
    if (inherits(modLIST, "try-error")) stop("There was an error during 'modlist' creation.")
  } else modLIST <- x 
                           
  ## if 'group' is defined, make a 'replist'
  if (!is.null(group)) {     
    repLIST <- try(replist(modLIST, group = group, check = check, checkPAR = checkPAR, remove = remove,
                           names = names, opt = opt, optPAR = optPAR, verbose = TRUE, ...), silent = TRUE) 
    if (inherits(repLIST, "try-error")) cat("There was an error during 'replist' creation. Continuing with original 'modlist'...\n")
    else modLIST <- repLIST
  }  
  
  cat("\n")
                              
  ## plot diagnostics, if selected
  if (plot) plot(modLIST, which = "single")
  outLIST <- vector("list", length = length(modLIST))
  
  ## for all single models in the 'modlist' do...
  for (i in 1:length(modLIST)) {    
    NAME <- modLIST[[i]]$name    
    fitOBJ <- modLIST[[i]]   
    
    cat("Analyzing", NAME, "...\n")
    flush.console()
    
    ## sigmoidal model
    if ("sigfit" %in% methods) {
      cat("  Calculating 'eff' and 'ct' from sigmoidal model...\n")
      flush.console()
      EFF <- try(efficiency(fitOBJ, plot = FALSE, type = type, ...), silent = TRUE)
      if (!inherits(EFF, "try-error")) EFF <- c(EFF, coef(fitOBJ), model = fitOBJ$MODEL$name) else EFF <- list(eff = NA)
      names(EFF) <- paste("sig.", names(EFF), sep = "") 
    } else EFF <- NULL
    
    ## sliding window method
    if ("sliwin" %in% methods) {
      cat("  Using window-of-linearity...\n")
      SLI <- try(sliwin(fitOBJ, plot = FALSE, verbose = FALSE, ...)[1:4], silent = TRUE)
      if (inherits(SLI, "try-error")) SLI <- list(eff = NA) 
      names(SLI) <- paste("sli.", names(SLI), sep = "")       
    } else SLI <- NULL
      
    ## exponential model
    if ("expfit" %in% methods) {
      cat("  Fitting exponential model...\n")
      EXP <- try(expfit(fitOBJ, plot = FALSE, ...)[-c(2, 8)], silent = TRUE)
      if (inherits(EXP, "try-error")) EXP <- list(eff = NA)
      names(EXP) <- paste("exp.", names(EXP), sep = "")
    } else EXP <- NULL
    
    ## LRE method
    if ("LRE" %in% methods) {
      cat("  Using linear regression of efficiency (LRE)...\n")
      LRES <- try(LRE(fitOBJ, plot = FALSE, verbose = FALSE, ...)[1:3], silent = TRUE)
      if (inherits(LRES, "try-error")) LRES <- list(eff = NA) 
      names(LRES) <- paste("LRE.", names(LRES), sep = "")       
    } else LRES <- NULL    
      
    ## from 1.3-4: attach any of the 'mak' models
    if (any(c("mak2", "mak2i", "mak3", "mak3i") %in% methods)) {
      SEL <- match(methods, c("mak2", "mak2i", "mak3", "mak3i"))
      SEL <- SEL[!is.na(SEL)]
      TEXT <- c("mak2", "mak2i", "mak3", "mak3i", "cm3")[SEL]
      MODEL <- get(TEXT)
      cat("  Fitting", TEXT, "model...\n")
      MAK <- try(pcrfit(fitOBJ$DATA, 1, 2, MODEL, verbose = FALSE), silent = TRUE)
      if (inherits(MAK, "try-error")) {
        cat("There was an error in buidling the", TEXT, "model. Continuing without...\n")
        flush.console()
        MAK <- list(D0 = NA)
      } else {
        MAK <- coef(MAK)
        names(MAK) <- paste(TEXT, ".", names(MAK), sep = "")
      }
    } else MAK <- NULL
      
    ## from 1.3-7: attach 'cm3' model
    if ("cm3" %in% methods) {
      cat("  Fitting cm3 model...\n")
      CM3 <- try(pcrfit(fitOBJ$DATA, 1, 2, cm3, verbose = FALSE), silent = TRUE)
      if (inherits(CM3, "try-error")) {
        cat("There was an error in buidling the cm3 model. Continuing without...\n")
        flush.console()
        CM3 <- list(D0 = NA)
      } else {
        CM3 <- coef(CM3)
        names(CM3) <- paste("cm3.", names(CM3), sep = "")
      }
    } else CM3 <- NULL    
  
    outALL <- c(EFF, SLI, EXP, LRES, MAK, CM3)     
    outLIST[[i]] <- outALL
    
    cat("\n")
  }
  
  allNAMES <- unique(unlist(lapply(outLIST, function(x) names(x))))  
  resMAT <- matrix(nrow = length(allNAMES), ncol = length(outLIST) + 1)
  resMAT <- as.data.frame(resMAT)
  resMAT[, 1] <- allNAMES
     
  ## aggregate all results into a dataframe by 'matching'
  for (i in 1:length(outLIST)) {
    tempDAT <- t(as.data.frame(outLIST[[i]]))
    m <- match(resMAT[, 1], rownames(tempDAT))
    resMAT[, i + 1] <- tempDAT[m, ]
  }
  
  colnames(resMAT)[1] <- "Vars"
  names(resMAT)[-1] <-  sapply(modLIST, function(x) x$name)       
  class(resMAT) <- c("data.frame", "pcrbatch")   
  return(resMAT)
}

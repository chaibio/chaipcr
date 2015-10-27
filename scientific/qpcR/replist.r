replist <- function(
object, 
group = NULL, 
check = "none",
checkPAR = parKOD(),
remove = c("none", "KOD"),
names = c("group", "first"),
doFit = TRUE, 
opt = FALSE, 
optPAR = list(sig.level = 0.05, crit = "ftest"),
verbose = TRUE, 
...)
{
  names <- match.arg(names)  
  remove <- match.arg(remove)  
  
  if (class(object)[1] != "modlist") stop("Please supply an object of class 'modlist'!")
  if (is.null(group)) stop("Please define replicate groups!")
  if (length(group) != length(object)) stop("length of 'group' and 'object' must match!")    
      
  ## from 1.3-5: removing failed fits from 'modlist' which are sigmoidal outliers
  NAMES <- sapply(object, function(x) x$names)
  SEL <- grep("\\*", NAMES)  
   
  if (length(SEL) > 0) {
    cat("Removing", NAMES[SEL], "prior to fitting...\n\n")
    object <- object[-SEL]
    group <- group[-SEL]  
  }
    
  ## split 'modlist' into subsets  
  splitLIST <- split(1:length(object), group)
  repMOD <- vector("list", length = length(splitLIST))
  remID <- NULL
  newGROUP <- NULL
    
  ## iterate over all subsets
  for (i in 1:length(splitLIST)) {
    DATA <- NULL
    
    modTEMP <- object[splitLIST[[i]]]
    class(modTEMP) <- c("modlist", "pcrfit")
      
    ## from 1.3-5: tagging failed fits from 'modlist' which are kinetic outliers
    if (check != "none") {
      kodTEMP <- KOD(modTEMP, method = check, par = checkPAR, 
                     remove = switch(remove, "none" = FALSE, "KOD" = TRUE))
      modTEMP <- kodTEMP
    }
  
    ## aggregate data
    for (j in 1:length(modTEMP)) {
      DATA <- rbind(DATA, modTEMP[[j]]$DATA)         
    }  
      
    ## use model from first item
    MODEL <- modTEMP[[1]]$MODEL
    nameMODEL <- MODEL$name
    nameTEMP <- sapply(modTEMP, function(x) x$names)
      
    ## fit replicates
    if (doFit) {
      if (verbose) cat("Making model for replicates:", nameTEMP, "=>" , nameMODEL, "\n", sep = " ")
      flush.console()
      fitOBJ <- try(pcrfit(DATA, 1, 2, model = MODEL, verbose = FALSE), silent = TRUE)
    } else {
      if (verbose) cat("Aggregating without fit:", nameTEMP, "\n", sep = " ")
      flush.console()
      fitOBJ <- list()
      fitOBJ$DATA <- DATA
      fitOBJ$isFitted <- FALSE
      fitOBJ$isOutlier <- FALSE
    }  
    
    ## return empty list, if fitting failed
    if (inherits(fitOBJ, "try-error") && doFit) {
      fitOBJ <- list()   
      fitOBJ$DATA <- DATA
      if (verbose) cat(" => Fitting failed. Tagging replicates...\n", sep = "")  
      flush.console()
      ## from 1.3-5: tag failed replicate fits
      remID <- c(remID, i)  
      fitOBJ$isFitted <- FALSE
      fitOBJ$isOutlier <- FALSE
      splitLIST[[i]] <- rep(NA, length(splitLIST[[i]]))
    } else {
      if (verbose) cat(" => Fitting passed...\n", sep = "")
      fitOBJ$isFitted <- TRUE
      fitOBJ$isOutlier <- FALSE
      flush.console()       
    }
      
    ## optional model selection
    if (opt) {
      fitOBJ2 <- try(mselect(fitOBJ, verbose = FALSE, sig.level = optPAR$sig.level, crit = optPAR$crit), silent = TRUE)             
            
      if (inherits(fitOBJ2, "try-error")) {
        if (verbose) cat(" => Model selection failed! Using original model...\n", sep = "")
        flush.console()
        fitOBJ <- fitOBJ        
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
      
    repMOD[[i]] <- fitOBJ
    repMOD[[i]]$isReps <- TRUE
    repMOD[[i]]$DATA <- DATA     
    repMOD[[i]]$modlist <- modTEMP    
    
    if (names == "group") repMOD[[i]]$names <- paste("group_", i, sep = "") 
    else repMOD[[i]]$names <- modTEMP[[1]]$names     
    newGROUP <- c(newGROUP, rep(i, length(modTEMP)))
  }      
        
  ## from 1.3-5: remove failed replicate fits  
  if (!is.null(remID)) { 
    if (verbose) cat("Removing tagged replicates...\n")
    repMOD <- repMOD[-remID]
    SEL <- as.numeric(sapply(remID, function(x) which(newGROUP == x)))
    newGROUP <- newGROUP[-SEL]    
  }
  
  newGROUP <- as.factor(newGROUP)
      
  class(repMOD) <- c("modlist", "replist", "pcrfit")
  attr(repMOD, "nlevels") <- nlevels(newGROUP)
  attr(repMOD, "nitems") <- as.numeric(table(newGROUP))
  attr(repMOD, "group") <- newGROUP
  return(repMOD)
}
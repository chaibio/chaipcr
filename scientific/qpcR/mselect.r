mselect <- function(
object,
fctList = NULL,
sig.level = 0.05,
verbose = TRUE,
crit = c("ftest", "ratio", "weights", "chisq"),
do.all = FALSE, 
...
)
{
  crit <- match.arg(crit)
  if (any(class(object) == "replist")) object <- object[[1]]
  else if (any(class(object) == "pcrfit")) object <- object 
  else stop("'object' must be either of class 'pcrfit' or 'replist'!")
  
  mtype <- object$MODEL$name     

  if (is.null(fctList)) {
    if (mtype %in% c("b4", "b5", "b6", "b7")) fctLIST <- list(b4, b5, b6, b7)
    if (mtype %in% c("l4", "l5", "l6", "l7")) fctLIST <- list(l4, l5, l6, l7)
    if (mtype == "mak2" || mtype == "mak3") fctLIST <- list(mak2, mak3)
  } else fctLIST <- fctList
  
  if (do.all) {
      fctLIST <- list(l4, l5, l6, l7, b4, b5, b6, b7)
      crit <- "weights"
  }
  
  retMAT <- matrix(nrow = length(fctLIST), ncol = 7)
  rn <- NULL	
   
  modLIST <- list()
  
  for (i in 1:length(fctLIST)) {
    tempMOD <- try(pcrfit(object$DATA, 1, 2, fctLIST[[i]], verbose = verbose), silent = TRUE)
    if (inherits(tempMOD, "try-error")) next     
    modLIST[[i]] <- tempMOD
  } 

  for (i in 1:length(modLIST)) {
    rn[i] <- modLIST[[i]]$MODEL$name
    retMAT[i, 1] <- round(logLik(modLIST[[i]]), 2)
		retMAT[i, 2] <- round(AIC(modLIST[[i]]), 2)
		retMAT[i, 3] <- round(AICc(modLIST[[i]]), 2)
		retMAT[i, 4] <- round(resVar(modLIST[[i]]), 5)   		
    if (i < length(modLIST)) retMAT[i + 1 , 5] <- as.matrix(anova(modLIST[[i]], modLIST[[i + 1]]))[2, 6]
    if (i < length(modLIST)) retMAT[i + 1, 6] <- llratio(modLIST[[i]], modLIST[[i + 1]])$p.value  
    retMAT[i, 7] <- fitchisq(modLIST[[i]], ...)$chi2.red            
  }           
	
  aic.w <- round(akaike.weights(retMAT[, 2])$weights, 3)
  aicc.w <- round(akaike.weights(retMAT[, 3])$weights, 3)       
  retMAT <- cbind(retMAT, aic.w, aicc.w)      
  	
  colnames(retMAT) <- c("logLik", "AIC", "AICc", "resVar", "ftest", "LR", "Chisq", "AIC.weights", "AICc.weights")
  rownames(retMAT) <- rn
	
  if (verbose) {
    cat("\n")
    print(retMAT)
  }     
  	
  if (crit == "ftest") {
    modTRUE <- retMAT[, 5] < sig.level    
    if(all(is.na(modTRUE))) stop("nested f-test was unsuccessful! Probably not nested (df = 0)?")   
    modTRUE[is.na(modTRUE)] <- FALSE   
    WHICH <- which(modTRUE)                
    SELECT <- max(WHICH)
    if (any(modTRUE == TRUE)) optMODEL <- fctLIST[[SELECT]] else optMODEL <- object$MODEL      
  }
      
  if (crit == "ratio") {     
    if (any(retMAT[, 6] == 0, na.rm = TRUE)) stop("likelihood ratio p-value is 0! Probably not nested (df = 0)?")     
    modTRUE <- retMAT[, 6] < sig.level   
    modTRUE[is.na(modTRUE)] <- FALSE      
    WHICH <- which(modTRUE)     
    SELECT <- max(WHICH)   
    if (any(modTRUE == TRUE)) optMODEL <- fctLIST[[SELECT]] else optMODEL <- object$MODEL    
  }

  if (crit == "weights") {
    SELECT <- which.max(retMAT[, 9])
    optMODEL <- fctLIST[[SELECT]]
  }
  
  if (crit == "chisq") {
    SELECT <- which.min(abs(1 - retMAT[, 7]))
    optMODEL <- fctLIST[[SELECT]]
  }
      
  optMODEL <- pcrfit(object$DATA, 1, 2, optMODEL, verbose = verbose)    

  optMODEL$retMat <- retMAT
  return(optMODEL)
}

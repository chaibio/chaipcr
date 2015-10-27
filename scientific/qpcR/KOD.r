KOD <- function(
object,    
method = c("uni1", "uni2", "multi1", "multi2", "multi3"),
par = parKOD(),
remove = FALSE,
verbose = TRUE, 
plot = TRUE,
...
)
{
  method <- match.arg(method)
  CLASS <- class(object)
  tempLIST <- GROUP <- NULL   
  
  ## extract parameters for the different functions
  EFF <- par$eff
  TRAIN <- par$train
  CPCRIT <- par$cp.crit
  CUT <- par$cut
  ALPHA <- par$alpha  

  if (!is.na(pmatch("uni", method))) CHAR <- "univariate" else CHAR <- "multivariate"
  
  if (CLASS[1] != "modlist") stop("Please supply either a 'modlist' or 'replist'!")       
  if (CLASS[2] == "replist") ITER <- length(object) else ITER <- 1       

  for (i in 1:ITER) {
    if (CLASS[2] == "replist") tempOBJ <- object[[i]]$modlist else tempOBJ <- object
    NAMES <- sapply(tempOBJ, function(x) x$names) 
            
    ## methods selection
    if (method == "uni1") DATA <- uni1(tempOBJ, eff = EFF, train = TRAIN, alpha = ALPHA, verbose = verbose, ...)
    if (method == "uni2") DATA <- uni2(tempOBJ, cp.crit = CPCRIT, verbose = verbose, ...)
    if (method == "multi1") DATA <- multi1(tempOBJ, cut = CUT, alpha = ALPHA, verbose = verbose, ...)    
    if (method == "multi2") DATA <- multi2(tempOBJ, verbose = verbose, ...)
    if (method == "multi3") DATA <- multi3(tempOBJ, verbose = verbose, ...)      
    
    ## get outliers from univariate outlier tests
    if (!is.na(pmatch("uni", method))) OUTL <- DATA   
  
    ## get outliers from multivariate outlier tests => 'aq.plot'' 
    ## from package 'mvoutlier' in utils.R
    if (!is.na(pmatch("multi", method))) {
      row.names(DATA) <- NAMES   
    
      if (verbose) cat("Calculating multivariate outlier(s)...\n")
    
      RES <- aq.plot(DATA, delta = qchisq(0.975, df = ncol(DATA)), quan = 1/2, alpha = par$alpha,
                     plot = plot)    
      
      OUTL <- which(RES$outlier == TRUE)
    }
      
    if (length(OUTL) == 0) NOUTL <- 1:length(tempOBJ) else NOUTL <- (1:length(tempOBJ))[-OUTL]
    
    ## tag as outliers
    for (i in OUTL) tempOBJ[[i]]$isOutlier <- TRUE
    for (j in NOUTL) tempOBJ[[j]]$isOutlier <- FALSE 
    
    ## tag names or optionally remove outlier runs
    if (length(OUTL) > 0) {
      if (verbose) cat(" Found", CHAR, "outlier for", NAMES[OUTL], "\n")  
      flush.console() 
      if (remove) {
        if (verbose) cat(" Removing", NAMES[OUTL], "...\n")
        flush.console()
        tempOBJ <- tempOBJ[-OUTL]         
      } else {
        if (verbose) cat(" Tagging name of", NAMES[OUTL], "...\n")
        flush.console()
        for (i in OUTL) tempOBJ[[i]]$names <- paste("**", tempOBJ[[i]]$names, "**", sep = "") 
        flush.console()      
      }      
    }
    
    ## create new list from replicates and define GROUP vector
    if (CLASS[2] == "replist") {
      cat("\n")
      tempLIST <- c(tempLIST, tempOBJ)
      GROUP <- c(GROUP, length(tempOBJ))      
    }

  }
    
  ## update by making a new 'replist'
  if (CLASS[2] == "replist") {    
    if (verbose) cat("Updating object of class 'replist':\n")
    class(tempLIST) <- c("modlist", "pcrfit")
    GROUP <- rep(1:length(GROUP), GROUP) 
    tempOBJ <- replist(tempLIST, GROUP, verbose = verbose, ...)    
  }          
    
  class(tempOBJ) <- CLASS    
  return(tempOBJ)
}  
   

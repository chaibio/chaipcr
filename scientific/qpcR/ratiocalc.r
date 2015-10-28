ratiocalc <- function(
data, 
group = NULL, 
which.eff = c("sig", "sli", "exp", "mak", "cm3", "ext"),
type.eff = c("individual", "mean.single", "median.single",
              "mean.pair", "median.pair"), 
which.cp = c("cpD2", "cpD1", "cpE", "cpR", "cpT", "Cy0", "ext"),
...)
{      
    if (class(data)[2] != "pcrbatch")
        stop("data is not of class 'pcrbatch'!")
    
    NCOL <- ncol(data) - 1      
    
    ## test for equal length of input
    if (is.null(group))
        stop("Please define 'group'!")   
          
    if (length(group) != NCOL)
        stop("Length of 'group' and 'data' do not match!")
    
    if (!is.numeric(which.eff)) which.eff <- match.arg(which.eff)

    if (!is.numeric(which.cp)) which.cp <- match.arg(which.cp)
    type.eff <- match.arg(type.eff)
    
    ## version 1.3-4: added option of external efficiencies or threshold cycles,
    ## either single value (recycled) or a vector of values.
    if (is.numeric(which.eff)) {      
      if (length(which.eff) == 1) which.eff <- rep(which.eff, NCOL)
      else {
        if (length(which.eff) != NCOL) stop("Length of input efficiencies does not match number of runs!")
      }
      effDAT <- matrix(c("ext.eff", which.eff), nrow = 1)
      colnames(effDAT) <- colnames(data)
      data <- rbind(data, effDAT) 
      which.eff <- "ext"     
    }
    
    if (is.numeric(which.cp)) {
      if (length(which.cp) != NCOL) stop("Length of input threshold cycles does not match number of runs!")
      cpDAT <- matrix(c("sig.ext", which.cp), nrow = 1)
      colnames(cpDAT) <- colnames(data)
      data <- rbind(data, cpDAT) 
      which.cp <- "ext"      
    }      
    
    ANNO <- data[, 1]
    DATA <- data[, -1]
                      
    ## version 1.3-4: added mak3
    ## version 1.3-7: added cm3
    if (which.eff == "mak") {
      GREP <- grep("mak\\w*.D0", ANNO)         
      if (length(GREP) == 0) stop("data has no 'mak' model included! Please use 'pcrbatch' with methods = 'makX'!")
      ANNO <- sub("mak\\w*.D0", "mak.eff", ANNO)
    }    
         
    if (which.eff == "cm3") {
      GREP <- grep("cm3.D0", ANNO)     
      if (length(GREP) == 0) stop("data has no 'cm3' model included! Please use 'pcrbatch' with methods = 'cm3'!")
      ANNO <- sub("cm3.D0", "cm3.eff", ANNO)
    }    
    
    ## version 1.3-5 : added removal of failed runs (either failed fits
    ## or SOD outlier) from DATA and 'group' by identification
    ## of *...* or **...** in sample name
    sampNAMES <- names(DATA)      
    hasTag <- grep("\\*\\w*\\*", sampNAMES, perl = TRUE)   
    if (length(hasTag) > 0) {
       DATA <- DATA[, -hasTag]
       group <- group[-hasTag]      
    }
    
    ## test for presence of reference genes
    if (all(regexpr("rs", group, perl = TRUE) == -1)) refNo <- TRUE else refNo <- FALSE   
    
    ## get names pattern
    PATTERN <- unique(group)    
    
    ## check for replicate data, if not present set type.eff = "individual"
    REPS <- lapply(PATTERN, function(x) which(x == group))
    NREPS <- sapply(REPS, function(x) length(x))           
    if (!all(NREPS > 1)) type.eff <- "individual"
    
    cpDAT <- effDAT <- NULL
    cpNAMES <- effNAMES <- NULL   
    
    ## select criteria
    effSEL <- which(ANNO == paste(which.eff, ".eff", sep = ""))
    cpSEL <- which(ANNO == paste("sig.", which.cp, sep = ""))
       
    ## version 1.3-8: convert to matrix to eliminate strange behaviour with non-replicates
    DATA <- as.matrix(DATA)
    
    ## for all entries 'gs', 'gc', 'rs', 'rc' do...
    for (i in 1:length(PATTERN)) {    
      WHICH <- which(group == PATTERN[i])  
      tempCP <- as.numeric(DATA[cpSEL, WHICH, drop = FALSE])    
      tempEff <- as.numeric(DATA[effSEL, WHICH, drop = FALSE])        
      cpDAT <- cbind.na(cpDAT, tempCP)        
      effDAT <- cbind.na(effDAT, tempEff)
      cpNAMES <- c(cpNAMES, paste("cp.", PATTERN[i], sep = ""))
      effNAMES <- c(effNAMES, paste("eff.", PATTERN[i], sep = ""))         
    }
      
    ## remove first column
    cpDAT <- cpDAT[, -1]      
    effDAT <- effDAT[, -1]      
    
    ## calculate averaged efficiencies/threshold cycles
    if (is.numeric(which.eff))
        type.eff <- "individual"
    if (type.eff == "mean.single")
        effDAT <- t(replicate(nrow(effDAT), apply(effDAT, 2, function(x) mean(x, na.rm = TRUE))))
    if (type.eff == "median.single")
        effDAT <- t(replicate(nrow(effDAT), apply(effDAT, 2, function(x) median(x, na.rm = TRUE))))
    if (type.eff == "mean.pair") {
        effDAT[, 1:2] <- mean(effDAT[, 1:2], na.rm = TRUE)
        if (!refNo)
            effDAT[, 3:4] <- mean(effDAT[, 3:4], na.rm = TRUE)
    }
    if (type.eff == "median.pair") {
        effDAT[, 1:2] <- median(effDAT[, 1:2], na.rm = TRUE)
        if (!refNo)
            effDAT[, 3:4] <- median(effDAT[, 3:4], na.rm = TRUE)
    }
    
    ## make a one row matrix in case of no replicates
    cpDAT <- matrix(cpDAT, ncol = length(cpNAMES))
    effDAT <- matrix(effDAT, ncol = length(effNAMES))    
    
    allDAT <- cbind(cpDAT, effDAT)     
    colnames(allDAT) <- c(cpNAMES, effNAMES)    
    
    ## define expressions
    if (refNo) {
      EXPR <- expression(eff.gc^cp.gc/eff.gs^cp.gs)      
      
      ## version 1.3-4/1.3-7: added makX/cm3 option => we only need D0 for ratio calculation
      if (which.eff %in% c("mak", "cm3")) {
        EXPR <- expression(eff.gs/eff.gc)
        TIES <- NULL
      }      
    }    
    else {
      EXPR <- expression((eff.gc^cp.gc/eff.gs^cp.gs)/(eff.rc^cp.rc/eff.rs^cp.rs))      
      
      ## version 1.3-4/1.3-7: added makX/cm3 option => we only need D0 for ratio calculation
      if (which.eff %in% c("mak", "cm3")) {
        EXPR <- expression((eff.gs/eff.gc)/(eff.rs/eff.rc))
        TIES <- NULL
      }      
    }       
    
    ## define 'TIES' that bind rs/gs and rc/gc samples together,
    ## similar to "pairwise reallocation" in REST software
    TIES <- numeric(ncol(allDAT))
    isCON <- grep("\\w*c$", colnames(allDAT))
    isSAMP <- grep("\\w*s$", colnames(allDAT))
    TIES[isCON] <- 1
    TIES[isSAMP] <- 2   
              
    CRIT <- c("perm > init", "perm == init", "perm < init")
        
    ## version 1.3-8: need to eliminate first two columns if mak/cm3 model
    if (which.eff %in% c("mak", "cm3")) {
      if (ncol(allDAT) == 4) {
        allDAT <- allDAT[, 3:4]
        TIES <- TIES[3:4]
      }
      if (ncol(allDAT) == 8) {
        allDAT <- allDAT[, 5:8]   
        TIES <- TIES[5:8]
      }
    }
    
    PROP <- try(propagate(EXPR, allDAT, do.sim = TRUE, do.perm = TRUE, ties = TIES, perm.crit = CRIT, 
                      verbose = TRUE, logx = TRUE, ...))

    if (inherits(PROP, "try-error")) stop("'propagate' failed to calculate ratios! Try other 'which.eff', 'type.eff' or 'which.cp'!")
    PROP <- c(list(data = allDAT), PROP)     
    class(PROP) <- "ratiocalc"
    return(PROP)
}

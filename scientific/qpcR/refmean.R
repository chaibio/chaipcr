refmean <- function(
data, 
group = NULL, 
which.eff = c("sig", "sli", "exp", "mak", "ext"),
type.eff = c("individual", "mean.single"), 
which.cp = c("cpD2", "cpD1", "cpE", "cpR", "cpT", "Cy0", "ext"),
verbose = TRUE,
...)
{
  if (class(data)[2] != "pcrbatch") stop("data must be of class 'pcrbatch'!")
  if (is.null(group)) stop("Please define 'group'!")
  if (length(group) != ncol(data) - 1) stop("Length of 'group' and 'data' do not match!")
  if (!is.numeric(which.eff)) which.eff <- match.arg(which.eff)
  type.eff <- match.arg(type.eff)
  
  ## from 1.3-7: exchange numeric efficiencies/threshold cycles
  if (is.numeric(which.eff)) {
    effDAT <- matrix(c("ext.eff", which.eff), nrow = 1) 
    colnames(effDAT) <- colnames(data)
    data <- rbind(data, effDAT)
    which.eff <- "ext" 
  } 
  if (is.numeric(which.cp)) {
    cpDAT <- matrix(c("sig.ext", which.cp), nrow = 1) 
    colnames(cpDAT) <- colnames(data)
    data <- rbind(data, cpDAT)
    which.cp <- "ext" 
  }
  
  ## get 'group' name
  GROUPNAME <- deparse(substitute(group))  
  
  ## split labels and data
  ANNO <- data[, 1, drop = FALSE]
  DATA <- data[, -1, drop = FALSE]
  
  ## check for equal length of data and 'group' vector
  if (length(group) != ncol(DATA)) stop("Length of 'group' and 'data' do not match!")
  
  ## check for number of reference genes, control samples and treatment samples
  numCon <- unique(na.omit(as.numeric(sub("g\\d*c(\\d*)", "\\1", group, perl = TRUE))))
  numSamp <- unique(na.omit(as.numeric(sub("g\\d*s(\\d*)", "\\1", group, perl = TRUE))))  
  RefInCon <- unique(na.omit(as.numeric(sub("r(\\d*)c\\d*", "\\1", group, perl = TRUE))))
  RefInSamp <- unique(na.omit(as.numeric(sub("r(\\d*)s\\d*", "\\1", group, perl = TRUE))))
    
  ## initialize variables  
  matMEAN <- NULL
  matSD <- NULL
  allSEL <- NULL 
  
  ## averaging of reference genes in control and treatment samples 
  for (k in c("c", "s")) {
  for (i in switch(k, "c" = numCon, "s" = numSamp)) {
    if (verbose) cat(" Calculating statistics (mean & sd) for: ")
    for (j in switch(k, "c" = RefInCon, "s" = RefInSamp)) {      
      STR <- paste("r", j, k, i, sep = "")   
      if (verbose) cat(STR, "")
      SEL <- grep(STR, group)       
      allSEL <- c(allSEL, SEL)
      tempDAT <- DATA[, SEL, drop = FALSE]
      GROUP <- as.factor(rep(1, ncol(tempDAT)))  
      MEAN <- apply(tempDAT, 1, function(x) tapply(as.numeric(x), GROUP, function(y) mean(y, na.rm = TRUE)))
      MEAN <- matrix(MEAN)      
      colnames(MEAN) <- STR      
      SD <- apply(tempDAT, 1, function(x) tapply(as.numeric(x), GROUP, function(y) sd(y, na.rm = TRUE)))
      SD <- matrix(SD)    
      
      ## replace NA values in SD that occur when sd is done on single runs
      if (all(is.na(SD))) SD <- matrix(0, nrow = nrow(SD), ncol = 1)
      
      ## if reference values are taken as all with the same average or is numeric, set s.d. = 0 
      if (type.eff == "mean.single" || is.numeric(which.eff)) SD <- matrix(rep(0, nrow(SD)))
      colnames(SD) <- STR
      matMEAN <- cbind(matMEAN, MEAN)
      matSD <- cbind(matSD, SD) 
    }
        
    if (verbose) cat("\n")
        
    TEXT1 <- paste("a", 1:ncol(matMEAN), sep = "", collapse = " + ")
    TEXT2 <- paste("(", TEXT1, ")", "/", ncol(matMEAN), sep = "")
    EXPR <- parse(text = TEXT2)  
      
    ## error propagation of averaged efficiencies
    selEFF <- which(ANNO == paste(which.eff, "eff", sep = "."))      
    meanEFF <- matMEAN[selEFF, , drop = FALSE]      
    sdEFF <- matSD[selEFF, ]     
    statEFF <- rbind(meanEFF, sdEFF) 
    if (verbose) cat("  => error propagation for", colnames(statEFF), "(efficiencies)...\n")
    colnames(statEFF) <- paste("a", 1:ncol(statEFF), sep = "")    
    propEFF <- propagate(EXPR, statEFF, type = "stat", plot = FALSE, ...)    
    newEFF <- makeStat(length(allSEL), propEFF$summary[1, "Prop"], propEFF$summary[2, "Prop"])
    if (verbose) cat("  => replacing with new values...\n")
    DATA[selEFF, allSEL] <- round(newEFF, 6)
    
    ## error propagation of averaged threshold cycles
    selCP <- which(ANNO == paste("sig", which.cp, sep = "."))
    meanCP <- matMEAN[selCP, ]
    sdCP <- matSD[selCP, ]
    statCP <- rbind(meanCP, sdCP)   
    if (verbose) cat("  => error propagation for", colnames(statCP), "(threshold cycles)...\n")
    colnames(statCP) <- paste("a", 1:ncol(statCP), sep = "")    
    propCP <- propagate(EXPR, statCP, type = "stat", plot = FALSE, ...)
    newCP <- makeStat(length(allSEL), propCP$summary[1, "Prop"], propCP$summary[2, "Prop"])
    if (verbose) cat("  => replacing with new values...\n")
    DATA[selCP, allSEL] <- round(newCP, 2)
    
    ## exchange labels in 'group' vector    
    POS <- grep(paste("r.", k, i, sep = ""), group)
    group[POS]  <- paste("r1", k, i, sep = "")   
    
    ## reset variables
    matMEAN <- NULL
    matSD <- NULL
    allSEL <- NULL
  }
  }
  
  DATA <- cbind(ANNO, DATA)
  class(DATA) <- c("data.frame", "pcrbatch")
  
  ## attaching 'group' attribute for 'ratiobatch'
  attr(DATA, "group") <- group
  return(DATA)    
}
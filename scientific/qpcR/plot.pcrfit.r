plot.pcrfit <- function(
x, 
which = c("all", "single", "3D", "image"),
fitted = TRUE, 
add = FALSE,
col = NULL, 
confband = c("none", "confidence", "prediction"),
errbar = c("none", "sd", "se", "conf"),
par3D = list(),
par2D = list(),
parCI = list(),
parSD = list(), 
...) 
{
  confband <- match.arg(confband)
  errbar <- match.arg(errbar)
  which <- match.arg(which)    
  
  object <- x
  
  if (class(x) != "modlist") modLIST <- list(object) else modLIST <- object      
    
  ## extract cycles and fluorescence values from all curves
  allCYC <- lapply(modLIST, function(x) x$DATA[, 1])
  allFLUO <- lapply(modLIST, function(x) x$DATA[, 2])
  vecCYC <- do.call(c, allCYC)
  vecFLUO <- do.call(c, allFLUO)
  
  ## make unique cycles  
  CYC <- unique(as.numeric(vecCYC))  
  CYC <- CYC[!is.na(CYC)]    
  
  ## calculate min and max fluo values for defining ylim 
  MIN <- min(vecFLUO, na.rm = TRUE)   
  MAX <- max(vecFLUO, na.rm = TRUE)     
  
  ## length of 'modlist'
  LEN <- length(modLIST)
  ## names of 'modlist'
  NAMES <- sapply(modLIST, function(x) x$names)   
  
  ## define plotting colors
  if (is.null(col)) {
    COL <- rep(1, LEN)    
    if (class(object)[2] == "replist") COL <- rainbow(attr(object, "nlevels"))     
  } else COL <- rep(col, length.out = LEN)   
    
  ## 3D plot empty setup using par3D parameters
  if (which == "3D") {
    do.call(plot3d, modifyList(list(x = CYC, y = 1:LEN, z = MAX, type = "n", axes = FALSE, box = FALSE, xlab = "", 
           ylab = "", zlab = "", zlim = c(0, 1.1 * MAX)), par3D))
    do.call(axis3d, modifyList(list('x', at = pretty(CYC), cex = 0.5), par3D))
    do.call(mtext3d, modifyList(list("Cycles", 'x', line = 2), par3D))     
    do.call(axis3d, modifyList(list('y', at = 1:LEN, label = NAMES, cex = 0.5), par3D))
    do.call(mtext3d, modifyList(list("Run", 'y', line = 2), par3D))
    do.call(axis3d, modifyList(list('z', cex = 0.5), par3D))
    do.call(mtext3d, modifyList(list("Fluo", 'z', line = 2), par3D))
  }   
  
  ## standard 'all' plot empty setup
  if (which == "all" && !add)   
    do.call(plot, modifyList(list(CYC, rep(MAX, length(CYC)), ylim = c(MIN, MAX), 
         xlab = "Cycles", ylab = "Raw fluorescence", type = "n", las = 1), par2D)) 
  
  ## plot matrix empty setup
  if (which == "single") {
    DIM <- ceiling(sqrt(LEN))
    par(mfrow = c(DIM, DIM))
    par(mar = c(0.2, 0.2, 1, 0.2))
  } 
  
  ## image plot 
  if (which == "image") {
    RUNS <- 1:length(modLIST)
    nRUNS <- length(RUNS)
    ## unique cycles
    CYCS <- unique(unlist(lapply(modLIST, function(x) x$DATA[, 1])))
    nCYCS <- length(CYCS)
    ## convert list with fluo data to matrix, fll unequal length with NA
    allLIST <- lapply(modLIST, function(x) x$DATA[, 2])
    maxCYCS <- max(sapply(allLIST, length))
    for (i in 1:length(allLIST)) allLIST[[i]] <- c(allLIST[[i]], rep(NA, maxCYCS - length(allLIST[[i]])))
    allDAT <- do.call(cbind, allLIST)
    ## image setup
    allDAT <- allDAT[, ncol(allDAT):1]
    image(allDAT, col = heat.colors(100), axes = FALSE, xlab = "Cycles", ylab = "Runs")
    axis(1, at = seq(0, 1, length.out = nCYCS), labels = CYCS)
    axis(2, at = seq(0, 1, length.out = nRUNS), labels = rev(RUNS))
  }
  
  for (i in 1:LEN) {
    DATA <- modLIST[[i]]$DATA    
    DATA <- na.omit(DATA)      
    FITTED <- fitted(modLIST[[i]])       
    m <- match(CYC, DATA[, 1])
    m <- na.omit(m)
          
    ## plot 3D curves
    if (which == "3D") {
      do.call(points3d, modifyList(list(x = DATA[, 1], y = i, z = DATA[, 2], color = COL[i]), par3D))
      if (!is.null(FITTED) && fitted) do.call(lines3d, modifyList(list(x = DATA[m, 1], y = i, z = FITTED[m], color = COL[i]), par3D))      
    }
    
    ## plot 2D curves
    if (which == "all") {
      do.call(points, modifyList(list(DATA[, 1], DATA[, 2], col = COL[i]), par2D))
      if (!is.null(FITTED) && fitted) do.call(lines, modifyList(list(DATA[m, 1], FITTED[m], col = COL[i]), par2D)) 
    } 
    
    ## plot matrix curves
    if (which == "single") {
      NAME <- NAMES[i]
      ## color by failed fit or failed structure
      if (grepl("\\*\\*[[:alnum:]]*", NAME)) colMAIN <- "blue" 
      else if (grepl("\\*[[:alnum:]]*", NAME)) colMAIN <- "red"
      else colMAIN <- "black"
      TRY <- try(do.call(plot, modifyList(list(DATA[, 1], DATA[, 2], main = NAME, cex.main = 0.7, col.main = colMAIN, type = "p", 
                         xlab = FALSE, ylab = FALSE, xaxt = "n", yaxt = "n", col = COL[i]), par2D)), silent = TRUE)
      if (inherits(TRY, "try-error")) next      
      if (!is.null(FITTED) && fitted) do.call(lines, modifyList(list(DATA[m, 1], FITTED[m], col = COL[i]), par2D))      
    } 
        
    ## confidence band
    if (confband != "none") {      
      CONFINT <- predict(modLIST[[i]], interval = confband, ...)
      do.call(lines, modifyList(list(CYC, CONFINT$Lower, col = 2), parCI))
      do.call(lines, modifyList(list(CYC, CONFINT$Upper, col = 2), parCI))
    }
    
    ## error bars and confidence intervals
    if (errbar != "none") {      
      if (class(object)[2] != "replist") stop("Error bars only possible on a 'replist'!")      
      STAT <- switch(errbar, sd = tapply(DATA[, 2], DATA[, 1], function(x) sd(x, na.rm = TRUE)),
                     se = tapply(DATA[, 2], DATA[, 1], function(x) sd(x, na.rm = TRUE)/sqrt(length(na.omit(x)))),
                     conf = predict(modLIST[[i]], interval = "conf", ...))
      upperSTAT <- switch(errbar, sd = STAT, se = STAT, conf = STAT$Upper - FITTED[m])
      lowerSTAT <- switch(errbar, sd = STAT, se = STAT, conf = FITTED[m] - STAT$Lower)
      do.call(arrows, modifyList(list(DATA[m, 1], FITTED[m] - lowerSTAT, DATA[m, 1], FITTED[m] + upperSTAT, angle = 90, code = 3, col = COL[i], length = 0.05), parSD))
    } 
  }     
}  
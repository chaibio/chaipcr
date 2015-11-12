sliwin <- function(
object, 
wsize = 6, 
basecyc = 1:6,
base = 0,
border = NULL,
type = c("rsq", "slope"),
plot = TRUE, 
verbose = TRUE, 
...) 
{
  if (class(object)[1] != "pcrfit") stop("object must be of class 'pcrfit'!")   
  type <- match.arg(type)
  PARS <- list(...)$pars
  OPT <- list(...)$opt
  
  ## define border to search in
  RES <- efficiency(object, plot = FALSE)
  cpD1 <- RES$cpD1
  cpD2 <- RES$cpD2
  LOWER <- takeoff(object)$top
  UPPER <- cpD1 + (cpD1 - cpD2)
 
  if (length(border) == 2) {
    LOWER <- LOWER + border[1]
    UPPER <- UPPER + border[2]    
  } else if (length(border == 1)) LOWER <- UPPER <- border
   
  ## get data
  X <- object$DATA[, 1]
  Y <- object$DATA[, 2]  
  
  ## define ylim for plotting
  YMIN <- min(log10(Y), na.rm = TRUE)
  YMAX <- max(log10(Y), na.rm = TRUE) 
  
  ## baseline sequence
  MIN <- min(Y[basecyc], na.rm = TRUE)
  MAX <- max(Y[basecyc], na.rm = TRUE)    
  MEAN <- mean(Y[basecyc], na.rm = TRUE)
  SD <- sd(Y[basecyc], na.rm = TRUE)
  
  if (is.null(OPT)) {
    if (base > 0) BASE <- seq(MIN, MEAN + base * SD, length.out = 100)
    else BASE <- base
  } else BASE <- base      
  
  ## make combinatory grid and eliminate sliding window
  ## points outside of border 
  GRID <- expand.grid(LOWER:UPPER, wsize, BASE)
  GRID[, 4] <- GRID[, 1] + GRID[, 2] - 1  
  if (nrow(GRID) > 1) GRID <- GRID[GRID[, 4] < UPPER, ]    
      
  ## pre-allocate result matrix
  parMAT <- matrix(nrow = nrow(GRID), ncol = 4)   
  
  ## iterate over all wsize/base and sliding window combinations
  for (i in 1:nrow(GRID)) {
    if (verbose) counter(i)     
    
    ## subtract baseline value
    modY <- Y - GRID[i, 3]        
         
    ## log Y
    modY <- log10(modY)    
  
    ## linear regression on sliding window    
    win <- GRID[i, 1]:GRID[i, 4]  
    winX <- X[win]   
    winY <- modY[win]      
    LM <- try(lm(winY ~ winX), silent = TRUE)      
    if (inherits(LM, "try-error")) next
    COEF <- coef(LM)  
    if (any(is.na(COEF))) next
    
    ## get parameters
    EFF <- as.numeric(10^COEF[2])
    RSQ <- as.numeric(Rsq(LM))
    INIT <- as.numeric(10^COEF[1])  
    SLOPE <- as.numeric(COEF[2])
    parMAT[i, ] <- c(EFF, RSQ, INIT, SLOPE)       
    
    ## plot cycles vs log data and regression curve
    if (plot) {
      plot(X, modY, xlab = "Cycles", ylab = "log(RFU)", cex.axis = 1.3, cex.lab = 1.5, ylim = c(YMIN, YMAX), 
           main = paste(expression(R^2), ":", round(RSQ, 5), "\nEff:", round(EFF, 2)))
      points(winX, winY, cex = 1, pch = 16, col = 2)
      abline(LM, col = 2)
      abline(h = log10(GRID[i, 3]), col = 4)
    }    
  }  
   
  ## find best iteration based on R-square and Eff <= 2 
  resMAT <- cbind(GRID, parMAT)      
  names(resMAT) <- c("lower", "wsize", "base", "upper", "eff", "rsq", "init", "slope")   
  
  resMAT <- resMAT[resMAT[, 5] <= 2, ]
  resMAT <- resMAT[resMAT[, 5] >= 1, ]      
  
  if (type == "rsq") {
    ## select best r-square
    SEL <- which.max(resMAT[, 6])  
  } else {
    ## select window with least change in slope at lower/upper part 
    ## and take best R-square from this
    SLOPE <- resMAT[, 8]
    BASE <- resMAT[, 3]
    SLOPESD <- tapply(SLOPE, BASE, function(x) sd(x, na.rm = TRUE))
    minSD <- which.min(SLOPESD)
    ID <- which(resMAT[, 3] == names(SLOPESD)[minSD])
    tempMAT <- resMAT[ID, ]
    rsqMAX <- which.max(tempMAT[, 6])   
    selMAT <- tempMAT[rsqMAX, , drop = FALSE]
    SEL <- which(rownames(resMAT) == rownames(selMAT))  
  }  
  
  ## run 'sliwin' with optimal parameters
  optPAR <- resMAT[SEL, ]    
      
  ## one more go with optimized parameters  
  if (is.null(PARS)) {    
    res <- sliwin(object, wsize = as.numeric(optPAR[2]), border = as.numeric(optPAR[1]), 
                  base = as.numeric(optPAR[3]), plot = plot, pars = resMAT, verbose = verbose, opt = 1)
    return(res)
  }

  if (verbose) cat("\n") 
  
  ## return parameters
  if (!is.null(PARS)) resMAT <- PARS
  return(list(eff = as.numeric(optPAR[5]), rsq = as.numeric(optPAR[6]), init = as.numeric(optPAR[7]),
              base = as.numeric(optPAR[3]), window = as.numeric(c(optPAR[1], optPAR[4])), parMat = resMAT))
}

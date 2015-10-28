LRE <- function(
object, 
wsize = 6, 
basecyc = 1:6,
base = 0, 
border = NULL,
plot = TRUE,
verbose = TRUE,
...)
{
  if (class(object)[1] != "pcrfit") stop("object must be of class 'pcrfit'!")
   
  PARS <- list(...)$pars
  OPT <- list(...)$opt
    
  X <- object$DATA[, 2] 
  
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
        
  ## baseline sequence
  MIN <- min(X[basecyc], na.rm = TRUE)
  MAX <- max(X[basecyc], na.rm = TRUE)    
  MEAN <- mean(X[basecyc], na.rm = TRUE)
  SD <- sd(X[basecyc], na.rm = TRUE)
          
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
  parMAT <- matrix(nrow = nrow(GRID), ncol = 2)
    
  ## iterate over all wsize/base and sliding window combinations
  for (i in 1:nrow(GRID)) {
    if (verbose) counter(i)     
    
    ## subtract baseline value
    modX <- X - GRID[i, 3]        
         
    ## calculate efficiencies
    Y <- c(NA, tail(modX, -1)/head(modX, -1))
               
    ## linear regression on sliding window    
    win <- GRID[i, 1]:GRID[i, 4]  
    winX <- modX[win]   
    winY <- Y[win]   
          
    LM <- try(lm(winY ~ winX), silent = TRUE)  
    if (inherits(LM, "try-error")) next
    COEF <- coef(LM)  
    if (any(is.na(COEF))) next
        
    ## get parameters
    RSQ <- as.numeric(Rsq(LM))
    EFF <- COEF[1]
    parMAT[i, ] <- c(RSQ, EFF)      
        
    ## plot cycles vs log data and regression curve
    if (plot) {      
      plot(modX, Y, xlab = "Raw fluorescence", ylab = "Efficiency", cex.axis = 1.3, cex.lab = 1.5, ylim = c(-1, 3), 
           main = paste(expression(R^2), ":", round(RSQ, 5), "\nEff:", round(EFF, 3), "    Cycles", deparse(win)))
      points(winX, winY, cex = 1, pch = 16, col = 2)
      abline(LM, col = 2)
      abline(h = GRID[i, 3], col = 4)
    }    
  }
  
  resMAT <- cbind(GRID, parMAT)
  names(resMAT) <- c("lower", "wsize", "base", "upper", "rsq", "eff")
  
  ## remove NA entries that failed to fit
  resMAT <- na.omit(resMAT)
  
  ## find best iteration based on R-square and Eff <= 2  
  resMAT <- resMAT[resMAT[, 6] <= 2 & resMAT[, 6] >= 1, ]  
  
  ## select best r-square
  SEL <- which.max(resMAT[, 5])  
  
  ## run 'sliwin' with optimal parameters
  optPAR <- resMAT[SEL, ]
          
  ## one more go with optimized parameters
  if (is.null(PARS)) {    
    res <- LRE(object, wsize = as.numeric(optPAR[2]), border = as.numeric(optPAR[1]), 
                  base = as.numeric(optPAR[3]), plot = plot, verbose = verbose, pars = resMAT, opt = 1)
    return(res)
  }
  
  if (verbose) cat("\n")
   
  ## calculate F0 by classical method using single efficiency Emax
  ## and threshold cycle cpD2 to calculate F0
  EFF <- COEF[1]
  FLUO <- predict(object, newdata = data.frame(Cycles = cpD2))
  INIT1 <- as.numeric(FLUO/(EFF^cpD2))
  
  ## calculate F0 by new method using Emax and deltaE of all efficiencies
  ## and threshold cycle cpD2 to calculate F0
  CYC <- floor(cpD2)
  fluoCYC <- predict(object, newdata = data.frame(Cycles = CYC))
  vecFLUO <- object$DATA[1:CYC, 2]
  vecEFF <- COEF[1] + COEF[2] * vecFLUO  
  INIT2 <- as.numeric(fluoCYC/prod(vecEFF, na.rm = TRUE)) 
  
  ## return parameters
  if (!is.null(PARS)) resMAT <- PARS
  return(list(eff = as.numeric(optPAR[6]), rsq = as.numeric(optPAR[5]), 
              base = as.numeric(optPAR[3]), window = as.numeric(c(optPAR[1], 
              optPAR[4])), parMat = resMAT, init1 = INIT1, init2 = INIT2))
}

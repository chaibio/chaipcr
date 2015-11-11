meltcurve <- function(
data, 
temps = NULL, 
fluos = NULL, 
window = NULL, 
norm = FALSE, 
span.smooth = 0.05, 
span.peaks = 51,
is.deriv = FALSE, 
Tm.opt = NULL, 
Tm.border = c(1, 1),
plot = TRUE, 
peaklines = TRUE,
calc.Area = TRUE,
plot.Area = TRUE,
cut.Area = 0,
...)
{
  options(warn = -1)
  if (is.null(temps)) temps <- seq(from = 1, to = ncol(data), by = 2) 
  if (is.null(fluos)) fluos <- seq(from = 2, to = ncol(data), by = 2)
  if (length(temps) != length(fluos)) stop("Numbers of temperature columns and fluorescence columns do not match!")
  if (calc.Area == FALSE) plot.Area <- FALSE
  
  NAMES <- colnames(data[, fluos, drop = FALSE])  
  
  ### create dataframes with temp and fluo values
  TEMPS <- data[, temps, drop = FALSE]
  FLUOS <- data[, fluos, drop = FALSE]    
   
  ### define grid 
  if (!is.null(Tm.opt)) {
    SM.seq <- seq(0, 0.2, by = 0.01)
    SP.seq <- seq(11, 201, by = 10)
    GRID <- expand.grid(SM.seq, SP.seq)      
  } else 
    GRID <- matrix(c(span.smooth, span.peaks), nrow = 1) 
    
  ### create output list
  outLIST <- vector("list", length = ncol(TEMPS))   
    
  ### iterate over all samples  
  for (i in 1:ncol(TEMPS)) {
    cat(NAMES[i], "\n")
    TEMP <- TEMPS[, i]
    FLUO <- FLUOS[, i]      
    
    ### cut off unimportant temperature regions
    if (!is.null(window)) {
      SEL <- which(TEMP <= window[1] | TEMP > window[2])
      TEMP <- TEMP[-SEL]
      FLUO <- FLUO[-SEL]
    }       
    
    ### optionally normalize fluo values
    if (norm) FLUO <- rescale(FLUO, 0, 1)    
    
    ### define result matrix 
    resMAT <- matrix(nrow = nrow(GRID), ncol = 3)
    
    ### iterate over GRID and get result for best parameters
    ### (lowest RSS) 
    for (j in 1:nrow(GRID)) {
      counter(j)
      RES <- try(TmFind(TEMP = TEMP, FLUO = FLUO, span.smooth = GRID[j, 1], span.peaks = GRID[j, 2], is.deriv = is.deriv, Tm.opt = Tm.opt), silent = TRUE)
      if (inherits(RES, "try-error")) next
      resMAT[j, ] <- c(RES$Pars[1:2], RES$RSS[1])      
    }
    
    if (!is.null(Tm.opt)) {
      resMAT <- resMAT[order(resMAT[, 3]), ]        
      bestPAR <- resMAT[1, 1:2]
      RES <- try(TmFind(TEMP = TEMP, FLUO = FLUO, span.smooth = bestPAR[1], span.peaks = bestPAR[2], is.deriv = is.deriv, Tm.opt = Tm.opt), silent = TRUE)
      if (inherits(RES, "try-error")) RES <- NA
    }   
    
    ### calculation of peak area by 'peakArea'
    tempDATA <- RES$Temp
    meltDATA <- RES$Fluo
    derivDATA <- RES$df.dT
    TMs <- RES$Tm
    TMs <- TMs[!is.na(TMs)]
    PA <- numeric(length = length(TMs)) 
    baseLIST <- vector("list", length = length(TMs))     

    if (calc.Area) {
      for (k in 1:length(TMs)) {
        WHICH <- which(tempDATA > TMs[k] - Tm.border[1] & tempDATA < TMs[k] + Tm.border[2])
        X <- tempDATA[WHICH]
        Y <- derivDATA[WHICH]           
        PEAKAREA <- try(peakArea(X, Y), silent = TRUE)
        if (!inherits(PEAKAREA, "try-error")) {
          PA[k] <- PEAKAREA$area
          BL <- PEAKAREA$baseline
        } else PA[k] <- BL <- NA     
        
        baseLIST[[k]] <- cbind.na(Temp = X, baseline = BL)                           
      }         
      
      ### remove TMs if peak area < cutoff
      SEL <- which(PA < cut.Area | is.na(PA))
      if (length(SEL) > 0) {
        PA <- delete(PA, SEL, fill = TRUE)
        BL <- NA
        RES$Tm <- delete(RES$Tm, SEL, fill = TRUE)
      }           
        
      ### attach peak area values
      RES <- cbind.na(RES, Area = PA)      
      
      ### attach baseline area values to
      ### the corresponding temperature values
      RES <- cbind.na(RES, baseline = NA)
      for (m in 1:length(baseLIST)) {
        MATCH <- match(baseLIST[[m]][, 1], RES$Temp)
        RES$baseline[MATCH] <- baseLIST[[m]][, 2]       
      }        
    
    }  
    
    ### flag meltcurve as 'failed' if all peak areas < cut.Area
    if (all(is.na(RES$Area))) attr(RES, "quality") <- "bad" else attr(RES, "quality") <- "good"          
    
    ### create output list
    outLIST[[i]] <- RES
    
    cat("\n\n")
  }
    
  ### plotting setup and x-y-y plot
  if (plot) {    
    DIM <- ceiling(sqrt(length(outLIST)))   
    par(mfrow = c(DIM, DIM))
    for (i in 1:length(outLIST)) {
      ### plot raw melt data and first derivatives
      ### including identified melting points   
      tempDATA <- outLIST[[i]]$Temp
      meltDATA <- outLIST[[i]]$Fluo
      derivDATA <- outLIST[[i]]$df.dT
      baseDATA <- outLIST[[i]]$baseline       
      TMs <- outLIST[[i]]$Tm        
             
      xyy.plot(tempDATA, meltDATA, if (!is.deriv) derivDATA, main = NAMES[i], 
                      y1.par = list(xlab = "", ylab = "", type = "l", lwd = 2),
                      y2.par = list(xlab = "", ylab = "", type = ifelse(is.deriv, "n", "l"), lwd = 2, main = "", text = ""),
                      first = par(mar = c(3, 2, 2, 3)), 
                      y1.last = if (peaklines) abline(v = TMs, lwd = 1, lty = 2, ...) else NULL, 
                      y2.last = if (plot.Area) segments(tempDATA, baseDATA, tempDATA, derivDATA, col = 2) else NULL, 
                      ...)      
    }
  }   
         
  return(outLIST)           
}

     

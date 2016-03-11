# customized by Xiaoqing Rong-Mullins 2015-11-16

meltcurve <- function(
data, 
temps = NULL, 
fluos = NULL, 
window = NULL, 
norm = FALSE, 
temp_shoulder = NULL, # xqrm
# span.smooth = 0.05, # ori
span_smooth_factor = NULL, # xqrm
span_smooth_default = NULL, # xqrm
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
  # xqrm: start counting for running time
  func_name <- 'meltcurve'
  start_time <- proc.time()[['elapsed']]
  
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
    GRID_not_determined <- FALSE # xqrm
  } else 
    #GRID <- matrix(c(span.smooth, span.peaks), nrow = 1) # ori
    GRID_not_determined <- TRUE # xqrm
    
  ### create output list
  outLIST <- vector("list", length = ncol(TEMPS))   
    
  ### iterate over all samples  
  for (i in 1:ncol(TEMPS)) {
    
    # xqrm: start counting for running time
    start_time_for <- proc.time()[['elapsed']]
    
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
    
    
    # start: xqrm: determine span_smooth
    
    len1 <- length(TEMP)
    central_fluo_temp = TEMP[order(FLUO)[as.integer(len1 / 2)]] # the temperature for approximately median fluo value
    considered_indices <- which(TEMP >= central_fluo_temp - temp_shoulder & TEMP <= central_fluo_temp + temp_shoulder)
    considered_temp <- TEMP[considered_indices]
    considered_fluo <- FLUO[considered_indices]
    
    len2 <- length(considered_indices)
    trend_mtx <- as.data.frame(cbind(1:len2, 
                                     considered_temp, c(considered_temp[2:len2], NA), 
                                     considered_fluo, c(considered_fluo[2:len2], NA)))
    colnames(trend_mtx) <- c('count', 'TEMP', 'TEMP_next', 'FLUO', 'FLUO_next')
    trend_mtx[,'TEMP_diff'] <- trend_mtx[,'TEMP_next'] - trend_mtx[,'TEMP']
    trend_mtx[,'FLUO_diff'] <- trend_mtx[,'FLUO_next'] - trend_mtx[,'FLUO']
    
    trend_positive <- trend_mtx[trend_mtx[,'FLUO_diff'] > 0,]
    
    if (all(is.na(trend_positive))) {
      span_smooth <- span_smooth_default
    } else {
      len3 <- dim(trend_positive)[1]
      trend_positive[,'count_diff'] <- c(trend_positive[2:len3, 'count'], NA) - trend_positive[,'count']
      trend_seps <- which(trend_positive[,'count_diff'] > 1)
      trend_starts <- c(1, trend_seps + 1)
      trend_ends <- c(trend_seps, len3 - 2)
      
      len4 <- length(trend_seps) + 1
      temp_intervals <- sapply(1:len4, function(i) sum(trend_positive[trend_starts[i]:trend_ends[i], 'TEMP_diff'])) # temperature intervals where fluo value increases
      max_temp_interval <- max(temp_intervals)
      span_smooth <- span_smooth_factor * max_temp_interval
      
      # # to test
      message('central_fluo_temp: ', central_fluo_temp)
      # print(trend_mtx)
      # print(trend_positive)
      # print(cbind(trend_starts, trend_ends))
      # print(temp_intervals)
       message('max_temp_interval: ', max_temp_interval)
      
      }
    
    if (GRID_not_determined) GRID <- matrix(c(span_smooth, span.peaks), nrow = 1)
    
    # end: xqrm: determine span_smooth
    
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
    
      if (length(TMs) == 0) { # xqrm
        RES <- cbind.na(RES, Area=NA, baseline=NA) # xqrm
        
      } else { # xqrm
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
    }  
    
    ### flag meltcurve as 'failed' if all peak areas < cut.Area
    if (all(is.na(RES$Area))) attr(RES, "quality") <- "bad" else attr(RES, "quality") <- "good"          
    
    ### create output list
    outLIST[[i]] <- RES
    
    cat("\n\n")
    
    # xqrm: report time cost for this function
    end_time_for <- proc.time()[['elapsed']]
    message('iteration ', i, ' took ', round(end_time_for - start_time_for, 2), ' seconds.\n')
    
  } # xqrm: end: for loop
    
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
         
  # xqrm: report time cost for this function
  end_time <- proc.time()[['elapsed']]
  message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
  
  return(outLIST)           
}

     

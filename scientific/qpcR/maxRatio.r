maxRatio <- function(x, 
method = c("spline", "sigfit"),
baseshift = NULL, 
smooth = TRUE,  
plot = TRUE,
...)
{
  method <- match.arg(method)
  if (class(x) == "pcrfit") ml <- modlist(x) else ml <- x    
  COLS <- rainbow(length(ml))   
  
  RES <- lapply(ml, function(x) eff(x, method = switch(method, spline = "spline", sigfit = "sigfit"), 
                                    baseshift = baseshift, smooth = smooth, plot = FALSE, ...))
  
  RATIO <- round(sapply(RES, function(x) x$effmax.y), 3) - 1     
  FCN <- sapply(RES, function(x) x$effmax.x) 
  FCNA <- round(FCN - log2(RATIO), 2)       
  NAMES <- sapply(ml, function(x) x$names)   

  if (plot) {
    par(mfrow = c(3, 1))     
    par(mar = c(5, 5, 1, 1))       
    plot(ml, col = COLS, ...)
    par(mar = c(5, 5, 1, 1))
    
    xmin <- min(sapply(RES, function(x) min(x$eff.x, na.rm = TRUE)), na.rm = TRUE)
    xmax <- max(sapply(RES, function(x) max(x$eff.x, na.rm = TRUE)), na.rm = TRUE)
    ymin <- min(sapply(RES, function(x) min(x$eff.y, na.rm = TRUE)), na.rm = TRUE)
    ymax <- max(sapply(RES, function(x) max(x$eff.y, na.rm = TRUE)), na.rm = TRUE)      
   
    plot(RES[[1]]$eff.x, RES[[1]]$eff.y - 1, type = "n", col = COLS[1],
         xlab = "Cycles", ylab = "Ratio", xlim = c(xmin, xmax), ylim = c(ymin, ymax), ...)
    
    sapply(1:length(RES), function(x) lines(RES[[x]]$eff.x, RES[[x]]$eff.y, col = COLS[x], ...))    
    abline(v = FCN, col = COLS)     
    par(mar = c(5, 5, 1, 1))
    plot(FCN, RATIO, pch = 16, col = COLS, ylab = "MR", ...)
  }                   
  return(list(eff = RATIO + 1, mr = RATIO, fcn = FCN, fcna = FCNA, names = NAMES))
}


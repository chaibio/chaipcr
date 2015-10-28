resplot <- function(object, overlay = TRUE, ylim = NULL, ...)
{
  ## extract residuals
  RESID <- try(as.numeric(residuals(object)), silent = TRUE)
  if (inherits(RESID, "try-error")) stop("'object' does not have any residuals!")
  
  ## sum-up all residuals from possible replicates
  ALL <- fetchData(object)
  X <- ALL$data[, ALL$pred.pos]
  RESID <- tapply(RESID, X, function(x) sum(abs(x), na.rm = TRUE))  
  RESID <- as.numeric(scale(RESID))
 
  ## calculate order and define colour vector
  ORD <- order(abs(RESID))
  COL <- vector()
  LEN <- 1:length(RESID)
  COL[ORD] <- LEN
  
  ## only residuals
  if (!overlay) {
    barplot(RESID, col = rev(heat.colors(length(RESID)))[COL],
             ylab = "Standardized residual value", ylim = c(1.2 * min(RESID), 1.2 * max(RESID)), ...)
  } else {
    ## overlay plot
    par(mar = c(5.1, 4.1, 4.1, 4.1))
    if (is.null(ylim)) YLIM <- c(2 * min(RESID), 2 * max(RESID)) else YLIM <- ylim
    plot(object)   
    par(new = TRUE)
    BP <- barplot(RESID, space = 0.8, axes = FALSE, plot = FALSE)
    barplot(RESID, space = 0.8, axes = FALSE, xlim = c(min(BP), max(BP)), axisnames = FALSE,
            col = rev(heat.colors(length(RESID)))[COL], ylim = YLIM, ...)
    axis(side = 4)
    mtext("Standardized residual value", side = 4, line = 2.5)
  }
}

eff <- function(
object, 
method = c("sigfit", "spline"), 
sequence = NULL,
baseshift = NULL, 
smooth = FALSE,   
plot = FALSE) 
{
    method <- match.arg(method)
        
    if (is.null(sequence)) {
      MIN <- min(object$DATA[, 1], na.rm = TRUE)
      MAX <- max(object$DATA[, 1], na.rm = TRUE)
      DIVS <- 0.01        
    } else {
      MIN <- sequence[1]
      MAX <- sequence[2]
      DIVS <- sequence[3]      
    }    
    SEQ <- seq(MIN, MAX, by = DIVS)     
    
    if (method == "sigfit") {            
      coefVec <- coef(object)        
      FCT <- object$MODEL$fct 
      F1 <- FCT(SEQ, coefVec)  
      F2 <- FCT(SEQ - 1, coefVec)     
      EFFres <- F1/F2
      maxCYC <-  SEQ[which.max(EFFres)]
      EFFres.D1 <- NULL
      EFFres.D2 <- NULL     
    }
    
    if (method == "spline") {
      X <- object$DATA[, 1]       
      Y <- object$DATA[, 2]      
        
      if (smooth) {
        Y <- c(rep(Y[1], 2), Y, rep(tail(Y, 1), 2))
        Y <- filter(Y, rep(0.2, 5))
        Y <- Y[-c(1, 2, length(Y) - 1, length(Y))]               
      }         
      
      if (is.null(baseshift)) SHIFT <- 0
      else if (is.numeric(baseshift)) SHIFT <- baseshift
      else stop("'baseshift' must be either 'NULL' or numeric!")  
      
      Y <- Y + SHIFT           
      N <- round(1/DIVS, 1)        
      FLUO1 <- tail(Y, -1)        
      FLUO2 <- head(Y, -1)        
      sY <- FLUO1/FLUO2       
      sX <- tail(X, -1)       
      SPLINE <- splinefun(sX, sY)     
      EFFres <- SPLINE(SEQ, deriv = 0)          
      maxCYC <-  round(SEQ[which.max(EFFres)], 2)             
    }               
   
    if (plot) {
      plot(SEQ, EFFres, xlab = "Cycles", ylab = "Efficiency")
      abline(v = maxCYC, col = 2, lwd = 2)
      mtext(maxCYC, side = 1, at = maxCYC, col = 2)
    }
    return(list(eff.x = SEQ, eff.y = EFFres, effmax.x = maxCYC, effmax.y = max(EFFres, na.rm = TRUE)))
}
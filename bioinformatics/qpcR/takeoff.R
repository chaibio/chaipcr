takeoff <- function(object, pval = 0.05, nsig = 3)
{
      ## extract x, y values
      CYC <- object$DATA[, 1]
      FLUO <- object$DATA[, 2]
      RES <- vector()
      
      ## calculate studententized residuals over moving window
      for (i in 5:length(CYC)) {
            MOD <- lm(FLUO[1:i] ~ CYC[1:i], na.action = na.exclude)
            ST <- rstudent(MOD)   
            ST1 <- tail(ST, 1)            
            PST1 <- 1 - pt(ST1, df = MOD$df.residual)           
            RES <- c(RES, PST1)            
      }
      
      ## calculate p-value events
      SIG <- sapply(RES, function(x) x < pval) 
      SIG[is.na(SIG)] <- FALSE
      
      ## which nsig cycles are TRUE? (outliers)
      selTOP <- sapply(1:length(SIG), function(x) all(SIG[x:(x + nsig - 1)]))
      minTOP <- min(which(selTOP == TRUE), na.rm = TRUE)
      TOP <- as.numeric(names(SIG[minTOP]))                    
      
      fluoTOP <- as.numeric(predict(object, newdata = data.frame(Cycles = TOP)))
      return(list(top = TOP, f.top = fluoTOP))
}
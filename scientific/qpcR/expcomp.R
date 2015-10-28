expcomp <- function(object, ...)
{ 	 		
  fList <- list(b4, b5, b6, b7, l4, l5, l6, l7)
	fnList <- lapply(fList, function(x) x$name)
  print("Fitting all sigmoidal models...")
  flush.console()
	modList <- lapply(fList, function(x) pcrfit(object$DATA, 1, 2, x, verbose = FALSE))   
	
	EXP <- expfit(object, plot = FALSE, ...)
	expMod <- EXP$mod
	expReg <- EXP$cycles

	RMSEs <- sapply(modList, function(x) RMSE(x, which = expReg))
	RMSEs <- c(RMSEs, EXP$RMSE)  	
	
	modList <- c(modList, list(expMod))
	fnList <- c(fnList, "expGrowth")
  cols <- rk <- rank(RMSEs)
  cols[cols != 1] <- "grey"   
	cols[cols == 1] <- "red"   
	lwds <- rep(1, length(RMSEs))
	lwds[cols != "grey"] <- 3    
				
	for (i in 1:length(modList)) {
		if (i == 1) plot(modList[[i]], col = cols[i], subset = c(min(expReg) - 3, max(expReg) + 3),
						            lwd = lwds[i], main = "Fitting within the exponential region")
		else plot(modList[[i]], add = TRUE, col = cols[i], lwd = lwds[i])
	}
	return(cbind(model = fnList[order(rk)], RMSE = RMSEs[order(rk)]))
}	

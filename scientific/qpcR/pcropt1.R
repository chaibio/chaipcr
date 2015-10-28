pcropt1 <- function (object, fact = 3, opt = FALSE, plot = TRUE, bubble = NULL, ...) 
{
  
  START <- try(efficiency(object, plot = FALSE))
  if (inherits(START, "try-error")) stop("Could not initialize optimization. Please try different 'fact'!")
  
  ## calculate bordr values to iterate in
  cpD1 <- round(START$cpD1)
  cpD2 <- round(START$cpD2)
  LOWER <- round(cpD1 - fact * (cpD1 - cpD2))
  UPPER <- round(cpD1 + fact * (cpD1 - cpD2))    
  seqLOWER <- 1:LOWER
  seqUPPER <- nrow(object$DATA):UPPER   
  
  ## counter for initializing result matrix
  counter <- 1
    
  for (i in seqLOWER) {
    counter(i)
    for (j in seqUPPER) {      
      ## data subset
      newDAT <- object$DATA[i:j, ]   
      ## new model from subset
      newMOD <- try(pcrfit(newDAT, 1, 2, model = object$MODEL, verbose = FALSE), silent = TRUE)
      if (inherits(newMOD, "try-error")) next    
      ## optional model selection
      if (opt) newMOD <- mselect(newMOD, verbose = FALSE, ...)       
      ## efficiency parameters
      EFF <- try(efficiency(newMOD, plot = plot, ...), silent = TRUE)   
      if (inherits(EFF, "try-error")) next
      ## goodness-of-fit
      GOF <- pcrGOF(newMOD)
      ## initialize result matrix at first iteration
      vecGOF <- unlist(GOF)
      vecEFF <- unlist(EFF)[c("eff", "init1", "init2")]
      RES <- c(i, j, vecGOF, vecEFF)
      if (counter == 1) resMAT <- matrix(nrow = length(seqLOWER) * length(seqUPPER), ncol = length(RES))
      
      ## store results in matrix and increase counter
      resMAT[counter, ] <- RES 
      counter <- counter + 1
      }
    }
  
    cat("\n")
  
    ## make coulumn names
    colnames(resMAT) <- c("lower", "upper", names(vecGOF), names(vecEFF))
  
    ## make bubble plot from the parameter selected in 'bubble'
    if (!is.null(bubble)) {
      Z <- try(resMAT[, bubble], silent = TRUE)
      if (!inherits(Z, "try-error")) {
        bubbleplot(resMAT[, 1], resMAT[, 2], rank(Z), scale = 0.1, las = 1,
                   xlab = "Lower cycle number", ylab = "Upper cycle number")        
      } else print("Parameter could not be extracted from result matrix! Omitting bubbleplot...")
    }
            
    return(resMAT)
}

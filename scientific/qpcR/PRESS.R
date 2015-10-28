PRESS <- function(object, verbose = TRUE)
{
  ## fetch data and predictor/response columns
  fetchDATA <- fetchData(object)
  DATA <- fetchDATA$data
  PRED.pos <- fetchDATA$pred.pos
  RESP.pos <- fetchDATA$resp.pos
  PRED.name <- fetchDATA$pred.name
  PRESS.res <- vector("numeric", nrow(DATA))
 
  ## calculate PRESS by Leave-One-Out refitting
  for (i in 1:nrow(DATA)) {
    if (verbose) {
      counter(i)  
      flush.console()
    }
     
    ## omit data
    newDATA <- DATA[-i, ]    
    
    ## update new Model without data
    if (class(object) == "pcrfit") newMOD <- pcrfit(newDATA, cyc = 1, fluo = 2, model = object$MODEL, verbose = FALSE) 
    else newMOD <- update(object, data = newDATA)
    
    newPRED <- as.data.frame(DATA[i, PRED.pos])
    colnames(newPRED) <- PRED.name
    ## predict omitted data by refitted model
    y.hat <- as.numeric(predict(newMOD, newdata = newPRED))
    PRESS.res[i] <- DATA[i, RESP.pos] - y.hat
  }
  
  if (verbose) cat("\n")
  
  ## PRESS statistic and P-square
  Yi <- residuals(object) - fitted(object)
  TSS <- sum((Yi - mean(Yi))^2)
  RSS <- sum(PRESS.res^2)
  P.square <- 1 - (RSS/TSS)    

  return(list(stat = sum(PRESS.res^2), residuals = PRESS.res, P.square = P.square))
}
  
  

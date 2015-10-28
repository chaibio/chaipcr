fitchisq <- function(object, error = NULL)
{
  if (any(class(object) == "replist")) object <- object[[1]] else object <- object
    
  ### fetch predictor and response values
  fetchDATA <- fetchData(object)
  DATA <- fetchDATA$data
  PRED.pos <- fetchDATA$pred.pos
  RESP.pos <- fetchDATA$resp.pos
  PRED.name <- fetchDATA$pred.name
  PRED <- DATA[, PRED.pos]
  RESP <- DATA[, RESP.pos]

  ### if replicates are available, calculate s.d.
  if (length(PRED) > length(unique(PRED))) {
    error <- tapply(RESP, PRED, function(x) sd(x, na.rm = TRUE))
  } 
  ### if not, and error == NULL return unevaluated
  else if (is.null(error)) return(list(chi2 = NA, chi2.red = NA, p.value = NA))
  ### if not, and error is given, replicate error values
  else {
    ### if error vector is supplied, check for length
    if (length(error) > 1 && length(error) != length(RESP))
       stop(paste("'error' vector must have the same length as response values! (", length(RESP), ")", sep = ""))
    ### else replicate error value to length
    else {
         error <- rep(error, length.out = length(DATA[, PRED.pos]))
         names(error) <- DATA[, PRED.pos]
    }
  }      
    
  res <- residuals(object)
  n <- length(res)
  p <- length(coef(object))
  df <- n - p
  m <- match(DATA[, PRED.pos], names(error))
  ### calculate chi-square
  CHISQ <- sum(res^2/error[m]^2)
  ### calculate reduces chi-square
  CHISQ.red <- CHISQ/df
  ### calculate chi-square fit probability
  p.value <- 1 - pchisq(CHISQ, df)
  
  return(list(chi2 = CHISQ, chi2.red = CHISQ.red, p.value = p.value))
}

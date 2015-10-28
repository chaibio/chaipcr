RSS <- function(object)
{
  w <- object$weights
  r <- residuals(object)
  if (is.null(w)) w <- rep(1, length(r))
  sum(w * residuals(object)^2)    	
} 

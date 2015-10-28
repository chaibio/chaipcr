Rsq <- function(object)
{
  w <- object$weights
  r <- residuals(object)
  f <- fitted(object)
  if (is.null(w)) w <- rep(1, length(f))
  rss <- sum(w * residuals(object)^2)
  Yi <- residuals(object) - fitted(object)
  m <- sum(w * Yi)/sum(w)
  tss <- sum(w * (Yi - m)^2)
  1 - (rss/tss)
}


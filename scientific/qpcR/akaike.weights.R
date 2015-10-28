akaike.weights <- function(x)
{
      x <- x[!is.na(x)]
      delta.aic <- x - min(x, na.rm = TRUE)
      rel.LL <- exp(-0.5 * delta.aic)
      sum.LL <- sum(rel.LL, na.rm = TRUE)
      weights.aic <- rel.LL/sum.LL
      return(list(deltaAIC = delta.aic, rel.LL = rel.LL, weights = weights.aic))
}
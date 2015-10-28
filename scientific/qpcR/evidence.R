evidence <- function(x, y, type = c("AIC", "AICc", "BIC"))
{
  type <- match.arg(type)

  if (!is.numeric(x) && !is.numeric(y)) {
    x1 <- switch(type, AIC = AIC(x), AICc = AICc(x), BIC = BIC(x))
    y1 <- switch(type, AIC = AIC(y), AICc = AICc(y), BIC = BIC(y))
  } else {
    if (is.numeric(x) && is.numeric(y)) {
      x1 <- x
      y1 <- y
    } else {
      stop("Input must (both) be either a fitted model or numeric!")
    }
  }  	
	1/(exp(-0.5 * (y1 - x1)))	
}


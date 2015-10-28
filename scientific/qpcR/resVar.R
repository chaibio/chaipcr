resVar <- function(object)
{
	rss <- sum(residuals(object)^2)
    	n <- length(residuals(object))
    	p <- length(coef(object))
    	rss/(n - p)
} 

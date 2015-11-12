RMSE <- function(object, which = NULL)
{
	if (is.null(which)) which <- 1:length(residuals(object))
    	sqrt(mean(residuals(object)[which]^2, na.rm = TRUE))
}
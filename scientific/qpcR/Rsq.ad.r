Rsq.ad <- function(object) 
{
    n <- length(residuals(object))
    p <- length(coef(object))        
    rsq <- Rsq(object)          
    1 - (n - 1)/(n - p) * (1 - rsq)    
}


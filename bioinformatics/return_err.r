# return_err

return_err <- function(func, ...) {
    return(tryCatch(func(...), error=function(e) e))
    }


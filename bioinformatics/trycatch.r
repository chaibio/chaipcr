# tryCatchError

tryCatchError <- function(func, ...) {
    return(tryCatch(func(...), error=function(e) e))
    }


is.outlier <- function(object)
{
  if (!(class(object)[1] == "modlist")) stop("object must be of class 'modlist'")  
  OUTL <- sapply(object, function(x) x$isOutlier)
  NAMES <- sapply(object, function(x) x$names)
  names(OUTL) <- NAMES
  return(OUTL)
}
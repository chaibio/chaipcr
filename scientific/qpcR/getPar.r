getPar <- function(x, type = c("fit", "curve"), cp = "cpD2", eff = "sigfit", ...) 
{
  type <- match.arg(type)
  options(expressions = 20000)  
  
  if (class(x)[1] == "pcrfit") x <- modlist(x)
  if (class(x)[1] != "modlist") stop("'x' must be either of class 'pcrfit' or 'modlist'!")
  
  ## extract unique model names
  modNAMES <- sapply(x, function(x) x$MODEL$name)
  modNAMES <- unique(modNAMES[!is.na(modNAMES)])
  if (modNAMES %in% c("mak2", "mak3", "chag", "cm3")) type <- "fit"
  
  ## rownames and their length
  if (type == "fit") {
    RN <- lapply(x, function(x) names(coef(x)))
    RN <- unique(unlist(RN)) 
    RN <- na.omit(RN)
    NR = length(RN)
  } else {
    RN <- c("ct", "eff")
    NR = 2 
  }
  
  ## pre-allocate matrix
  RES <- matrix(nrow = NR, ncol = length(x))  
  NAMES <- sapply(x, function(a) a$name)
  
  for (i in 1:length(x)) {
    counter(i)
    flush.console()
    tempMOD <- x[[i]]     
    
    ## coefficients from fit
    if (type == "fit") {
      COEF <- try(coef(tempMOD), silent = TRUE)
      if (inherits(COEF, "try-error")) COEF <- NA
      if (length(COEF) > 0) RES[1:length(COEF), i] <- COEF
    }
    
    ## efficiency and threshold cycles  
    if (type == "curve") {
      outNAME <- switch(cp, "cpD2" = "cpD2", "cpD1" = "cpD1", "maxE" = "cpE", "expR" = "cpR", "Cy0" = "Cy0", "CQ" = "cpCQ", "maxRatio" = "cpMR", stop())
      tempRES <- tryCatch(efficiency(tempMOD, plot = FALSE, type = cp, ...), error = function(e) NA)
      tempCT <- tryCatch(tempRES[[outNAME]], error = function(e) NA)
      RES[1, i] <- tempCT 
      RES[2, i] <- switch(eff, "sigfit" =  if (!is.na(tempRES)) tempRES$eff else NA,
                          "expfit" = tryCatch(expfit(tempMOD, plot = FALSE, ...)$eff, error = function(e) NA),
                          "sliwin" = tryCatch(sliwin(tempMOD, plot = FALSE, ...)$eff, error = function(e) NA))          
   }                       
  } 
  
  colnames(RES) <- NAMES
  rownames(RES) <- RN  
                   
  cat("\n")
  return(RES)
}
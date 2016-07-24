# customized by Xiaoqing Rong-Mullins. 2015-10-29.
# all the ', silent = FALSE' were added by xqrm

# getPar <- function(x, type = c("fit", "curve"), cp = "cpD2", eff = "sigfit", ...) # ori
# xqrm
getPar <- function(
    x, type = c("fit", "curve"), cp = "cpD2", eff = "sigfit",
    min_reliable_cyc,
    ...) 
{
  
  # xqrm: start counting for running time
  func_name <- 'getPar'
  start_time <- proc.time()[['elapsed']]
  
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
    
    # # ori
    # RN <- c("ct", "eff")
    # NR = 2
    
    # xqrm, for D1 and D2
    RN <- c("cq", "eff", "D1max", "D2max", "cpD1", "cpD2")
    NR <- 6
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
      #COEF <- try(coef(tempMOD), silent = TRUE) # ori
      COEF <- try(coef(tempMOD), silent = FALSE) # xqrm
      if (inherits(COEF, "try-error")) COEF <- NA
      if (length(COEF) > 0) RES[1:length(COEF), i] <- COEF
    }
    
    ## efficiency and threshold cycles  
    if (type == "curve") {
      outNAME <- switch(cp, "cpD2" = "cpD2", "cpD1" = "cpD1", "maxE" = "cpE", "expR" = "cpR", "Cy0" = "Cy0", "CQ" = "cpCQ", "maxRatio" = "cpMR", stop())
      # tempRES <- tryCatch(efficiency(tempMOD, plot = FALSE, type = cp, ...), # ori
                          #error = function(e) NA) # ori
      tempRES <- tryCatch(efficiency(tempMOD, plot = FALSE, type = cp, min_reliable_cyc = min_reliable_cyc, ...), # xqrm
                          error = err_NA) # xqrm
      tempCT <- tryCatch(tempRES[[outNAME]], 
                         #error = function(e) NA) # ori
                         error = err_NA) # xqrm
      RES[1, i] <- tempCT 
      RES[2, i] <- switch(eff, 
        "sigfit" =  if (!is.na(tempRES)) tempRES$eff else NA,
        "expfit" = tryCatch(expfit(tempMOD, plot = FALSE, ...)$eff, 
          #error = function(e) NA), # ori
          error = err_NA), # xqrm
        "sliwin" = tryCatch(sliwin(tempMOD, plot = FALSE, ...)$eff, 
          #error = function(e) NA)) # ori
          error = err_NA)) # xqrm
      # xqrm
      RES[3, i] <- tryCatch(tempRES[["D1max"]], error = err_NA)
      RES[4, i] <- tryCatch(tempRES[["D2max"]], error = err_NA)
      RES[5, i] <- tryCatch(tempRES[["cpD1"]], error = err_NA)
      RES[6, i] <- tryCatch(tempRES[["cpD2"]], error = err_NA)
   }                       
  } 
  
  colnames(RES) <- NAMES
  rownames(RES) <- RN  
                   
  cat("\n")
  
  # xqrm: report time cost for this function
  end_time <- proc.time()[['elapsed']]
  message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
  
  return(RES)
}
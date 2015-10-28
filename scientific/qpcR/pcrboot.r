pcrboot <- function(
object, 
type = c("boot", "jack"),  
B = 100, 
njack = 1,
plot = TRUE, 
do.eff = TRUE, 
conf = 0.95, 
verbose = TRUE,
...)
{
  type <- match.arg(type)
  
  if (class(object) != "pcrfit") stop("Use only with objects of class 'pcrfit'!")   
    
  ## get data from object
  fetchDATA <- fetchData(object)
  DATA <- fetchDATA$data
  PRED.pos <- fetchDATA$pred.pos
  RESP.pos <- fetchDATA$resp.pos
  PRED.name <- fetchDATA$pred.name
  
  ## fitted and residuals
  fitted1 <- fitted(object)    
  resid1 <- residuals(object)   
  modLIST <- vector("list", length = B)
  effLIST <- vector("list", length = B)    
  NR <- nrow(DATA)  
  noCONV <- 0     
  
  ## for each iteration do...
  for (i in 1:B) {    
    newDATA <- DATA   
    
    if (verbose) {
      counter(i) 
      flush.console()
    }
  
    if (type == "boot") newDATA[, RESP.pos] <- fitted1 + sample(scale(resid1, scale = FALSE), replace = TRUE)
    else {
      sampleVec <- sample(1:NR, njack)    
      newDATA <- newDATA[-sampleVec, ]      
    }       
    
    ## new model based on bootstrap
    newMODEL <- try(pcrfit(data = newDATA, cyc = 1, fluo = 2, model = object$MODEL, verbose = FALSE), silent = TRUE)  
       
    if (inherits(newMODEL, "try-error")) {
      noCONV <- noCONV +  1
      next
    }                
    
    if (plot) plot(newMODEL, ...)
    
    modLIST[[i]] <- list(coef = coef(newMODEL), sigma = summary(newMODEL)$sigma,
                         rss = sum(residuals(newMODEL)^2), 
                         dfb = abs(coef(newMODEL) - coef(object))/(summary(object)$parameters[, 2]),
                         gof = pcrGOF(newMODEL)) 
    
    ## get efficiencies
    if (do.eff) {
      EFF <- try(efficiency(newMODEL, plot = FALSE, ...)[c(1, 7:18)], silent = TRUE)
      if (inherits(EFF, "try-error")) effLIST[[i]] <- NA else effLIST[[i]] <- EFF        
    }
  }
  
  cat("\n\n")
  if (verbose) cat("fitting converged in ", 100 - (noCONV/B), "% of iterations.\n\n", sep = "")      
  
  COEF <- t(sapply(modLIST, function(z) z$coef))  
  RSE <- sapply(modLIST, function(z) z$sigma)  
  RSS <- sapply(modLIST, function(z) z$rss)           
  GOF <- t(sapply(modLIST, function(z) unlist(z$gof))) 
  
  ## combine data
  effDAT <- t(sapply(effLIST, function(z) unlist(z)))    
  statLIST <- list(coef = COEF, rmse = RSE, rss = RSS, gof = GOF, eff = effDAT) 
  confLIST <- lapply(statLIST, function(x) t(apply(as.data.frame(x), 2, function(y) quantile(y, c((1 - conf)/2, 1 - (1 - conf)/2), na.rm = TRUE)))) 
    
  if (plot) {
    ndata <- sum(rapply(statLIST, function(x) ncol(x)))
    par(mfrow = c(6, 5))
    par(mar = c(1, 2, 2, 1))
    
    ## boxplot for each parameter
    for (i in 1:length(statLIST)) { 
      temp <- as.data.frame(statLIST[[i]])    
      if (is.vector(statLIST[[i]])) colnames(temp) <- names(statLIST)[i]      
      for (j in 1:ncol(temp)) {        
        if (all(is.na(temp[, j]))) next 
        COL <- switch(names(statLIST)[i], coef = 2, gof = 3, eff = 4)             
        boxplot(temp[, j], main = colnames(temp)[j], col.main = COL, outline = FALSE, ...)  
        abline(h = confLIST[[i]][j, ], col = 2, ...)    
      }    
    }           
   }  
  
  return(list(ITER = statLIST, CONF = confLIST))   
} 
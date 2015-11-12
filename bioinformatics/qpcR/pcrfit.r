pcrfit <- function(
data, 
cyc = 1, 
fluo, 
model = l4, 
start = NULL,
offset = 0, 
weights = NULL,
verbose = TRUE,  
...)
{            
  options(warn = -1)   
  if (!exists("control")) control <- nls.lm.control(maxiter = 1000, maxfev = 10000)
  
  ## version 1.3-4: create (stacked) data, depending on replicates
  if (length(fluo) == 1) {
    CYC <- data[, cyc]
    FLUO <- data[, fluo]
  } else {
    CYC <- rep(data[, cyc], length(fluo))
    FLUO <- stack(data[, fluo])[, 1]
    ssDATA <- rowMeans(data[, fluo], na.rm = TRUE)    
  }   
  
  ## define weights for nls
  if (is.null(weights)) WEIGHTS <- rep(1, length(FLUO))
  ## version 1.3-7: use an expression for weights
  if (is.character(weights)) WEIGHTS <- wfct(weights, CYC, FLUO, model = model,
                                             start = start, offset = offset, verbose = TRUE)
  if (is.numeric(weights)) WEIGHTS <- weights
  if (length(WEIGHTS) != length(FLUO)) stop("'weights' and 'fluo' have unequal length!")  
      
  ## eliminate NAs
  allDAT <- cbind(CYC, FLUO, WEIGHTS)
  tempDAT <- na.omit(allDAT)
  CYC <- tempDAT[, 1]
  FLUO <- tempDAT[, 2]
  WEIGHTS <- tempDAT[, 3]

  ## version 1.3-4: get selfStart values
  if (is.null(start)) {
    if (length(fluo) == 1) {
      ssVal <- model$ssFct(CYC, FLUO)
    } else {
      ssVal <- model$ssFct(data[, cyc], ssDATA)
    }
  } else ssVal <- start
  
  ## get attribute 'cutoff' transferred from ssFct
  ## version 1.3-4: offset parameter for 'cutoff' (usually SDM)
  SUB <- attr(ssVal, "cutoff")
  if (!is.null(SUB)) {  
    SUB <- SUB + offset
    SEL <- 1:SUB 
    CYC <- CYC[SEL]    
    FLUO <- FLUO[SEL]
    WEIGHTS <- WEIGHTS[SEL]
  }
  
  ## initialize parameter matrix
  ssValMat <- NULL
  ssValMat <- rbind(ssValMat, c("start", ssVal)) 
    
  names(ssVal) <- model$parnames      
        
  ## coerce to dataframe
  DATA <- as.data.frame(cbind(Cycles = CYC, Fluo = FLUO))  
      
  ## make nlsModel using 'nlsLM' from package 'minpack.lm'
  NLS <- nlsLM(as.formula(model$expr), data = DATA, start = as.list(ssVal), model = TRUE, 
              algorithm = "LM", control = control, weights = WEIGHTS, ...)
     
  ## attach parameter values to matrix
  ssValMat <- rbind(ssValMat, c(class(NLS), coef(NLS)))      
                
  ## modify 'object'
  NLS$DATA <- DATA     
  NLS$MODEL <- model  
  NLS$parMat <- ssValMat
  NLS$opt.method <- "LM"
  
  CALL <- as.list(NLS$call)     
  CALL$formula <- as.formula(model$expr)
  CALL$start <- ssVal
  NLS$call <- as.call(CALL)
  NLS$call2 <- match.call()
  NLS$names <- names(data)[fluo]
  
  class(NLS) <- c("pcrfit", "nls")    
  return(NLS)      
}

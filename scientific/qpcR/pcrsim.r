pcrsim <- function(
object,
nsim = 100,        
error = 0.02,
errfun = function(y) 1,
plot = TRUE,
fitmodel = NULL,
select = FALSE,
statfun = function(y) mean(y, na.rm = TRUE),
PRESS = FALSE,
...
)
{
    if (class(object) != "pcrfit") stop("object must be of class 'pcrfit'!")

    ## take fitted values as template
    CYCS <- object$DATA[, 1]
    FITTED <- fitted(object)
    fluoMAT <- matrix(nrow = length(FITTED), ncol = nsim)
           
    ## add random noise
    for (i in 1:nsim) {
     ranVEC <- sapply(FITTED, function(x) rnorm(1, mean = x, sd = error * errfun(x)))
     fluoMAT[, i] <- ranVEC
    }
         
    ## make empty plot
    if (plot) {
      plot(CYCS, FITTED, type = "n", ylim = c(min(fluoMAT, na.rm = TRUE), max(fluoMAT, na.rm = TRUE)),
           lwd = 2, col = 1, xlab = "Cycles", ylab = "Raw fluorescence", ...)
      apply(fluoMAT, 2, function(x) points(CYCS, x, cex = 0.5, ...))
    }        
    
    ## select models to fit
    if (is.null(fitmodel)) fitMODEL <- list(object$MODEL) else fitMODEL <- as.list(fitmodel)
       
    ## create data matrix for iterative fitting      
    fluoMAT <- cbind(CYCS, fluoMAT)
    colnames(fluoMAT) <- c("Cycles", paste("Fluo.", 1:nsim, sep = ""))
            
    ## preallocate lists for increased speed
    coefLIST <- vector("list", length = length(fitMODEL))
    names(coefLIST) <- sapply(fitMODEL, function(x) x$name)
    gofLIST <- vector("list", length = length(fitMODEL))
    names(gofLIST) <- sapply(fitMODEL, function(x) x$name)

    ## create color vector
    colVEC <- rainbow(length(fitMODEL))  
    
    ## for all models do...
    for (k in 1:length(fitMODEL)) {
      cat(fitMODEL[[k]]$name, "\n")

      ## preallocate matrix dimensions for increased speed
      coefMAT <- matrix(nrow = length(fitMODEL[[k]]$parnames), ncol = nsim)
      gofMAT <- matrix(nrow = ifelse(PRESS, 9, 8), ncol = nsim)
            
      ## for all simulated data do...
      for (i in 1:nsim) {        
        FIT <- pcrfit(fluoMAT, 1, i + 1, fitMODEL[[k]], verbose = FALSE, ...)        
        counter(i)
        
        ## plot fitted curve
        lines(CYCS, fitted(FIT), col = colVEC[k], ...)

        ## put coef's in matrix
        if (i == 1) rownames(coefMAT) <- names(coef(FIT))
        coefMAT[, i] <- coef(FIT)
        
        ## obtain GOF measures
        vecGOF <- unlist(pcrGOF(FIT, PRESS = PRESS, ...))
        
        ## obtain reduced chi-square with error taken from
        ## simulation
        CHISQ <- fitchisq(FIT, error = error * errfun(error))$chi2.red
        vecGOF <- c(vecGOF, chi2.red = CHISQ)
        
        ## put GOF's in matrix
        if (i == 1) rownames(gofMAT) <- names(vecGOF)
        gofMAT[, i] <- vecGOF
      }
      
      cat("\n\n")
      coefLIST[[k]] <- coefMAT
      gofLIST[[k]] <- gofMAT
    }
      
    ## in case of model selection for all GOF measures...
    if (select) {
      RN <- rownames(gofLIST[[1]])    
      ## pre-allocate result list/matrix
      selLIST <- vector("list", length = nrow(gofLIST[[1]]))
      selMAT <- matrix(nrow = length(gofLIST), ncol = ncol(gofLIST[[1]]))         
      ## collect each of the GOF measures for each of the models
      for (i in 1:nrow(gofLIST[[1]])) {
        for (j in 1:length(gofLIST)) {
          selMAT[j, ] <- gofLIST[[j]][i, ]      
        }
              
        ## select based on criteria for the different GOF measures
        if (RN[i] == "Rsq") SEL <- apply(selMAT, 2, function(x) which.max(x))
        if (RN[i] == "Rsq.ad") SEL <- apply(selMAT, 2, function(x) which.max(x))
        if (RN[i] == "AIC") SEL <- apply(selMAT, 2, function(x) which.min(x))
        if (RN[i] == "AICc") SEL <- apply(selMAT, 2, function(x) which.min(x))
        if (RN[i] == "BIC") SEL <- apply(selMAT, 2, function(x) which.min(x))
        if (RN[i] == "resVar") SEL <- apply(selMAT, 2, function(x) which.min(x))
        if (RN[i] == "RMSE") SEL <- apply(selMAT, 2, function(x) which.min(x))
        if (RN[i] == "p.neill") SEL <- apply(selMAT, 2, function(x) which.min(x))
        if (RN[i] == "chi2.red") SEL <- apply(selMAT, 2, function(x) which.min(abs(1-x)))
        if (RN[i] == "P.square") SEL <- apply(selMAT, 2, function(x) which.max(x))
        
        ## store selected model number in list
        selLIST[[i]] <- SEL   
        selMAT[] <- NA
      }
      ## make a matrix from list
      modelMAT <- sapply(selLIST, function(x) x)
      colnames(modelMAT) <- RN
    } else modelMAT <- NULL   
      
    ## create statistics
    statLIST <- lapply(gofLIST, function(x) apply(x, 1, statfun))      
          
    OUT <-  list(fluoMat = fluoMAT, coefList = coefLIST, gofList = gofLIST, 
                 statList = statLIST, modelMat = modelMAT)

    class(OUT) <- "pcrsim"
    return(OUT)
}     

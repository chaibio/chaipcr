calib <- function(
refcurve, 
predcurve = NULL, 
thresh = "cpD2", 
dil = NULL,
group = NULL,
plot = TRUE,
conf = 0.95,
B = 200
)
{
  if (class(refcurve) != "modlist") stop("'refcurve' is not a 'modlist'!")
  if (!is.null(predcurve) & class(predcurve) != "modlist") stop("'predcurve' is not a 'modlist'!")
  if (thresh != "cpD2" && !is.numeric(thresh)) stop("'thresh' must be either 'cpD2' or numeric!")
  if (is.null(dil)) stop("Please define dilutions!")
  if (!is.null(group) && (length(dil) != length(unique(group)))) stop("Supply as many dilutions as number of PCR groups in 'refcurve'!")

  lref <- length(refcurve)
  lpred <- length(predcurve)
  lgroup <- length(unique(group))
  dil <- log10(dil)
  COLref <- rep(rainbow(nlevels(as.factor(dil))), table(as.factor(dil)))
  COLpred <- rep(rainbow(lpred))   

  if(is.null(group))  {
      group <- as.factor(1:lref)
      isReps <- FALSE
  } else isReps <- TRUE

  LMFCT <- function(dil, ref, pred = NULL, conf) {
    linModY <- lm(ref ~ dil)
    conf.Y <- predict(linModY, interval = "confidence", level = conf)
    eff <- as.numeric(10^(-1/coef(linModY)[2]))
    FOM1 <- AIC(linModY)
    FOM2 <- AICc(linModY)
    FOM3 <- Rsq(linModY)
    FOM4 <- Rsq.ad(linModY)
    
    if (!is.null(pred)) {
      linModX <- lm(dil ~ ref)
      pred.conc <- sapply(as.numeric(pred), function(x) predict(linModX, newdata = data.frame(ref = x), interval = "confidence", level = conf))
    } else pred.conc <- NULL

    return(list(linModY = linModY, conf.Y = conf.Y, eff = eff, FOM1 = FOM1, FOM2 = FOM2,
                FOM3 = FOM3, FOM4 = FOM4, pred.conc = pred.conc[1, ], pred.conf = pred.conc[2:3, ]))
   }
   
   print("Calculating threshold cycles of reference curves...")
   flush.console()
   
   if (thresh == "cpD2") refCt <- sapply(refcurve, function(x) efficiency(x, plot = FALSE)$cpD2)
    else refCt <- as.numeric(sapply(refcurve, function(x) predict(x, newdata = data.frame(Fluo = thresh), which = "x")))   
    
   print("Calculating threshold cycles of prediction curves...")
   flush.console()
   
   if (!is.null(predcurve)) {
    if (thresh == "cpD2") predCt <- sapply(predcurve, function(x) efficiency(x, plot = FALSE)$cpD2)
    else predCt <- as.numeric(sapply(predcurve, function(x) predict(x, newdata = data.frame(Fluo = thresh), which = "x")))
   } else predCt <- NULL

   iterRef <- split(refCt, group)

   lmResList <- list()
   iterMat <- matrix(ncol = lgroup, nrow = B)

   for (i in 1:B) {
      if (isReps) selRef <- sapply(iterRef, function(x) sample(x, 1))
       else selRef <- unlist(iterRef)
      lmRes <- LMFCT(dil = dil, ref = as.numeric(selRef), pred = predCt, conf = conf)
      lmResList[[i]] <- lmRes
      iterMat[i, ] <- selRef

      if (plot) {
        par(mar = c(5, 4, 2, 2))
        if (i == 1) {
            par(mfg = c(1, 1))
            plot(dil, selRef, col = COLref, pch = 16, cex = 1.3, xlab = "log(Dilution or copy number)", ylab = "threshold cycle")
        } else {
            points(dil, selRef, col = COLref, pch = 16, cex = 1.3)
            abline(lmRes$linModY, lwd = 2)
            lines(dil, lmRes$conf.Y[, 2], col = 2, lty = 3)
            lines(dil, lmRes$conf.Y[, 3], col = 2, lty = 3)
         }
         if (!is.null(predcurve)) {
                  points(lmRes$pred.conc, predCt, pch = 15, col = COLpred, cex = 1.5)
                  if (is.vector(lmRes$pred.conf)) lmRes$pred.conf <- matrix(lmRes$pred.conf, ncol = 1)
                  if (!all(is.na(lmRes$pred.conc))) {
                        arrows(lmRes$pred.conf[1, ], predCt, lmRes$pred.conf[2, ], predCt, code = 3, angle = 90, length = 0.1, col = "blue")
                  }
         }
      }
   }
      
   summaryList <- list()
   lenRML <- 2:length(lmResList[[1]])
   
   for (i in lenRML) {
      temp <- sapply(lmResList, function(x) x[[i]])
      summaryList[[i - 1]] <- t(temp)
   }
   
   names(summaryList) <- names(lmRes[lenRML])
   
   alpha = 1 - conf
   CONFINT <- function(x, alpha = alpha) quantile(x, c(alpha/2, 1 - (alpha/2)), na.rm = TRUE)

   CONF.eff <- CONFINT(summaryList$eff, alpha = alpha)
   CONF.AICc <- CONFINT(summaryList$FOM2, alpha = alpha)
   CONF.Rsq.ad <- CONFINT(summaryList$FOM4, alpha = alpha)
   
   if (!is.null(predcurve)) {
    if (nrow(summaryList$pred.conc) == 1) summaryList$pred.conc <- t(summaryList$pred.conc)
    CONF.predconc <- apply(summaryList$pred.conc, 2, function(x) CONFINT(x, alpha = alpha))
    if (!isReps) CONF.predconc <- apply(rbind(lmRes$pred.conf[1, ], lmRes$pred.conf[2, ]) , 2, function(x) CONFINT(x, alpha = alpha))
   } else {
    summaryList$pred.conc <- NULL 
    CONF.predconc <- NULL
   } 
      
   if (plot) {
    par(ask = TRUE)
    par(mfrow = c(2, 2))
    par(mar = c(1, 2, 2, 1))
    boxplot(as.numeric(summaryList$eff), main = "Efficiency", cex = 0.2)
    abline(h = CONF.eff, col = 2, lwd = 2)
    boxplot(as.numeric(summaryList$FOM2), main = "corrected AIC", cex = 0.2)
    abline(h = CONF.AICc, col = 2, lwd = 2)
    boxplot(as.numeric(summaryList$FOM4), main = "adjusted R-square", cex = 0.2)
    abline(h = CONF.Rsq.ad, col = 2, lwd = 2)
    if (!is.null(predcurve)) {
      boxplot(summaryList$pred.conc, main = "log(conc) of predicted", cex = 0.2)
      abline(h = CONF.predconc, col = 2, lwd = 2)
    }
  }
  return(list(eff = summaryList$eff, AICc = summaryList$FOM2, Rsq.ad = summaryList$FOM4, predconc = summaryList$pred.conc,
              conf.boot = list(conf.eff = CONF.eff, conf.AICc = CONF.AICc, conf.Rsq.ad = CONF.Rsq.ad, conf.predconc = CONF.predconc)))
}

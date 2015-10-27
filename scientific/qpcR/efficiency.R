efficiency <- function(
object, 
plot = TRUE, 
type = "cpD2", 
thresh = NULL, 
shift = 0, 
amount = NULL,
...) 
{  
    if (!is.numeric(type)) type <- match.arg(type, c("cpD2", "cpD1", "maxE", "expR", "Cy0", "CQ", "maxRatio"))
    if (!is.null(amount) && !is.numeric(amount))
        stop("'amount' must be numeric!")
    if (!is.null(thresh) && !is.numeric(thresh))
        stop("'thresh' must be numeric!")       
    
    if (is.numeric(type) && (type < min(object$DATA[, 1], na.rm = TRUE) || type > max(object$DATA[, 1], na.rm = TRUE))) stop("'type' must be within Cycles range!")
    if (is.numeric(thresh) && (thresh < min(object$DATA[, 2], na.rm = TRUE) || thresh > max(object$DATA[, 2], na.rm = TRUE))) stop("'thresh' must be within fluorescence range!")
    
    CYCS <- object$DATA[, 1]    
    EFFobj<- eff(object, ...)
    SEQ <- EFFobj$eff.x      
    D1seq <- object$MODEL$d1(SEQ, coef(object))
    D2seq <- object$MODEL$d2(SEQ, coef(object))   
    
    ## from 1.3-7: remove Inf's that mimicked maximum values
    D1seq[!is.finite(D1seq)] <- NA
    D2seq[!is.finite(D2seq)] <- NA    
    EFFseq <- EFFobj$eff.y        
       
    maxD1 <- which.max(D1seq)     
    maxD2 <- which.max(D2seq)      
    cycmaxD1 <- SEQ[maxD1]      
    cycmaxD2 <- SEQ[maxD2]     
    
    if (!is.null(thresh)) type <- "cpD2"        
    
    ## cpD2
    if (type == "cpD2" || type == "CQ") {
        maxEFF <- EFFseq[maxD2 + (100 * shift)]
        CYC <- cycmaxD2 + shift 
        if (shift != 0) shiftCyc <- cycmaxD2 + shift
    }
                 
    ## cpD1
    if (type == "cpD1") {
        maxEFF <- EFFseq[maxD1 + (100 * shift)]
  	    CYC <- cycmaxD1 + shift
        if (shift != 0) shiftCyc <- cycmaxD1 + shift        
    }

    ## maxE
    if (type == "maxE") {
        cycmaxEFF <- EFFobj$effmax.x   
        maxEFF <- EFFseq[(cycmaxEFF + shift - 1) * 100]        
        CYC <- cycmaxEFF + shift
        if (shift != 0) shiftCyc <- cycmaxEFF + shift             
    } else cycmaxEFF <- NA
                                
    ## numeric threshold cycle
    if (is.numeric(type)) {
        cycTYPE <- which(SEQ == round(type, 2))
        maxEFF <- EFFseq[cycTYPE]
        if (shift != 0) shiftCyc <- type + shift
        CYC <- type + shift
    }

    ## expR
    if (type == "expR") {
        expR <- maxD2 - (maxD1 - maxD2)
        cycEXP <- SEQ[expR]
        maxEFF <- EFFseq[expR + (100 * shift)]
        if (shift != 0) shiftCyc <- cycEXP + shift
        CYC <- cycEXP + shift
    } else cycEXP <- NA         
    
    ## Cy0
    if (type == "Cy0") {
        Cy0reg <- Cy0(object, plot = FALSE) 
        maxEFF <- EFFseq[(Cy0reg + shift - 1) * 100]
        if (shift != 0) shiftCyc <- Cy0reg + shift
        CYC <- Cy0reg + shift          
    } else Cy0reg <- NA
    
    ## numeric threshold fluorescence
    if (!is.null(thresh)) {
        cycF <- as.numeric(round(predict(object, newdata = data.frame(Fluo = thresh), "x"), 2))         
        maxEFF <- EFFseq[(cycF + shift - 1) * 100]
        if (shift != 0) shiftCyc <- cycF + shift  
        CYC <- cycF + shift        
    } else cycF <- NA           

    ## CQ (comparative quantitation)     
    if (type == "CQ") {
        fluo <- as.numeric(predict(object, newdata = data.frame(Cycles = CYC)))
        fluoCQ <- 0.2 * fluo
        cycCQ <- as.numeric(round(predict(object, newdata = data.frame(Fluo = fluoCQ), which = "x"), 2))
        maxEFF <- EFFseq[(cycCQ + shift - 1) * 100]
        if (shift != 0) shiftCyc <- cycCQ + shift
        CYC <- cycCQ + shift
        fluo <- fluoCQ
    } else cycCQ <- NA
    
    ## maxRatio method as in Shain et al. (2008)
    if (type == "maxRatio") {
      EFFobj <- eff(object, method = "spline", ...)
      SEQ <- EFFobj$eff.x
      EFFseq <- EFFobj$eff.y
      maxEFF <- EFFobj$effmax.y
      cycMR <- EFFobj$effmax.x
      CYC <- cycMR + shift                         
    } else cycMR <- NA      

    if (is.null(thresh)) fluo <- as.numeric(predict(object, newdata = data.frame(Cycles = CYC))) else fluo <- thresh
    init1 <- as.numeric(predict(object, newdata = data.frame(Cycles = 0)))     
    init2 <- fluo/(maxEFF^CYC)      
        
    if (is.numeric(amount)) CF <- amount/init1 else CF <- NA

    if (plot) {
        par(mar = c(5, 4, 4, 4))
        plot(object, lwd = 1.5, main = NA, cex.main = 0.9, ...)
        points(CYC, fluo, col = 1, pch = 16)    
        lines(SEQ, D1seq, col = 2, lwd = 1.5) 
        lines(SEQ, D2seq, col = 3, lwd = 1.5)  
        abline(h = fluo, col = 1) 
        axis(side = 2, at = fluo, labels = round(fluo, 3), col = 1, 
             col.axis = 1, cex.axis = 0.7, las = 1)      
        par(new = TRUE)
        plot(SEQ, EFFseq, axes = FALSE, xlab = "", ylab = "", ylim = c(1, 2.2), type = "l", col = 4, lwd = 1.5)
        axis(side = 4, col = 4, col.axis = 4, col.ticks = 4)            
        points(CYC, maxEFF, col = 4, pch = 16)      
        mtext(side = 4, "Efficiency", line = 2.5, col = 4)         
        abline(h = maxEFF, lwd = 1.5, col = 4)
        abline(v = cycmaxD1, lwd = 1.5, col = 2)
                    
        switch(type, maxE = abline(v = cycmaxEFF, lwd = 1.5, col = 4),
                     expR = abline(v = cycEXP, lwd = 1.5, col = 6),           
                     Cy0 = abline(v = Cy0reg, lwd = 1.5, col = "darkviolet"),
                     CQ = abline(v = cycCQ, lwd = 1.5, col = "darkviolet"),
                     maxRatio = abline(v = cycMR, lwd = 1.5, col = "darkviolet")
        )
                        
        if (is.numeric(type)) 
            abline(v = type, lwd = 1.5, col = 6)
            
        if (!is.null(thresh))
            abline(v = cycF, lwd = 1.5, col = 6)
            
        abline(v = cycmaxD2, lwd = 1.5, col = 3)
        
        if (shift != 0) abline(v = shiftCyc, lwd = 1.5, col = 7)
        
        mtext(paste("cpD2:", round(cycmaxD2, 2)), line = 0, col = 3, adj = 0.65, cex = 0.9)
        mtext(paste("cpD1:", round(cycmaxD1, 2)), line = 0, col = 2, adj = 0.35, cex = 0.9)
        
        switch(type, maxE = mtext(paste("cpE:", round(cycmaxEFF, 2)), line = 1, col = 4, adj = 0.65, cex = 0.9),            
                     expR = mtext(paste("cpR:", round(cycEXP, 2)), line = 1, col = 6, adj = 0.65, cex = 0.9),
                     Cy0 = mtext(paste("Cy0:", round(Cy0reg, 2)), line = 1, col = "darkviolet", adj = 0.65, cex = 0.9),
                     CQ = mtext(paste("cpCQ:", round(cycCQ, 2)), line = 1, col = "darkviolet", adj = 0.65, cex = 0.9),
                     maxRatio = mtext(paste("cpMR:", round(cycMR, 2)), line = 1, col = "darkviolet", adj = 0.65, cex = 0.9)
        )
                   
        if (is.numeric(type)) 
            mtext(paste("ct:", round(type, 2)), line = 1, col = 6, adj = 0.65, cex = 0.9)
            
        if (!is.null(thresh)) 
            mtext(paste("cpT:", round(cycF, 2)), line = 1, col = 6, adj = 0.65, cex = 0.9)                       
        
        mtext(paste("Eff:", round(maxEFF, 3)), line = 1, 
            col = 4, adj = 0.35, cex = 0.9)
        mtext(paste("resVar:", round(resVar(object), 5)), line = 2,
            col = 1, adj = 0.35, cex = 0.9)
        mtext(paste("AICc:", round(AICc(object), 2)), line = 2, 
            col = 1, adj = 0.65, cex = 0.9)
        mtext(paste("Model:", object$MODEL$name), line = 3, col = 1, adj = 0.5, 
            cex = 0.9)
        
        par(new = TRUE)
        plot(object, type = "n", axes = FALSE, main = "", xlab = "", ylab = "")
    }
    
    return(list(eff = maxEFF, resVar = round(resVar(object), 8), AICc = AICc(object), AIC = AIC(object), 
        Rsq = Rsq(object), Rsq.ad = Rsq.ad(object), cpD1 = round(cycmaxD1, 2), cpD2 = round(cycmaxD2, 2), 
        cpE = round(cycmaxEFF, 2), cpR = round(cycEXP, 2), cpT = round(cycF, 2), Cy0 = round(Cy0reg, 2),
        cpCQ = round(cycCQ, 2), cpMR = round(cycMR, 2), fluo = fluo, init1 = init1, init2 = init2, cf = CF))
}

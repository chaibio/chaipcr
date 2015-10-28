expfit <- function(
object,
method = c("cpD2", "outlier", "midpoint", "ERBCP"),
model = c("exp", "linexp"),
## cpD2
offset = 0,
## outlier
pval = 0.05,
n.outl = 3,
## midpoint
n.ground = 1:5,
## ERBCP
corfact = 1,
## all methods
fix = c("top", "bottom", "middle"),
nfit = 5,
plot = TRUE,
...
)
{
      method <- match.arg(method)
      model <- match.arg(model)
      fix <- match.arg(fix)       
      
      ## cpD2 method
      if (method == "cpD2") {
        cpD2 <- efficiency(object, plot = FALSE)$cpD2
        cpD2 <- floor(cpD2) + offset
        CYCS <- 1:cpD2        
      }
                  
      ## outlier method
      if (method == "outlier") {
            result <- takeoff(object, pval = pval, nsig = n.outl)
            OUTLIER <- result$top
            CYCS <- OUTLIER:(OUTLIER + nfit - 1)
      }
      
      ## midpoint method
      if (method == "midpoint") {
            result <- midpoint(object, noise.cyc = n.ground)
            MIDPOINT <- round(result$cyc.mp)            
            if (fix == "top") CYCS <- (MIDPOINT - nfit + 1):MIDPOINT
            if (fix == "bottom") CYCS <- MIDPOINT:(MIDPOINT + nfit - 1)
            if (fix == "middle") CYCS <- (MIDPOINT - (round(nfit/2 - 1))):(MIDPOINT + (round(nfit/2)))
      }
      
      ## ERBCP (Exponential Region By Crossing Points) method
      if (method == "ERBCP") {
            result <- efficiency(object, plot = FALSE)
            cpD1 <- result$cpD1
            cpD2 <- result$cpD2
            expreg <- cpD2 - corfact * (cpD1 - cpD2)
            EXPREG <- round(expreg)
            if (fix == "top") CYCS <- (EXPREG - nfit + 1):EXPREG
            if (fix == "bottom") CYCS <- EXPREG:(EXPREG + nfit - 1)
            if (fix == "middle") CYCS <- (EXPREG - (round(nfit/2 - 1))):(EXPREG + (round(nfit/2)))
      }
      
      ## calculate exponential model  
      DATA <- object$DATA[CYCS, ]
      expMod <- pcrfit(DATA, 1, 2, switch(model, exp = expGrowth, linexp = linexp), verbose = FALSE)         
      EFF <- exp(as.numeric(coef(expMod)[2])) 
      INIT <- as.numeric(coef(expMod)[1]) * as.numeric(exp(coef(expMod)[2]))  
      
      POINT <- switch(method, cpD2 = cpD2, outlier = OUTLIER, midpoint = MIDPOINT, ERBCP = EXPREG)  
      
      if (plot) {
            plot(object, ...)
            points(DATA[, 1], DATA[, 2], col = 2, pch = 16, ...)
            lines(DATA[, 1], fitted(expMod), col = 2, lwd = 2, ...)
      }

      return(list(point = POINT, cycles = CYCS, eff = EFF, AIC = AIC(expMod), 
                  resVar = resVar(expMod), RMSE = RMSE(expMod), init = INIT, mod = expMod))
}

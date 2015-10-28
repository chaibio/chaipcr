LOF.test <- function(object)
{
  if (any(class(object) == "replist")) object <- object[[1]] else object <- object

  fetchDATA <- fetchData(object)  
  DATA <- fetchDATA$data   
  PRED.pos <- fetchDATA$pred.pos
  RESP.pos <- fetchDATA$resp.pos
  PRED.name <- fetchDATA$pred.name    

  if (length(DATA[, PRED.pos]) == length(unique(DATA[, PRED.pos]))) stop("No response value replicates! Consider 'neill.test'...")

  X <- DATA[, PRED.pos]
  Y <- DATA[, RESP.pos]
  Xname <- colnames(DATA)[PRED.pos]
  Yname <- colnames(DATA)[RESP.pos]
  DATA2 <- as.data.frame(cbind(X, Y))
  colnames(DATA2) <- c(Xname, Yname)

  EXP <- paste(Yname, " ~ as.factor(", Xname, ")", sep = "")
  object2 <- lm(formula(EXP), data = DATA2)
  
  Q <- -2 * (logLik(object) - logLik(object2))
  df.Q <- df.residual(object) - df.residual(object2)
  p.Q <- 1 - pchisq(Q, df.Q)

  p.F <- anova(object, object2)$"Pr(>F)"[2]
  return(list(pF = p.F, pLR = as.numeric(p.Q)))
}
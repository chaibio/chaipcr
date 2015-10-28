llratio <- function(objX, objY)
{
      if(inherits(objX, "logLik")) LLx <- objX else LLx <- logLik(objX)
      if(inherits(objY, "logLik")) LLy <- objY else LLy <- logLik(objY)
      statistic <- abs(2 * (as.numeric(LLx) - as.numeric(LLy)))
      df <- abs(attr(LLx, "df") - attr(LLy, "df"))      
      p.value <- 1 - pchisq(statistic, df)
      return(list(ratio = statistic, df = df, p.value = p.value))
}

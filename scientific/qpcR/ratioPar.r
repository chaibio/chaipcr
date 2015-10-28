ratioPar <- function(
group = NULL, 
effVec = NULL,
cpVec = NULL,
type.eff = "individual",
plot = TRUE,
combs = c("same", "across", "all"),
refmean = FALSE,
verbose = TRUE,
...)
{
    ## create dummy "pcrbatch" data
    DATA <- rbind(effVec, cpVec)
    colnames(DATA) <- group
    DATA <- as.data.frame(DATA)
    DATA <- cbind(Vars = c("ext.eff", "sig.ext"), DATA)
    class(DATA)[2] <- "pcrbatch"       
      
    ratiobatch(data = DATA, group = group, which.eff = "ext", which.cp = "ext",
               type.eff = type.eff, plot = plot, combs = combs, refmean = refmean,
               verbose = verbose, ...)
}
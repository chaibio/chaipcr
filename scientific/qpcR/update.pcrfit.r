update.pcrfit <- function (object, ..., evaluate = TRUE)
{
    call <- object$call2
    extras <- match.call(expand.dots = FALSE)$...
    if (length(extras) > 0) {
        glsa <- names(as.list(args(pcrfit)))
        names(extras) <- glsa[pmatch(names(extras), glsa[-length(glsa)])]
        existing <- !is.na(match(names(extras), names(call)))
        for (a in names(extras)[existing]) call[[a]] <- extras[[a]]
        if (any(!existing)) {
            call <- c(as.list(call), extras[!existing])
            call <- as.call(call)
        }
    }
    if (evaluate) {
        eval(call, parent.frame())
    }
    else call
}
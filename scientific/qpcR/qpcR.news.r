qpcR.news <- function (...) 
{
    newsfile <- file.path(system.file(package = "qpcR"), 
        "NEWS")
    file.show(newsfile, ...)
}


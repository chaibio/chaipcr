pcrimport2 <- function(file = "clipboard", sep = "\t", header = TRUE,
				quote = "", dec = ".", colClasses = "numeric", ...)
{
	read.delim(file = file, sep = sep, header = header, quote = quote,
			dec = dec, colClasses = colClasses, check.names = FALSE, ...)
}

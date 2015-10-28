pcrimport <- function(
file = NA, 
sep = NA,
dec = NA,
delCol = NA,
delRow = NA, 
format = c(NA, "col", "row"),
sampleDat = NA,
refDat = NA,
names = NA,
sampleLen = NA,
refLen = NA, 
check = TRUE,
usePars = TRUE,
dirPars = NULL,
needFirst = TRUE,
...
)
{
  options(warn = -1)
  format <- match.arg(format)    
       
  ### file destination input
  FILE <- file
  if (is.na(FILE)) {
    while (is.na(FILE)) {
      cat("Where is the data?\n in a directory with file(s) such as \"c:\\temp\\\" \n in the clipboard => 1\n or a dataframe in the workspace => \"name\"\n")
      FILE <- scan("", what = "character", nmax = 1, quiet = TRUE)      
    }
  }
  
  if (FILE == "1" || FILE == "clipboard") {
    FILE <- "clipboard"
    isCB <- TRUE
  } else isCB <- FALSE
  
  if(exists(FILE, envir = .GlobalEnv)) {    
    DATA <- get(FILE, envir = .GlobalEnv)    
    isWS <- TRUE    
  } else isWS <- FALSE
  
  if (!isWS && !isCB) {
   LF <- list.files(FILE, full.names = TRUE)
   if (length(LF) == 0) stop("Directory does not exist or has no files...Please check!")
   if (length(LF) > 0) {
     FILE <- LF
     cat("Found the following files:", LF, "\n", fill = 1)
   }
  }   
  
  ### create output list
  outLIST <- vector("list", length = length(FILE))  
  
  ### for all files do...
  for (i in 1:length(FILE)) {
  
    ### decide if first datset is needed as template
    ### of if all runs are formatted by saved parLIST
    CRIT <- ifelse(needFirst, 1, 0)
    if (CRIT == 0) usePars <- TRUE

    ### use saved parameters for all but first files
    if (i > CRIT && usePars == TRUE) {
      cat("Formatting", FILE[i], "with saved parameters...\n")
      flush.console()
      if (is.null(dirPars)) PATH <- path.package("qpcR") else PATH <- dirPars
      SW <- try(setwd(PATH), silent = TRUE)
      if (inherits(SW, "try-error")) stop("Path defined in 'dirPars' does not exist! Please create or use a different one...")
      LOAD <- try(load(file = "parList.rda", envir = .GlobalEnv), silent = TRUE)
      if (inherits(LOAD, "try-error")) stop("Parameter list could not be loaded. Start again with 'needTemplate = TRUE'!")
      
      parLIST <- get("parLIST", envir = .GlobalEnv)
      sep <- parLIST$sep
      dec <- parLIST$dec
      delCol <- parLIST$delCol
      delRow <- parLIST$delRow
      format <-  parLIST$format
      names <- parLIST$names
      sampleDat <- parLIST$sampleDat
      sampleLen <- parLIST$sampleLen
      refDat <- parLIST$refDat
      refLen <- parLIST$refLen
      check <- parLIST$check
    }

    ### check for field separator
    SEP <- sep    
    if (is.na(SEP)) {
      while (!(SEP %in% 1:3) || length(SEP) != 1) {
        cat("Data is separated by\n tabs => 1\n commas => 2\n whitespace => 3\n")
        SEP <- scan("", what = "numeric", nmax = 1, quiet = TRUE)
        SEP <- as.numeric(SEP)
      }
    } else {
     if (!(sep %in% c("\t", "," , ""))) stop("'sep' must be one of '\t', ',' or ''!")
    }
    SEP <- switch(SEP, "1" = "\t", "2" = ",", "3" = "", sep)

    ### check for decimal point character
    DEC <- dec
    if (is.na(DEC)) {
      while (!(DEC %in% 1:2) || length(DEC) != 1) {
        cat("Decimals are separated by\n . => 1\n , => 2\n")
        DEC <- scan("", what = "numeric", nmax = 1, quiet = TRUE)
        DEC <- as.numeric(DEC)
      }
    } else {
      if (!(dec %in% c(".", ","))) stop("'dec' must be one of '.' or ','!")
    }
    DEC <- switch(DEC, "1" = ".", "2" = ",", dec)

    ### read in data
    if (!isWS) DATA <- try(read.delim(FILE[i], header = FALSE, skip = 0, sep = SEP, dec = DEC, colClasses = NA, check.names = FALSE,
                                      quote = "", stringsAsFactors = FALSE, comment.char = "", na.strings = "NA", ...), silent = TRUE)
    if (inherits(DATA, "try-error")) {
       cat("There was an error in importing from", FILE[i], ". Trying next file...\n")
       next
    }
    
    if (check) View(DATA, title = paste("Step 1: Raw import =>", FILE[i]))
    
    ### delete any colums in data
    DELCOL <- delCol
    if (is.na(delCol)) {
      while (is.na(DELCOL) || length(DELCOL) == 0 || !is.numeric(DELCOL)) {    
        cat("Any columns to delete? (i.e. 1, 2:3, c(1, 40:50), ...)\n nothing to delete => 0\n")
        DELCOL <- scan("", what = "numeric", sep = "\t", nmax = 1, quiet = TRUE)         
        DELCOL <- try(eval(parse(text = DELCOL)), silent = TRUE)         
        if (inherits(DELCOL, "try-error")) DELCOL <- NA          
      }
    } else {
      if (!is.numeric(delCol)) stop("'delCol' must be numeric!")
      DELCOL <- delCol
    }  
    
    ### delete any rows in data
    DELROW <- delRow
    if (is.na(delRow)) {
      while (is.na(DELROW) || length(DELROW) == 0 || !is.numeric(DELROW)) {    
        cat("Any rows to delete? (i.e. 1, 2:3, c(1, 40:50), ...)\n nothing to delete => 0\n")
        DELROW <- scan("", what = "numeric", sep = "\t", nmax = 1, quiet = TRUE)         
        DELROW <- try(eval(parse(text = DELROW)), silent = TRUE)         
        if (inherits(DELROW, "try-error")) DELROW <- NA          
      }
    } else {
      if (!is.numeric(delRow)) stop("'delRow' must be numeric!")
      DELROW <- delRow
    }  

    if (DELCOL != 0) DATA <- DATA[, -DELCOL]
    if (DELROW != 0) DATA <- DATA[-DELROW, ]
    
    if (check) View(DATA, title = paste("Step 2: Cols/Rows deleted =>", FILE[i]))
  
    ### check for data orientation 
    FORMAT <- format
    if (is.na(FORMAT)) {
      while (!(FORMAT %in% 1:2) || length(FORMAT) != 1) {
        cat("qPCR data is in\n columns => 1\n rows => 2\n")
        FORMAT <- scan("", what = "numeric", nmax = 1, quiet = TRUE)   
        FORMAT <- as.numeric(FORMAT)     
      }
    } else {
      if (!(format %in% c("col", "row"))) stop("'format' must be either 'col' or 'row'!")
    }
    FORMAT <- switch(FORMAT, "1" = "col", "2" = "row", format)
    
    ### transpose matrix if data in rows
    if (FORMAT == "row") DATA <- t(DATA)
    
    ### make intermediate column names
    colnames(DATA) <- paste("col", 1:ncol(DATA), sep = "")
    
    if (check) View(DATA, title = paste("Step 3: final orientation =>", FILE[i]))    
        
    ### get location of reporter dye data
    SAMPLE <- sampleDat
    while (is.na(SAMPLE) || length(SAMPLE) == 0 || !is.numeric(SAMPLE)) {    
      cat("Column(s) with reporter dye data (i.e. SybrGreen I)?\n")
      cat(" any number or sequence such as 1, 1:10, c(4, 5:7), seq(1, 11, by = 2), ...\n all columns => 0\n")        
      SAMPLE <- scan("", what = "numeric", sep = "\t", nmax = 1, quiet = TRUE)   
      SAMPLE <- try(eval(parse(text = SAMPLE)), silent = TRUE)
      if (inherits(SAMPLE, "try-error")) SAMPLE <- NA   
    }
    if (SAMPLE == 0) {      
      SAMPLE <- 1:ncol(DATA)
      hasREF <- FALSE
      outSAMPLE <- 0
    } else {
      hasREF <- TRUE
      outSAMPLE <- SAMPLE
    }       
            
    ### get location of reference dye data
    REF <- refDat
    if (!hasREF) REF <- 0      
    while (is.na(REF) || length(REF) == 0 || !is.numeric(REF)) {    
      cat("Column(s) with reference dye data (i.e. ROX)?\n")
      cat(" any number or sequence such as 1, 1:10, c(4, 5:7), seq(1, 11, by = 2), ...\n no reference dye used => 0\n all remaining columns not defined as sample columns (alongside to sample data) => -1\n same columns as in sample (stacked under sample data) = -2\n")
      REF <- scan("", what = "numeric", nmax = 1, sep = "\t", quiet = TRUE)   
      REF <- try(eval(parse(text = REF)), silent = TRUE)
      if (inherits(REF, "try-error")) REF <- NA   
    } 
    if (REF == -1) {      
      REF <- (1:ncol(DATA))[-SAMPLE]
      outREF <- -1
    } else if (REF == -2) {
      REF <- SAMPLE
      outREF <- -2
    } else outREF <- REF       
            
    ### check for sample names
    NAMES <- names
    while (is.na(NAMES) || length(NAMES) == 0) {        
        cat("Naming by either\n a row or rows with Sample Names/Well ID's, i.e. 3, c(1, 3),\n a name prefix (i.e. Well#),\n or automatically => 0\n")
        NAMES <- scan("", what = "character", nmax = 1, quiet = TRUE)
    }
    
    ### make run names
    TEST <- try(eval(parse(text = NAMES)), silent = TRUE)
    if (inherits(TEST, "try-error")) TEST <- 0
    if (is.numeric(TEST)) {
       if (TEST == 0) NAMEVEC <- paste("Run.", SAMPLE, sep = "")
       else {
            NAMEVEC <- DATA[TEST, , drop = FALSE]
            NAMEVEC <- do.call(paste, c(split(NAMEVEC, f = 1:nrow(NAMEVEC)), sep = "."))
            DATA <- DATA[-TEST, ]
       }
    } else NAMEVEC <- paste(NAMES, SAMPLE, sep = ".")
    colnames(DATA) <- NAMEVEC
    
    if (check) View(DATA, title = paste("Step 4: named dataset =>", FILE[i]))
           
    ### get length of reporter data
    SLEN <- sampleLen
    while (is.na(SLEN) || !is.numeric(SLEN) || length(SLEN) == 0) {
      cat("In which rows is the sample data (fluorescence values), i.e. 1:40 ?\n all rows till end of data => 0\n")
      SLEN <- scan("", what = "numeric", sep = "\t", nmax = 1, quiet = TRUE)   
      SLEN <- try(eval(parse(text = SLEN)), silent = TRUE)
      if (inherits(SLEN, "try-error")) SLEN <- NA       
    }
    if (SLEN == 0) {
      SLEN <- 1:nrow(DATA)
      outSLEN <- 0
    } else outSLEN <- SLEN 
            
    ### get length of reference data
    if (REF != 0) {
      RLEN <- refLen
        while (is.na(RLEN) || !is.numeric(RLEN) || length(RLEN) == 0) {
        cat("In which rows is the reference data (fluorescence values), i.e. 1:40 ?\n same rows as sample data (alongside to samples) => 0\n all remaining rows till end of data (stacked under samples) => -1\n")
        RLEN <- scan("", what = "numeric", sep = "\t", nmax = 1, quiet = TRUE)   
        RLEN <- try(eval(parse(text = RLEN)), silent = TRUE)
        if (inherits(RLEN, "try-error")) RLEN <- NA  
      }
      if (RLEN == 0) {
        RLEN <- SLEN
        outRLEN <- 0
      } else if (RLEN == -1) {
        RLEN <- (1:nrow(DATA))[-SLEN] 
        outRLEN <- -1
      } else outRLEN <- RLEN 
    } else outRLEN <- NA                  
          
    ### convert all data to numeric (to be sure...)
    DATA <- apply(DATA, c(1, 2), function(x) as.numeric(as.character(x)))

    ### create datasets with names
    SAMPLEDAT <- DATA[SLEN, SAMPLE]
    if (REF != 0) REFDAT <- DATA[RLEN, REF]

    ### try to normalize by reference dye, if exists
    if (REF != 0) {      
      SAMPLEDAT2 <- try(SAMPLEDAT/REFDAT, silent = TRUE)
      if (inherits(SAMPLEDAT2, "try-error")) {
        cat("Sample data could not be normalized by reference data! Unequal dimensions?\nPlease check, continuing with original sample data...\n")
      } else SAMPLEDAT <- SAMPLEDAT2
    }   
       
    SAMPLEDAT <- cbind(Cycles = 1:nrow(SAMPLEDAT), SAMPLEDAT)
    if (check) View(SAMPLEDAT, title = paste("Step 5: final format =>", FILE[i]))
    SAMPLEDAT <- as.data.frame(SAMPLEDAT)
    outLIST[[i]] <- SAMPLEDAT        
  
    if (i == 1 && needFirst == TRUE) {
      parLIST <- list(sep = SEP, dec = DEC, delCol = DELCOL, delRow = DELROW,
                      format = FORMAT, names = NAMES, sampleDat = outSAMPLE, sampleLen = outSLEN,
                      refDat = outREF, refLen = outRLEN, check = FALSE)
      if (is.null(dirPars)) PATH <- path.package("qpcR") else PATH <- dirPars
      SW <- try(setwd(PATH), silent = TRUE)
      if (inherits(SW, "try-error")) stop("Path defined in 'dirPars' does not exist! Please create or use a different one...")
      save(parLIST, file = "parList.rda")
    } 
  }
  
  return(outLIST)    
}

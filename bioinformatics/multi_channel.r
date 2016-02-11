# process multi-channel (mtch) data. Use global variable `channels`.


# function: consolidate result_list_by_channel (rlc) for one element in the one-channel result. 
consolidate_rlc_per_element <- function(result_ele_name, result_list_by_channel) {
    
    erfc <- result_list_by_channel[[1]][[result_ele_name]] # element of interest in the result for the first channel
    channels <- names(result_list_by_channel)
    
    if (class(erfc) == 'matrix') {
        consolidated_ele <- array(NA, 
                                  dim = c(length(channels), dim(erfc)[1], dim(erfc)[2]),
                                  dimnames = list(channels, rownames(erfc), colnames(erfc)))
        for (channel in channels) consolidated_ele[channel,,] <- result_list_by_channel[[channel]][[result_ele_name]] # lapply only make changes in the local scope.
    } else {
        consolidated_ele <- lapply(channels, function(channel) result_list_by_channel[[channel]][[result_ele_name]]) 
        names(consolidated_ele) <- channels }
    
    return(consolidated_ele)
    }


# function: run qPCR functions on multi-channel fluorescence data and output consolidated results. original matrix will become 3-D array, original string or list will be come list.
process_mtch <- function( 
                         iterable_by_channel, # must be a named list or vector, where names are channels, to be inherited by result_list_by_channel
                         func, 
                         ...) {
    
    result_list_by_channel <- lapply(iterable_by_channel, func, ...) # result_list_by_channel will inherit names from iterable_by_channel
    
    result_ele_names <- names(result_list_by_channel[[1]])
    
    result_consoli <- lapply(result_ele_names, consolidate_rlc_per_element, result_list_by_channel)
    names(result_consoli) <- result_ele_names
    
    return(list('pre_consoli'=result_list_by_channel,
                'post_consoli'=result_consoli))
    }

#





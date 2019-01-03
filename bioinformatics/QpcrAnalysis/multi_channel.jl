# multi-channel.jl
#
# process multi-channel (mtch) data. 
# these functions are not currently used

# Top-level function: run qPCR functions on multi-channel fluorescence data and output consolidated results. original matrix will become 3-D array, original string or list will be come list.
function process_mtch(
    input_dict_bych::OrderedDict, # keyed by channels
    arydims2to3::Bool,
    func::Function,
    func_args...
    )

    channels = get_ordered_keys(input_dict_bych)

    result_dict_bych = OrderedDict([
        channel => func(input_dict_bych[channel], func_args...)
        for channel in channels])

    result_keys = get_ordered_keys(result_dict_bych[channels[1]])

    result_consoli = OrderedDict([
        result_key => consolidate_rdc_per_element(result_key, result_dict_bych, arydims2to3)
        for result_key in result_keys])

    return OrderedDict(
        "pre_consoli" => result_dict_bych,
        "post_consoli" => result_consoli)

end


# functions called by `process_mtch`

# function: consolidate for one result element from organization of channel then result element (as in `result_dict_bych`) into organization of result element then channel
function consolidate_rdc_per_element(
    result_key,
    result_dict_bych::OrderedDict,
    arydims2to3::Bool
    )

    channels = get_ordered_keys(result_dict_bych)
    erfc = result_dict_bych[channels[1]][result_key] # element of interest in the result for the first channel

    if arydims2to3 && isa(erfc, AbstractArray) && ndims(erfc) == 2
        consolidated_ele = cat(3, map(channels) do channel
            result_dict_bych[channel][result_key]
        end...) # The resulting DataArray is indexed by the linear indice of channel in `channels` instead of the actual channel values.
    else
        consolidated_ele = OrderedDict(map(channels) do channel
            channel => result_dict_bych[channel][result_key]
        end)
    end

    return consolidated_ele

end


#

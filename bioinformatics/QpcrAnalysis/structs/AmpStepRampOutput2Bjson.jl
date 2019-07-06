## AmpStepRampOutput2Bjson.jl
##
## Author: Tom Price
## Date:   June 2019


## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
struct AmpStepRampOutput2Bjson
    rbbs_3ary                   ::Array{Float_T,3} ## fluorescence after deconvolution and normalization
    blsub_fluos                 ::Array{Float_T,3} ## fluorescence after baseline subtraction
    dr1_pred                    ::Array{Float_T,3} ## dF/dc (slope of fluorescence/cycle)
    dr2_pred                    ::Array{Float_T,3} ## d2F/dc2
    cq                          ::Array{Float_T,2} ## cq values, applicable to sigmoid models but not to MAK models
    d0                          ::Array{Float_T,2} ## starting quantity from absolute quanitification
    ct_fluos                    ::Vector{Float_T}  ## fluorescence thresholds (one value per channel) for Ct method
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}} ## assigned genotypes from allelic discrimination, keyed by type of data (see `AD_DATA_CATEG` in "allelic_discrimination.jl")
end

## constructor
AmpStepRampOutput2Bjson(
	full_amp_out	::AmpStepRampOutput,
    reporting       ::Function = roundoff(JSON_DIGITS) ## reporting function
) =
    AmpStepRampOutput2Bjson(
    	map(fieldnames(AmpStepRampOutput2Bjson)) do fieldname
	        const fieldvalue = getfield(full_amp_out, fieldname)
	        try
	            reporting(fieldvalue)
	        catch
	            fieldvalue ## non-numeric fields
	        end ## try
	    end...) ## do fieldname

## AmpModel.jl
##
## Author: Tom Price
## Date:   June 2019

@enum AmpModel SfcModel MAK2 MAK3 MAKERGAUL3 MAKERGAUL4

const ampmodels = instances(AmpModel)
const AmpModel_DICT = OrderedDict(
    zip(map(Symbol, ampmodels), ampmodels))

## NB keys(AmpModel_DICT) = all the possible values of am_key in amp.jl

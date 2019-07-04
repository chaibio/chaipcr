## MeltCurveTF.jl
##
## Author: Tom Price
## Date:   July 2019

import DataArrays.DataArray


struct MeltCurveTF # `temperature and fluorescence` - TF
    temperature         ::DataArray{Float_T,2} ## | well x channel
    fluorescence        ::DataArray{Float_T,2} ## |
end

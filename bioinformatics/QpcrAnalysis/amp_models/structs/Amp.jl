## Amp.jl
##
## main object in amplification.jl
##
## Author: Tom Price
## Date:   July 2019

import DataStructures.OrderedDict
import Ipopt.IpoptSolver

struct Amp
    ## input data
    raw_data                ::AbstractArray # AmpRawData
    num_cycs                ::Int
    num_fluo_wells          ::Int
    num_channels            ::Int
    cyc_nums                ::Vector{Int}
    fluo_well_nums          ::Vector{Int}
    channels                ::Vector{Symbol}
    calibration_data        ::CalibrationData
    ## solver
    solver                  ::IpoptSolver
    ipopt_print2file_prefix ::String
    ## calibration parameters
    dcv                     ::Bool
    ## amplification model
    amp_model               ::AmpModel
    ## baseline model parameters
    kwargs_bl               ::Dict{Symbol,Any}
    ## model fitting parameters
    kwargs_fit              ::Dict{Symbol,Any}
    ## arguments for report_cq!()
    kwargs_rc               ::Dict{Symbol,Any}
    ## output format parameters
    # out_sr_dict             ::Bool
    out_format              ::Symbol
    reporting               ::Function
end

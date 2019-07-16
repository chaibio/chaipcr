#==================================

    ThermalConsistencyOutput.jl

    Author: Tom Price
    Date:   July 2019

==================================#

struct ThermalConsistencyOutput
    tm_check            ::Vector{TmCheck1w}
    delta_Tm            ::Tuple{Float_T, Bool}
    valid               ::Bool
end

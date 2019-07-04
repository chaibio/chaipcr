## Peak.jl
##
## data type and methods for melting curve
## and temperature consistency experiments
##
## Author: Tom Price
## Date: June 2019


struct Peak
    idx             ::Int
    Tm              ::Float_T
    area            ::Float_T
end


## Peak report methods
## do not report indices for each peak, only Tm and area
report(digits ::Integer, p ::Peak) =
    round.([p.Tm p.area], digits)

report(digits ::Integer, peaks ::Vector{Peak}) =
    length(peaks) == 0 ?
        EMPTY_Ta :
        mapreduce(p -> round.([p.Tm p.area], digits),
            vcat,
            peaks)

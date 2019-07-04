## PeakIndices.jl
##
## data type and methods for melting curve
## and temperature consistency experiments
##
## Author: Tom Price
## Date: June 2019

import Base: start, next, done, eltype, collect, iteratorsize, SizeUnknown


struct PeakIndices
    summit_heights  ::Vector{Float_T}
    summit_idc      ::Vector{Int}
    nadir_idc       ::Vector{Int}
    len_summit_idc  ::Int
    len_nadir_idc   ::Int
    PeakIndices(h,s,n) = new(vcat(h,0.0), vcat(s,0), vcat(n,0), length(s), length(n))
end


## PeakIndices methods
## iterator functions to find peaks and flanking nadirs

Base.start(iter ::PeakIndices) = (0, 0, 0)

Base.done(iter ::PeakIndices, state) =
    state == nothing || state[1] > iter.len_summit_idc

Base.iteratorsize(::PeakIndices) = SizeUnknown()

Base.eltype(iter ::PeakIndices) = Tuple{Int, Int, Int}

Base.collect(iter ::PeakIndices) =
    [peak for peak in iter if thing(peak)]

function Base.next(iter ::PeakIndices, state ::Tuple{Int, Int, Int})
    ## fail if state == nothing
    (state == nothing) && return (nothing, nothing)
    ## state != nothing
    left_nadir_ii, summit_ii, right_nadir_ii = state
    ## next summit
    while (summit_ii < iter.len_summit_idc)
        ## summit_ii < iter.len_summit_idc
        ## increment the summit index
        summit_ii += 1
        ## extend nadir range to the right
        while
            (right_nadir_ii < iter.len_nadir_idc)
                right_nadir_ii += 1
                (iter.summit_idc[summit_ii] < iter.nadir_idc[right_nadir_ii]) && break
        end
        ## decrease nadir range to the left, if possible
        while
            (left_nadir_ii < iter.len_nadir_idc) &&
            (iter.nadir_idc[left_nadir_ii + 1] < iter.summit_idc[summit_ii])
                left_nadir_ii += 1
        end
        ## if there is a nadir to the left, break out of loop
        (left_nadir_ii > 0) && break
        ## otherwise try the next summit
    end
    ## fail if no more summits or no flanking nadirs
    if  (summit_ii >= iter.len_summit_idc) ||
       !(iter.nadir_idc[left_nadir_ii] < iter.summit_idc[summit_ii] < iter.nadir_idc[right_nadir_ii])
            return (nothing, nothing)
    end
    ## find duplicate summits
    right_summit_ii = summit_ii
    while
        (right_summit_ii < iter.len_summit_idc) &&
        (iter.summit_idc[right_summit_ii + 1] < iter.nadir_idc[right_nadir_ii])
            right_summit_ii += 1
    end
    ## remove duplicate summits by choosing highest summit
    if right_summit_ii > summit_ii
        summit_ii = (iis -> iis[indmax(iter.summit_heights[iis])])(summit_ii:right_summit_ii)
    end
    ## return value
    ((iter.nadir_idc[left_nadir_ii], iter.summit_idc[summit_ii], iter.nadir_idc[right_nadir_ii]), ## element
        (left_nadir_ii, summit_ii, right_nadir_ii)) ## state
end ## next()

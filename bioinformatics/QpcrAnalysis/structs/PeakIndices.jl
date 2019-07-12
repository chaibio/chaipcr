#==============================================================================================

    PeakIndices.jl

    iterator for peaks in melting curve
    and temperature consistency experiments

    Author: Tom Price
    Date: June 2019

==============================================================================================#

import Base: start, next, done, eltype, collect, iteratorsize, SizeUnknown


#==============================================================================================
    structs >>
==============================================================================================#


struct PeakIndices
    summit_heights  ::Vector{Float_T}
    summit_idc      ::Vector{Int}
    nadir_idc       ::Vector{Int}
    len_summit_idc  ::Int
    len_nadir_idc   ::Int
    PeakIndices(h,s,n) = new(vcat(h,0.0), vcat(s,0), vcat(n,0), length(s), length(n))
end

struct PeakIndicesState
    left_nadir_ii   ::Int
    summit_ii       ::Int
    right_nadir_ii  ::Int
end 

struct PeakIndicesElement
    left_nadir_idx  ::Int
    summit_idx      ::Int
    right_nadir_idx ::Int
end


#==============================================================================================
    methods >>
==============================================================================================#


## PeakIndices methods
## iterator functions to find peaks and flanking nadirs

Base.start(iter ::PeakIndices) = PeakIndicesState(0, 0, 0)

Base.done(iter ::PeakIndices, state ::Void) = true
Base.done(iter ::PeakIndices, state ::PeakIndicesState) =
    state.left_nadir_ii > iter.len_summit_idc

Base.iteratorsize(::PeakIndices) = SizeUnknown()

Base.eltype(iter ::PeakIndices) = Type{PeakIndicesState}

Base.collect(iter ::PeakIndices) =
    [peak for peak in iter if thing(peak)]

## fail if state == nothing
Base.next(iter ::PeakIndices, state ::Void) = (nothing, nothing)

function Base.next(iter ::PeakIndices, state ::PeakIndicesState)
    left_nadir_ii, summit_ii, right_nadir_ii =
        state |> fieldnames |> mold(curry(getfield)(state))
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
    const newstate = PeakIndicesState(left_nadir_ii, summit_ii, right_nadir_ii)
    const element  = PeakIndicesElement(iter, newstate)
    return (element, newstate)
end ## next()

## constructor
PeakIndicesElement(iter ::PeakIndices, state ::PeakIndicesState) =
    PeakIndicesElement( iter.nadir_idc[  state.left_nadir_ii  ],
                        iter.summit_idc[ state.summit_ii      ],
                        iter.nadir_idc[  state.right_nadir_ii ] )

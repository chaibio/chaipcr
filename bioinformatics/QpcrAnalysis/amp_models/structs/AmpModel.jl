## AmpModel.jl
##
## Author: Tom Price
## Date:   June 2019

abstract type AmpModel                      end
abstract type DFCModel          <: AmpModel end
abstract type MAK2              <: DFCModel end
abstract type MAK3              <: DFCModel end
abstract type MAKERGAUL3        <: DFCModel end
abstract type MAKERGAUL4        <: DFCModel end
abstract type SFCModel          <: AmpModel end
abstract type SFCBaselineModel  <: SFCModel end
abstract type SFCQuantModel     <: SFCModel end

const AMPMODELS = ## baseline models
    [   subtypes(AmpModel)...,
        subtypes(DFCModel)...   ]

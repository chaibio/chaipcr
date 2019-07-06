## ClusteringMethod.jl
##
## enumerated instances of type ClusteringMethod
## these are preferred to subtypes of an abstract type:
## https://docs.julialang.org/en/v1/manual/style-guide/index.html#Avoid-confusion-about-whether-something-is-an-instance-or-a-type-1
## we can dispatch on the instances using Val{instance}
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict

## NB in Julia v0.7 we can use the syntax @enum begin ... end
@enum ClusteringMethod k_means k_means_medoids k_medoids

const CLUSTERINGMETHODS = instances(ClusteringMethod)

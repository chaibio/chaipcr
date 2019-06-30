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
@enum ClusteringMethod K_means K_means_medoids K_medoids

const clusteringmethods = instances(ClusteringMethod)
const cm_DICT = OrderedDict(
    zip(map(Symbol, clusteringmethods), 
        clusteringmethods))
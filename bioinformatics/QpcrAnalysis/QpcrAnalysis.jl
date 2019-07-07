## Module QpcrAnalysis.jl

## Notes on using MySQL 0.3.0 instead of current version
## ----
##                   0.3.0                      0.5.2
## connect           mysql_connect(, some_db)   connect(; db=some_db)
## query function    mysql_execute              query
## query return      Array(DataFrame)           NamedTuple
## data container    DataFrame                  NamedTuple
## data access       [1]                        (direct)
## ----
## `connect` examples:
## 0.3.0 `MySQL.mysql_connect(host, username, password, some_db)`
## 0.5.2 `MySQL.connect(host, username, password; db=some_db)`
## `query` examples:
## 0.3.0 `MySQL.mysql_execute(some_query)[1][:some_header]`
## 0.5.2 `MySQL.query(some_query)[:some_header]`

__precompile__()


# using Base

module QpcrAnalysis
    const MODULE_NAME = "QpcrAnalysis"

    # using Clustering, Combinatorics, DataFrames, DataStructures, Dierckx, Ipopt, JLD, JSON,
    # JuMP, MySQL, NamedTuples, DataArrays
    ## `NLopt` needed on BBB but not on PC ("ERROR: LoadError: Declaring __precompile__(false)
    ## is not allowed in files that are being precompiled".
    ## "ERROR: Failed to precompile NLopt to /root/.julia/lib/v0.6/NLopt.ji")
    ## In addition, `HttpServer` for "juliaserver.jl"

    ## Other functions than `include` read files from `pwd()` only instead of also `LOAD_PATH`.
    ## `pwd()` shows the present working directory in module `Main`, instead of the directory
    ## where "QpcrAnalysis.jl" is located. Therefore `LOAD_FROM_DIR` needs to be defined
    ## for those functions to find files in the directory where "QpcrAnalysis.jl" is located.
    const LOAD_FROM_DIR = LOAD_PATH[find(LOAD_PATH) do path_
        isfile("$path_/$MODULE_NAME.jl")
    end][1] ## slice by boolean vector returned a one-element vector. Assumption: LOAD_PATH is global

    ## include key string constants
    include("constants/keystrings.jl")

    ## default data width in production mode:  32 bits (BBB)
    ## default data width in development mode: 64 bits
    const production_env = (get(ENV, "JULIA_ENV", nothing) == PRODUCTION_MODE)
    const Float_T = production_env ? Float32 : Float64

    ## include each script, generally in the order of workflow

    ## format options
    include("structs/OutputFormat.jl")
    include("structs/DataFormat.jl")

    ## shared functions
    include("shared_functions.jl")

    ## dispatch
    include("structs/Action.jl")
    ## calibration
    include("structs/CalibrationData.jl")
    ## deconvolution
    include("structs/K4Deconv.jl")
    ## allelic discrimination
    include("structs/ClusteringMethod.jl")
    include("structs/ClusterAnalysisResult.jl")
    include("structs/UniqCombinCenters.jl")
    include("structs/AssignGenosResult.jl")
    ## amplification models
    include("amp_models/structs/AmpModel.jl")
    # include("amp_models/structs/Amp.jl")
    include("amp_models/structs/AmpModelFit.jl")
    include("amp_models/structs/SFCModelDef.jl")

    ## generate amplification model definitions
    include("amp_models/SFC_model_definitions.jl")
    include("amp_models/generate_SFC_models.jl")
    include("amp_models/MAKx.jl")
    include("amp_models/MAKERGAULx.jl")

    ## amplification experiments
    include("amp_models/structs/AmpRawData.jl")
    include("amp_models/structs/AmpInput.jl")
    include("amp_models/structs/AmpOutput.jl")
    include("amp_models/structs/AmpBaselineModelFit.jl")
    include("amp_models/structs/AmpQuantModelFit.jl")
    ## melting curve experiments
    # include("structs/MeltCurveRawData.jl")
    include("structs/MeltCurveTF.jl")
    include("structs/Peak.jl")
    include("structs/PeakIndices.jl")
    include("structs/MeltCurveTa.jl")
    include("structs/MeltCurveOutput.jl")
    ## standard curve
    include("structs/StandardCurveResult.jl")
    ## thermal consistency
    include("structs/TmCheck1w.jl")
    include("structs/ThermalConsistencyOutput.jl")

    ## this code is hidden from the parser on the BeagleBone
    @static if !production_env
        ## development & testing
        import Base.Test
        using FactCheck
        include("../test/test_functions.jl")
        ## data format verification
        include("../test/verify_request.jl")
        include("../test/verify_response.jl")
    end

    ## function definitions for:

    ## dispatch
    include("dispatch.jl")
    ## calibration
    include("calibration.jl")
    include("normalization.jl")
    include("deconvolution.jl")
    ## amplification
    include("amplification.jl")
    ## melting curve
    include("melting_curve.jl")
    include("supsmu.jl")
    ## standard curve
    include("standard_curve.jl")
    ## custom analyses
    include("custom_analyses/optical_cal.jl")
    include("custom_analyses/optical_test_single_channel.jl")
    include("custom_analyses/optical_test_dual_channel.jl")
    include("custom_analyses/thermal_consistency.jl")
    include("custom_analyses/thermal_performance_diagnostic.jl")
    # include("custom_analyses/your_own_analysis.jl")

    ## Create module level logger
    ## this can be precompiled
    using Memento
    import FactCheck.clear_results
    logger = getlogger(current_module())

    ## This function contains stuff that needs to happen
    ## at runtime when the module is loaded
    function __init__()
        ## Changes to the default logger must happen at runtime
        ## otherwise segfaults are liable to occur
        push!(logger,
            DefaultHandler(
                FileRoller("julia.log", production_env ? "/var/log" : "/tmp"), ## default max size ~5MB
                DefaultFormatter("[ {date} | {level} ]: {msg}")))
        !production_env && setlevel!(logger, "debug")
        ## Register the module level logger at runtime
        ## so it is accessible via `get_logger(QpcrAnalysis)`
        Memento.register(logger)
        #   
        ## clear Fact Checks
        !production_env && FactCheck.clear_results()
    end ## __init__()
end ## module QpcrAnalysis

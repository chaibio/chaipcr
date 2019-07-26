#===============================================================================

    optical_test_single_channel.jl

===============================================================================#

import DataStructures.OrderedDict
import Memento.debug


## preset values
const MIN_EXCITATION_FLUORESCENCE           = 5120
const MAX_EXCITATION_FLUORESCENCE           = 384000
# const MIN_EXCITATION_FLUORESCENCE_MULTIPLE  = 3


#===============================================================================
    function definition >>
===============================================================================#


## called by dispatch()
function act(
    ::Type{Val{optical_test_single_channel}},
    req             ::Associative;
    out_format      ::OutputFormat = pre_json_output
    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict} =calib_info_AIR; ## not used for computation
    # start: arguments that might be passed by upstream code
    # well_nums ::AbstractVector =[],
)
    debug(logger, "at act(::Type{Val{optical_test_single_channel}})")
 
    ## remove MySql dependency
    #
    # step_ids = ["baseline_step_id", "excitation_step_id"]
    # req = OrderedDict(map(step_ids) do step_id
    #     ot_qry_2b = "SELECT fluorescence_value, well_num
    #         FROM fluorescence_data
    #         WHERE
    #             experiment_id = $exp_id AND
    #             step_id = $step_id AND
    #             cycle_num = 1 AND
    #             step_id is not NULL
    #             well_constraint
    #         ORDER BY well_num
    #     "
    #     ot_nt, fluo_well_nums = get_mysql_data_well(
    #         well_nums, ot_qry_2b, db_conn, false
    #     )
    #     step_id => ot_nt[:fluorescence_value]
    # end) # do step_id

    ## assuming the 2 values of `req` are the same in length (number of wells)
    all_valid = true
    const results =
        map(eachindex(req[BASELINE_KEY][FLUORESCENCE_VALUE_KEY])) do well_i
            const baseline   = req[BASELINE_KEY][FLUORESCENCE_VALUE_KEY][well_i]
            const excitation = req[EXCITATION_KEY][FLUORESCENCE_VALUE_KEY][well_i]
            # valid =
            #    (excitation >= MIN_EXCITATION_FLUORESCENCE) &&
            #    (excitation / baseline >= MIN_EXCITATION_FLUORESCENCE_MULTIPLE) &&
            #    (excitation <= MAX_EXCITATION_FLUORESCENCE) # old
            const valid =
                (excitation .>= MIN_EXCITATION_FLUORESCENCE) &&
                (baseline   .<  MIN_EXCITATION_FLUORESCENCE) &&
                (excitation .<= MAX_EXCITATION_FLUORESCENCE) ## Josh, 2016-08-15
            all_valid &= valid
            OrderedDict(
                :baseline   => baseline,
                :excitation => excitation,
                :valid      => valid
            )
        end ## do well_i
    const output = OrderedDict(
        :optical_data => results,
        :valid        => all_valid)
    return output |> out(out_format)
end ## act(::Type{Val{optical_test_single_channel}})

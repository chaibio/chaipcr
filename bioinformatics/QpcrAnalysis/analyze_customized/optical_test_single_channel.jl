## optical_test_single_channel.jl

import DataStructures.OrderedDict
import JSON.json


function act(
    ::OpticalTestSingleChannel,
    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict} =calib_info_AIR; # not used for computation
    # start: arguments that might be passed by upstream code
    # well_nums ::AbstractVector =[],
    ot_dict         ::Associative;
    out_format      ::Symbol = :pre_json,
    verbose         ::Bool =false
)
    ## remove MySql dependency
    #
    # step_ids = [BASELINE_STEP_ID, EXCITATION_STEP_ID]
    # ot_dict = OrderedDict(map(step_ids) do step_id
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

    ## assuming the 2 values of `ot_dict` are the same in length (number of wells)
    const results =
        map(1:length(ot_dict["baseline"]["fluorescence_value"][1])) do well_i
            const baseline = ot_dict["baseline"]["fluorescence_value"][1][well_i]
            const excitation = ot_dict["excitation"]["fluorescence_value"][1][well_i]
            # valid =
            #    (excitation >= MIN_EXCITATION_FLUORESCENCE) &&
            #    (excitation / baseline >= MIN_EXCITATION_FLUORESCENCE_MULTIPLE) &&
            #    (excitation <= MAX_EXCITATION) # old
            const valid = 
                (excitation >= MIN_EXCITATION_FLUORESCENCE) &&
                (baseline   <  MIN_EXCITATION_FLUORESCENCE) &&
                (excitation <= MAX_EXCITATION) # Josh, 2016-08-15
            OrderedDict(
                :baseline   => baseline, 
                :excitation => excitation, 
                :valid      => valid
            )
        end # do well_i
    const output = OrderedDict(
        :optical_data => results,
        :valid        => true)
    return (out_format == :json) ?
        JSON.json(output) :
        output
end # analyze_optical_test_single_channel()




#


function standard_curve(req_vec::Vector{Any})

    target_input_dict = OrderedDict{Int,NamedTuple}()
    group_input_vec = Vector{Vector{Int}}()

    for well_dict in req_vec
        target_vec = well_dict["well"]
        sample = well_dict["sample"]
        for target_dict in target_vec
            target = target_dict["target"]
            cq = target_dict["cq"]
            qty_dict = target_dict["quantity"]
            qty = qty_dict["m"] * 10^qty_dict["b"]

            #
        end
    end # for well_dict

    # use linreg to fit lines

end # standard_curve

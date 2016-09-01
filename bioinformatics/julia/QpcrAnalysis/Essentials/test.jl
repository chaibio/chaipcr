# test


"""

all:
    single channel
    dual channel
    all wells, selected wells
    dcv == true or false
    output:
        full, pre-json, json
        elements and formats (type, dimension)
        values make sense (minus water, dcv, aw, blsub)
        plots
    end: output
end: all


amplification:
    data with cycles 1 through `min_reliable_cyc + 2`, 1000
end: amplification.

melt curve:
    1 tmprtr point with missing data, 2-4 tmprtr points, all available tmprtr
end: melt curve

calib_calib:
    whether output makes sense
end: calib_calib

deconv:
    well_proc = "vec" vs. "mean"
end: deconv


analyze functions

analyze_optical_calibration
    both single- and multi-channel: valid vs. invalid for adjusting w2w
    multi-channel only: valid vs. invalid for k matrix
end: analyze_optical_calibration

end: analyze functions

"""
function test()
    nothing
end




#

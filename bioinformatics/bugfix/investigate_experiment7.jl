# chaipcr experiment 6 dual channel calibration data

import DataStructures.OrderedDict
import JSON
import HTTP

cal_6_water=[
    [17275, 19833, 19578, 20563, 12187, 18485, 19543, 19261, 12510, 10805, 15503, 13138, 12808, 10954, 13537, 10570],
    [ 1992,  1981,  2040,  1949,  1714,  2294,  1857,  1851,  2005,  2134,  2140,  2072,  2044,  1969,  1947,  2177]
]
cal_6_FAM=[
    [16773, 19277, 19102, 20176, 11883, 17952, 18918, 18775, 12217, 10515, 15195, 12931, 12587, 10748, 13276, 10373],
    [ 2000,  1975,  2050,  1957,  1713,  2276,  1863,  1867,  2022,  2125,  2157,  2073,  2049,  1978,  1959,  2169]
]
cal_6_HEX=[
    [16367, 18894, 18793, 19974, 11747, 17652, 18540, 18447, 12052, 10342, 15020, 12831, 12448, 10577, 13062, 10236],
    [ 1995,  1958,  2054,  1961,  1714,  2287,  1863,  1869,  2020,  2109,  2148,  2071,  2033,  1959,  1946,  2184]
]

cal_6=OrderedDict(
    "water"     => Dict("fluorescence_value" => cal_6_water),
    "channel_1" => Dict("fluorescence_value" => cal_6_FAM),
    "channel_2" => Dict("fluorescence_value" => cal_6_HEX)
)

open("chaipcr_cal_6.json","w") do f
    JSON.print(f, cal_6)
end




# chaipcr experiment 7 dual channel meltcurve data

mc_7_raw=readdlm("mc_7.tsv",'\t',header=true)
raw_mc_7=OrderedDict(
    mc_7_raw[2][1]    => mc_7_raw[1][:,1],
    mc_7_raw[2][2]    => mc_7_raw[1][:,2],
    mc_7_raw[2][3]    => Vector{Integer}(mc_7_raw[1][:,3]),
    mc_7_raw[2][4]    => Vector{Integer}(mc_7_raw[1][:,4])
)

mc_7=OrderedDict(
    "experiment_id"       => 7,
    "stage_id"            => 13,
    "calibration_info"    => cal_6,
    "channel_nums"        => [1,2],
    "qt_prob"             => 0.64,
    "max_normd_qtv"       => 0.8,
    "top_N"               => 4,
    "raw_data"            => raw_mc_7
)

open("chaipcr_mc_7.json","w") do f
    JSON.print(f, mc_7)
end




# chaipcr experiment 8 dual channel amplification data

amp_8_raw=readdlm("amp_8.tsv",'\t',header=true)
raw_amp_8=OrderedDict(
    amp_8_raw[2][1]    => amp_8_raw[1][:,1],
    amp_8_raw[2][2]    => Vector{Integer}(amp_8_raw[1][:,2]),
    amp_8_raw[2][3]    => Vector{Integer}(amp_8_raw[1][:,3]),
    amp_8_raw[2][4]    => Vector{Integer}(amp_8_raw[1][:,4])
)

amp_8=OrderedDict(
  "experiment_id"       => 8,
  "step_id"             => 400,
  "min_reliable_cyc"    => 5,
  "calibration_info"    => cal_6,
  "baseline_cyc_bounds" => Any[],
  "baseline_method"     => "sigmoid",
  "cq_method"           => "Cy0",
  "min_fluomax"         => 4356,
  "min_D1max"           => 472,
  "min_D2max"           => 41,
  "raw_data"            => raw_amp_8
)

open("chaipcr_amp_8.json","w") do f
    JSON.print(f, amp_8)
end




# chaipcr experiment 189 dual channel meltcurve data
# replace calibration data with experiment 6

io = open("chaipcr_mc_189.json","r")
mc_189_cal_6 = JSON.parse(io; dicttype=OrderedDict)
close(io)

mc_189_cal_6["calibration_info"] = cal_6
open("chaipcr_mc_189_cal_6.json","w") do f
    JSON.print(f, mc_189_cal_6)
end




# experiment xh-amp2 dual channel amplification data
# replace calibration data with experiment 6

io = open("xh-amp2.json","r")
xh_amp2_cal_6 = JSON.parse(io; dicttype=OrderedDict)
close(io)

xh_amp2_cal_6["calibration_info"] = cal_6
open("xh-amp2_cal_6.json","w") do f
    JSON.print(f, xh_amp2_cal_6)
end




# POST request to Julia server

# r = HTTP.request("POST", "http://127.0.0.8081", [], JSON.json(f))

using HTTP

io = open("chaipcr_mc_189_cal_6.json","r")
j = read(io, String)
close(io)
r = HTTP.request("POST", "http://127.0.0.1:8081/experiments/189/meltcurve", [], j)

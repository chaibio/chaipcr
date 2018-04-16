
function __init__()

    # println("calling function __init__") # raised error when starting Julia REPL with "$sysimg_path.dll": "calling function __init__fatal: error thrown and no exception handler available."

    # MySQL.MySQLHandle objects involve raw Ptr objects and need to be defined in `__init__` (runtime instead of compile time), since memory layout does not remain the same across process restarts (e.g. between compile time and runtime).
    global const DB_CONN_DICT = OrderedDict(map([
        ("default", DB_INFO["database"])
	#,
    #    ("t1", "test_1ch"),
    #    ("t2", "test_2ch")
    ]) do db_tuple
        db_tuple[1] => mysql_connect(DB_INFO["host"], DB_INFO["username"], DB_INFO["password"], db_tuple[2])
    end) # do db_name

    # # comment this section when `--compile-all`
    # println("start of test")
    # @time global const TEST_RESULTS = test(;
    #     comprehensive=false,
    #     debug=true,
    #     verbose=true # `false` on PC, true on BBB to debug
    # )
    # println("end of test")

    return nothing
end




#

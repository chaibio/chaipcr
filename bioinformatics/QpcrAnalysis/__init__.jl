
function __init__()

    # println("calling function __init__") # raised error when starting Julia REPL with "$sysimg_path.dll": "calling function __init__fatal: error thrown and no exception handler available."

    # remove MySql dependency
    #
    ## MySQL.MySQLHandle objects involve raw Ptr objects and need to be defined in `__init__`
    ## (runtime instead of compile time), since memory layout does not remain the same across
    ## process restarts (e.g. between compile time and runtime).
    #
    # global const DB_CONN_DICT = OrderedDict(map([
    #     ("default", DB_INFO["database"]),
    #     ("t1", "test_1ch"),
    #     ("t2", "test_2ch")
    # ]) do db_tuple
    #     db_short, db_real = db_tuple
    #     db_short => try
    #         MySQL.mysql_connect(DB_INFO["host"], DB_INFO["username"], DB_INFO["password"], db_real)
    #     catch err
    #         if isa(err, MySQL.MySQLInternalError)
    #             warn("Database \"$db_real\" does not exist, returning MySQL.MySQLInternalError")
    #         else
    #             warn("Unknown error (other than database absence) occurred when attempt connection to \"$db_real\". Please report this to code owner.")
    #         end
    #         err
    #     end
    # end) # do db_name
    #
    ## test
    # if all(map(conn_outcome -> isa(conn_outcome, MySQL.MySQLHandle), values(DB_CONN_DICT)))
    #     println("start of test")
    #     @time global const TEST_RESULTS = test(;
    #         comprehensive=false,
    #         debug=true,
    #         verbose=true # `false` on PC, true on BBB to debug
    #    )
    #     println("end of test")
    # else
    #     warn("Not all default or test databases were connected successfully. Test is not performed during # initialization.")
    # end

    return nothing
end




#

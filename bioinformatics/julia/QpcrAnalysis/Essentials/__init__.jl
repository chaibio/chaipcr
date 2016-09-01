
const JULIA_ENV = ENV["JULIA_ENV"]


function __init__()

    # println("calling function __init__") # raised error when starting Julia REPL with "$sysimg_path.dll": "calling function __init__fatal: error thrown and no exception handler available."

    global const db_info = JSON.parsefile("$MODULE_DIR/database.json", dicttype=OrderedDict)[JULIA_ENV]
    global const db_conn_default = mysql_connect(db_info["host"], db_info["username"], db_info["password"], db_info["database"])

    trigger_compilation()
end


# trigger compilation of most functions in the package, to reduce running time for subsequent function calls.

function trigger_compilation()

    return nothing
end




#

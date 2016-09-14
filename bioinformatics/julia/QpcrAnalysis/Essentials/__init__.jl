
function __init__()

    # println("calling function __init__") # raised error when starting Julia REPL with "$sysimg_path.dll": "calling function __init__fatal: error thrown and no exception handler available."

    global const TEST_RESULTS = test(;
        comprehensive=false,
        debug=true,
        verbose=false
    )

    return nothing
end


# trigger compilation of most functions in the package, to reduce running time for subsequent function calls.

function trigger_compilation()

    return nothing
end




#

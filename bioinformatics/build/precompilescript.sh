echo "precompile julia packages if needed"
julia_pkgdir=/root
if [ -d $1 ] && ! [ -z $1 ]
then
    julia_pkgdir=$1
    echo "setting julia dir to $1"
fi
rm /root/chaipcr/bioinformatics/qpcranalysis.so
if [ -e /root/chaipcr/bioinformatics/juliaserver.jl ]
then
    julia -v
    echo "about to start using QpcrAnalysis"
    df -h
    free -m
    pkill -9 julia
    ps -aux

    echo "compiling _supsmu.so"
    cd /root/chaipcr/bioinformatics/QpcrAnalysis
    rm _supsmu.so
    #gfortran -Wall -Wextra -o _supsmu.so -c _supsmu.f
    gfortran -Wall -Wextra -o _supsmu.so _supsmu.f -fPIC -shared
    if [ -e _supsmu.so ]
    then
        echo "_supsmu.so compiled successfully"
    else
        echo "Error compiling _supsmu.so"
        exit 1
    fi
    cd

    JULIA_ENV=production julia -e 'push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/");reload("QpcrAnalysis");using QpcrAnalysis;' --compile=all

    echo ".julia/lib/v0.6/QpcrAnalysis.ji tested using QpcrAnalysis"
    if [ -e ${julia_pkgdir}/.julia/lib/v0.6/QpcrAnalysis.ji ]
    then
        echo "QpcrAnalysis package is precompiled."
    else
        echo "Error precompiling QpcrAnalysis package"
        exit 1
    fi

    echo "Creating executable"
#    julia -e 'Pkg.add("BuildExecutable");Pkg.add("Suppressor");Pkg.checkout("BuildExecutable")'
    julia -e 'Pkg.add("BuildExecutable");Pkg.checkout("BuildExecutable")'

    cd ${julia_pkgdir}/.julia/v0.6/BuildExecutable/src/

cat << 'EOF' >  add_catch.patch

--- src/BuildExecutable.jl	2018-05-29 22:08:45.271522602 +0000
+++ src/BuildExecutable.jl	2018-05-29 20:48:13.108040252 +0000
@@ -137,16 +137,20 @@
     run(cmd)
     println()
 
-
+try
     println("running: $gcc -g $win_arg $(join(incs, " ")) $(cfile) -o $(exe_file.buildfile) -Wl,-rpath,$(sys.buildpath) -L$(sys.buildpath) $(exe_file.libjulia) -l$(exename)")
     cmd = setenv(`$gcc -g $win_arg $(incs) $(cfile) -o $(exe_file.buildfile) -Wl,-rpath,$(sys.buildpath) -Wl,-rpath,$(sys.buildpath*"/julia") -L$(sys.buildpath) $(exe_file.libjulia) -l$(exename)`, ENV2)
     run(cmd)
     println()
+end
 
+try
     println("running: rm -rf $(tmpdir) $(sys.buildfile).o $(sys.inference).o $(sys.inference).ji $(sys.inference0).o $(sys.inference0).ji")
     map(f-> rm(f, recursive=true), [tmpdir, sys.buildfile*".o", sys.inference*".o", sys.inference*".ji", sys.inference0*".o", sys.inference0*".ji"])
     println()
+end
 
+try
     if targetdir != nothing
         # Move created files to target directory
         for file in [exe_file.buildfile, sys.buildfile * ".$(Libdl.dlext)", sys.buildfile * ".ji"]
@@ -194,7 +198,7 @@
             end
         end
     end
-
+end
     println("$(exe_file.targetfile) successfully created.")
     return 0
 end
EOF

    echo "Patching..."
    patch -i add_catch.patch || (echo error patching ExecBuilder package && exit 1)
    echo "done installation... creating executable:"
    rm add_catch.patch
    JULIA=julia

    cat > /tmp/precompile_QpcrAnalysis.jl << EOF

println("Starting precompile template !!!")
push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/")

println("Using time: ")
@time using QpcrAnalysis
println("Done Using!")

if isfile("/root/chaipcr/bioinformatics/build/exec_testfns.jl")
    println("Function testing script found.. executing by precompile script!")
    try
	include("/root/chaipcr/bioinformatics/build/exec_testfns.jl")
    end
else
    println("Function testing script not found!")
end

println("Done Dispatch training.. starting curl training..")

if isfile("/root/chaipcr/bioinformatics/build/juliaserver.jl")
    println("Function testing script found.. executing by precompile script!")
    try
	cmd=\`/root/chaipcr/bioinformatics/build/exec_testcurl.sh\`
	@async run(cmd)
	include("/root/chaipcr/bioinformatics/build/juliaserver.jl")
	println("Done with curl training..")
    end
else
    println("Function testing script not found!")
end

function main()

    println("Main is executed!")
    #reload("QpcrAnalysis")
    println("dispatch time no JIT:")
    include("/root/chaipcr/bioinformatics/build/juliaserver.jl")
    println("Server Exit")
end

println("Done with precompilescript!")


EOF

    cat > /tmp/mkexec.jl << EOF
println("Try dispatch on its own")
@time include("/tmp/precompile_QpcrAnalysis.jl")
println("Done checking dispatch.. now building executable..")

using BuildExecutable
println("BE package is used")

build_executable("/root/qpcranalysis", "/tmp/precompile_QpcrAnalysis.jl", "/tmp/output/", "native")
println("Executable creation finished")

EOF

    rm -r /tmp/output/
    ls /lib/lib/root && rm -r /lib/lib/root
    mkdir -p /tmp/output/
    ls /lib/lib/root || mkdir -p /lib/lib/root
    ls /root/qpcranalysis && rm /root/qpcranalysis

    rm -r /usr/lib/lib/root/
    #mkdir -p /root/julia/julia6RBinaries/lib/lib/root/
    mkdir -p /usr/lib/lib/root/

    rm /usr/lib/lib/root/qpcranalysis.ji
    rm /usr/lib/lib/root/qpcranalysis.so
    rm /usr/share/julia/base/userimg.jl

    echo "creating the image"
    if [ -e /usr/local/lib/lib ]
    then
	rm -r /usr/local/lib/lib
    fi

    mkdir -p /usr/local/lib/lib/root/
   
    cd /root/chaipcr/bioinformatics/build/
    cp ../juliaserver.jl .
    time JULIA_ENV=production $JULIA /tmp/mkexec.jl
    rm juliaserver.jl
    echo "template execution done"

    mkdir -p /root/lib/root/
    ls  /root/lib/root/qpcranalysis.so && cp /lib/lib/root/qpcranalysis.so  /root/lib/root/qpcranalysis.so
    cp /usr/lib/lib/root/qpcranalysis.so /root/lib/root/qpcranalysis.so
    if [ -e /usr/local/lib/lib/root/qpcranalysis.so ]
    then
	cp /usr/local/lib/lib/root/qpcranalysis.so /root/lib/root/qpcranalysis.so
    fi

fi

echo "testing juliaserver script to make sure nothing left to precompile as we are removing the compilation tools later to free up space."
if [ -e /run/precompilejuliadone.flag ]
then
	rm /run/precompilejuliadone.flag
fi

test_julia_server()
{

    if [ -e /tmp/output/qpcranalysis.so ]
    then
        echo "moving qpcranalysis.so"
        date
        cp /tmp/output/qpcranalysis  /root/chaipcr/bioinformatics/
        cp /tmp/output/qpcranalysis.so /root/chaipcr/bioinformatics/
        rm -r /tmp/output
    elif [ -e /lib/lib/root/qpcranalysis.so ]
    then
        echo "moving qpcranalysis.so"
        date
        cp /lib/lib/root/qpcranalysis.so  /root/chaipcr/bioinformatics/
    elif [ -e /usr/local/lib/lib/root/qpcranalysis.so ]
    then
	cp /usr/local/lib/lib/root/qpcranalysis.so /root/chaipcr/bioinformatics/
    fi

    ./exec_testcurl.sh &
    if [ -e /root/chaipcr/bioinformatics/qpcranalysis.so ]
    then
        echo "running with qpcranalysis.so"
        JULIA_ENV=production julia  -J /root/chaipcr/bioinformatics/qpcranalysis.so -e 'push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/"); include("/root/chaipcr/bioinformatics/juliaserver.jl")'
        echo "exit running with qpcranalysis.so"
        date
    else
        echo "running without qpcranalysis.so"
        JULIA_ENV=production julia  -e 'push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/"); include("/root/chaipcr/bioinformatics/juliaserver.jl")'
        echo "exit running without qpcranalysis.so"
        date
    fi
    echo "Juliaserver exit.. done with testing juliaserver."
    touch /run/precompilejuliadone.flag
    exit 0
}

test_julia_server &
counter=0
echo "starting julia server on a different thread"
while true
do
        if [ -e /run/precompilejuliadone.flag ]
        then
                echo Juliaserver finished testing.
                break
        fi
        if [ $counter -gt 30 ]
        then
                echo "julia server testing period due. Cleaning up."
                break
        fi
        counter=$((counter+1))
        sleep 60
done

rm -r /root/lib/root/

pkill -9 julia
pkill -9 julia
pkill -9 julia
pkill -9 julia
pkill -9 julia
sleep 100

ps -aux | grep julia
df -h
if [ -e /run/precompilejuliadone.flag ]
then
	echo Juliaserver finished testing.
else
	echo Juliaserver failed testing.
fi

exit 0
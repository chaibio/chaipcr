echo precompile julia packages if needed

if [ -e /root/chaipcr/bioinformatics/juliaserver.jl ]
then
      julia -v
      echo about to start using QpcrAnalysis
      df -h
      free -m
      export DEBIAN_FRONTEND=noninteractive
      apt-get -y -q autoremove --purge xserver* apache* gnome* libopencv* desktop* hicolor* xscreensaver* xrdp* xorg* x11-common xdg-utils xkb-data
      apt-get -y -q autoremove --purge xserver* apache* gnome* libopencv* desktop* hicolor* xscreensaver* xrdp* xorg* x11-common xdg-utils xkb-data

      export PATH=$PATH:/sbin:/usr/sbin
      export TERM=linux
      echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
      DEBIAN_FRONTEND=noninteractive apt-get -q -y  install patchelf
      DEBIAN_FRONTEND=noninteractive apt-get -q -y  install libfftw3-dev libgmp3-dev libmpfr-dev libblas-dev liblapack-dev libedit-dev parted git ntp build-essential curl python pkg-config libssl-dev libarpack2 libblas3 liblapack3
      DEBIAN_FRONTEND=noninteractive apt-get -q -y install libfftw3-dev libgmp3-dev libmpfr-dev libblas-dev liblapack-dev gfortran libgfortran3 m4 libedit-dev parted git ntp build-essential hdf5-tools curl python pkg-config libssl-dev libarpack2 libblas3 libgfortran3 liblapack3  || exit 1

      pkill -9 julia
      pkill -9 julia
      pkill -9 julia
      pkill -9 julia
      pkill -9 julia
      ps -aux

      JULIA_ENV=production julia -e 'push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/");reload("QpcrAnalysis");using QpcrAnalysis;' --compile=all

      echo tested using QpcrAnalysis
      if [ -e ${julia_pkgdir}/.julia/lib/v0.6/QpcrAnalysis.ji ]
      then
            echo QpcrAnalysis package is precompiled.
      else
            echo Error precompiling QpcrAnalysis package
            exit 1
      fi

      echo "Creating executiable"
      julia -e 'Pkg.add("BuildExecutable");Pkg.checkout("BuildExecutable")'

      cd ${julia_pkgdir}/.julia/v0.6/BuildExecutable/src/

cat << 'EOF' >  add_catch.patch

--- src/BuildExecutable.jl	2018-05-29 22:08:45.271522602 +0000
+++ src/BuildExecutable.jl	2018-05-29 20:48:13.108040252 +0000
@@ -143,10 +143,13 @@
     run(cmd)
     println()
 
+try
     println("running: rm -rf $(tmpdir) $(sys.buildfile).o $(sys.inference).o $(sys.inference).ji $(sys.inference0).o $(sys.inference0).ji")
     map(f-> rm(f, recursive=true), [tmpdir, sys.buildfile*".o", sys.inference*".o", sys.inference*".ji", sys.inference0*".o", sys.inference0*".ji"])
     println()
+end
 
+try
     if targetdir != nothing
         # Move created files to target directory
         for file in [exe_file.buildfile, sys.buildfile * ".$(Libdl.dlext)", sys.buildfile * ".ji"]
@@ -194,7 +197,7 @@
             end
         end
     end
-
+end
     println("$(exe_file.targetfile) successfully created.")
     return 0
 end


EOF

echo Patching..

patch -i add_catch.patch || (echo error patching ExecBuilder package && exit 1)
echo done installation.. creating execuitable:
rm add_catch.patch
#exit 0

JULIA=julia

cat > /tmp/precompile_QpcrAnalysis.jl << EOF

println("Starting precompile template !!!")
push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/")

println("Using time: ")
@time using QpcrAnalysis
println("Done Using!")


if isfile("/root/chaipcr/bioinformatics/build/exec_testfns.jl")
	println("Function test script found.. executing by precompile script!")
	include("/root/chaipcr/bioinformatics/build/exec_testfns.jl")
else
	println("Function test script not found!")
end

function main()

	println("Main is executed!")
	#reload("QpcrAnalysis")

	println("About to test dispatch. First time dispatch time:")
	@time QpcrAnalysis.dispatch("amplification", "{\"calibration_info\":{\"water\":{\"calibration_id\":44,\"step_id\":28},\"channel_1\":{\"calibration_id\":44,\"step_id\":31},\"channel_2\":{\"calibration_id\":44,\"step_id\":34}},\"experiment_id\":68,\"min_ct\":5,\"baseline_cyc_bounds\":[],\"cq_method\":\"Cy0\"}")

	println("dispatch time no JIT:")
	@time QpcrAnalysis.dispatch("amplification", "{\"calibration_info\":{\"water\":{\"calibration_id\":44,\"step_id\":28},\"channel_1\":{\"calibration_id\":44,\"step_id\":31},\"channel_2\":{\"calibration_id\":44,\"step_id\":34}},\"experiment_id\":68,\"min_ct\":5,\"baseline_cyc_bounds\":[],\"cq_method\":\"Cy0\"}")
	println("Done dispatch time test")
	include("/root/chaipcr/bioinformatics/juliaserver.jl")
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
mkdir -p /tmp/output/
ls /root/qpcranalysis && rm /root/qpcranalysis

rm -r /usr/lib/lib/root/
#mkdir -p /root/julia/julia6RBinaries/lib/lib/root/
mkdir -p /usr/lib/lib/root/

rm /usr/lib/lib/root/qpcranalysis.ji
rm /usr/lib/lib/root/qpcranalysis.so
rm /usr/share/julia/base/userimg.jl

echo creating the image
cd /root/chaipcr/bioinformatics/build/
time JULIA_ENV=production $JULIA /tmp/mkexec.jl

mkdir -p /root/lib/root/
cp /usr/lib/lib/root/qpcranalysis.so /root/lib/root/qpcranalysis.so

fi

echo testing juliaserver script to make sure nothing left to precompile as we are removing the compilation tools later to free up space.

test_julia_server2()
{
     JULIA_ENV=production julia -e 'push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/"); 
     include("/root/chaipcr/bioinformatics/juliaserver.jl")'
     echo error: julia server terminated
}

test_julia_server()
{
       if [ -e /tmp/output/qpcranalysis.so ] 
       then
             echo moving qpcranalysis.so
             date
             cp /tmp/output/qpcranalysis  /root/chaipcr/bioinformatics/
             cp /tmp/output/qpcranalysis.so /root/chaipcr/bioinformatics/
             rm -r /tmp/output

             echo running with qpcranalysis.so
             JULIA_ENV=production julia  -J /root/chaipcr/bioinformatics/qpcranalysis.so -e 'push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/"); include("/root/chaipcr/bioinformatics/juliaserver.jl")'
             echo exit running with qpcranalysis.so
             date
       else
             echo running without qpcranalysis.so
             JULIA_ENV=production julia  -e 'push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/"); include("/root/chaipcr/bioinformatics/juliaserver.jl")'
             echo exit running without qpcranalysis.so
             date
       fi
}

test_julia_server &
echo starting julia server on a different thread
sleep 1800
echo julia server testing period due. Cleaning up.
rm -r /root/lib/root/

pkill -9 julia
pkill -9 julia
pkill -9 julia
pkill -9 julia
pkill -9 julia
sleep 100

ps -aux | grep julia
df -h

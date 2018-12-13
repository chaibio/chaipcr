#
# Cookbook:: vm
# Recipe:: julia.rb
#
# install julia 0.6.2 and packages
#
package [
  'gfortran',             # to compile julia packages
  'hdf5-tools',           # dependency for julia package HDF5
  'libgtk-3-dev',         # workaround for bug https://github.com/JuliaGraphics/Gtk.jl/issues/289
]

bash 'julia' do
  user 'vagrant'
  code <<~JULIA
    mkdir ~/julia
    mkdir ~/julia/julia-0.6.2-linux-x86_64
    cd ~/julia/julia-0.6.2-linux-x86_64
    cp -p /vagrant/julia-0.6.2-linux-x86_64/*.tar.gz .
    gunzip *.tar.gz
    for f in $(ls *.tar); do tar -xvf $f; done
    rm *.tar
    sudo ln -s ~/julia/julia-0.6.2-linux-x86_64/bin/julia /usr/local/bin/julia
    /usr/local/bin/julia -e 'include("../chaipcr/bioinformatics/setup.jl")'
    cat <<-START_JULIA >> ~/.juliarc.jl
      atreplinit() do repl
          try
              @eval using Revise
              @async Revise.wait_steal_repl_backend()
          catch
          end
      end
START_JULIA
    echo 'export JULIA_ENV=development' >> ~/.bashrc
    touch /tmp/.vagrant-julia
  JULIA
  not_if { ::File.exist?('/tmp/.vagrant-julia') }
end

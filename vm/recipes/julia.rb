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
  code <<~JULIA
    mkdir ~/julia
    cd ~/julia
    cp -p /vagrant/julia-0.6.2-linux-x86_64.tar.gz .
    tar -xzf julia-0.6.2-linux-x86_64.tar.gz
    rm julia-0.6.2-linux-x86_64.tar.gz
    sudo ln -s ~/julia/julia-0.6.2-linux-x86_64/bin/julia /usr/local/bin/julia
    /usr/local/bin/julia -e 'include("../chaipcr/bioinformatics/setup.jl")'
    echo 'export JULIA_ENV=development' >> ~/.bashrc
  JULIA
  not_if { ::File.exist?('/usr/local/bin/julia') }
end

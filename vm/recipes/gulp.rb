#
# Cookbook:: vm
# Recipe:: gulp.rb
#
# install node package gulp
#
package [
  'node-gyp', # workaround for compilation error in gulp package
]

bash 'gulp' do
  user 'vagrant'
  code <<~GULP
    cd ~/chaipcr/web
    source ~/.rvm/scripts/rvm
    rvm --default use 2.2.9
    sudo npm install node-gyp -g    # avoids downstream compilation error
    sudo npm install gulp@3.9.1 -g  # install globally
    npm install gulp@3.9.1          # install locally
    touch /tmp/.vagrant-gulp
  GULP
  not_if { ::File.exist?('/tmp/.vagrant-gulp') }
end

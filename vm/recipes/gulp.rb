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
    source /usr/local/rvm/scripts/rvm
    rvm --default use 2.2.9
    sudo npm install node-gyp -g    # avoids downstream compilation error
    sudo npm install gulp -g        # install globally
    npm install gulp                # install locally
  GULP
  only_if (RUBY_VERSION == '2.2.9')
end

# this is a policyfile
# it describes how you want Chef to build your system
#
# https://docs.chef.io/policyfile.html

# a name that describes what the system you're building with Chef does
name 'policyfile_vm_development'

# where to find external cookbooks
default_source :supermarket

# cookbooks from default source
cookbook 'apt'
cookbook 'build-essential'
cookbook 'git'
cookbook 'nodejs', '~> 6.0.0'
cookbook 'nvm'
cookbook 'curl'
cookbook 'gpg'
cookbook 'unzip'
cookbook 'vim'
cookbook 'mysql'

# incompatible with Chef >= 13.0.84 due to bug
# https://github.com/martinisoft/chef-rvm/issues/367

# cookbook "rvm"

# custom source for a single cookbook
cookbook 'vm', path: '.'

# run_list: Chef will run these recipes in the order specified
run_list [
  'apt::default',
  'git::default',
  'nodejs::default',
  'nodejs::npm',
  'curl::default',
  'gpg::default',
  'unzip::default',
  'vim::default',
  'vm::development',
]

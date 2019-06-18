# vm cookbook

## Summary

* This file describes how to set up and test a local development environment.

* We will use `chef` and `vagrant` to set up a `VirtualBox` linux VM and install the _chaipcr_ firmware.

* The code is adapted from https://goo.gl/EsgciM

## Requirements

First install these applications:

* [__VirtualBox__](https://www.virtualbox.org/wiki/Downloads)

* [__Vagrant__](https://www.vagrantup.com/docs/installation/)

* [__Chef__](https://docs.chef.io/install_server.html)

## Procedure

1. Clone the _chaipcr_ repo:  
`git clone https://github.com/chaibio/chaipcr.git`
    
2. Check the specifications of the virtual machine:  
`cd chaipcr/vm`  
`kitchen list`

3. Create the virtual machine:  
`kitchen create`

4. Check that the virtual machine is present on VirtualBox and configured as expected.

5. Install the _chaipcr_ development environment:  
`kitchen converge`

6. Run some automated tests on the environment:  
`kitchen verify`

6. Log in to the test machine as user _vagrant_ (no password required) and check that `MySql` is running:  
`kitchen exec -c 'uname -a'`  
`kitchen login master-ubuntu-1604`  
`mysql -u root`  

7. Manually test the Rails app:  
`curl --include http://localhost:3000`

8. Remove the VM when you have finished, and check that all the VM instances are gone:  
`kitchen destroy`  
`vagrant global-status`
#!/bin/bash

/etc/init.d/jenkins stop
cp -r . /var/lib/jenkins/
/etc/init.d/jenkins start


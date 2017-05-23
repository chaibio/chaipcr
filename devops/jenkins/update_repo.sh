#!/bin/bash

cp --parents  /var/lib/jenkins/jobs/*/config.xml -r .
cp -r var/lib/jenkins/jobs .
rm -r var

sync

git diff .

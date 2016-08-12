#!/bin/bash

/usr/local/bin/bundle exec rake db:migrate
/usr/local/bin/bundle exec rake db:seed_fu
ruby scripts/upgrade.rb
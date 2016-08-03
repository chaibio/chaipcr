#!/bin/bash

bundle exec rake db:migrate
bundle exec rake db:seed_fu
ruby scripts/upgrade.rb
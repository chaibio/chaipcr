#!/bin/bash

RAILS_ENV=$RAILS_ENV bundle exec rake db:migrate
RAILS_ENV=$RAILS_ENV bundle exec rake db:seed_fu
RAILS_ENV=$RAILS_ENV ruby scripts/upgrade.rb
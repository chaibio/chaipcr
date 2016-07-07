require "./scripts/cron_db.rb"

crondb = CronDB.new(ENV['RAILS_ENV'])
crondb.clean_tokens
crondb.close
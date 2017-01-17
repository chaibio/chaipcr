require "./scripts/cron_db.rb"

class Startup < CronDB
  def run
    result = execute("DELETE FROM `user_tokens`")
    @logger.info "RubyCron: Remove #{@db.affected_rows} tokens"
    
    execute("UPDATE experiments SET completed_at=NOW(),completion_status='FAILED',completion_message='Instrument failure while running experiment' WHERE started_at is not NULL and completed_at is NULL")
    @logger.info "RubyCron: Update #{@db.affected_rows} orphan experiments"
    
    execute("UPDATE settings SET power_cycles=power_cycles+1")

    @logger.info "RubyCron: startup complete"
    `touch /run/startup_complete.flag`
  end
end

startup = Startup.new(ENV['RAILS_ENV'])
exit if !startup.ok?
startup.run
startup.close


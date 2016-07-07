require "./scripts/cron_db.rb"

class Startup < CronDB
  def run
    result = @db.query("DELETE FROM `user_tokens`")
    @logger.info "RubyCron: Remove #{@db.affected_rows} tokens"
    @db.query("UPDATE experiments SET completed_at=NOW(),completion_status='FAILED',completion_message='Orphan experiment detected on startup' WHERE started_at is not NULL and completed_at is NULL")
    @logger.info "RubyCron: Update #{@db.affected_rows} orphan experiments"
  end
end

startup = Startup.new(ENV['RAILS_ENV'])
exit if !startup.ok?
startup.run
startup.close


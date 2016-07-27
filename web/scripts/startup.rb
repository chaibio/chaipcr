require "./scripts/cron_db.rb"

class Startup < CronDB
  def run
    result = execute("DELETE FROM `user_tokens`")
    @logger.info "RubyCron: Remove #{@db.affected_rows} tokens"
    
    execute("UPDATE experiments SET completed_at=NOW(),completion_status='FAILED',completion_message='Orphan experiment detected on startup' WHERE started_at is not NULL and completed_at is NULL")
    @logger.info "RubyCron: Update #{@db.affected_rows} orphan experiments"
    
    result = @db.query("SELECT cached_version from settings")
    cached_version = result.first["cached_version"]
    if cached_version != nil && software_version != cached_version
      @logger.info "clean cached data after upgrade (cached_version=#{cached_version}, software_version=#{software_version})"
      execute("DELETE FROM `amplification_curves`")
      execute("DELETE FROM `amplification_data`")
      execute("DELETE FROM `cached_melt_curve_data`")
      execute("DELETE FROM `cached_analyze_data`")
      execute("UPDATE settings SET cached_version = NULL")
    end
    
  end
end

startup = Startup.new(ENV['RAILS_ENV'])
exit if !startup.ok?
startup.run
startup.close


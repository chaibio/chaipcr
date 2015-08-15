namespace :chaipcr do
  
desc "clear all user_tokens; cleanup orphan experiments"
task :startup => :environment do
  UserToken.delete_all
  Experiment.where("started_at is not NULL and completed_at is NULL").update_all(completed_at: Time.now, completion_status: "FAILED", completion_message: "Orphan experiment detected on startup")
end

desc "delete expired user_tokens"
task :cleanup => :environment do
  UserToken.delete_all(["expired_at < ?", Date.today])
end

end
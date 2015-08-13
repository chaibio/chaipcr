namespace :chaipcr do
  
desc "clear all user_tokens"
task :reset => :environment do
  UserToken.delete_all
end

desc "delete expired user_tokens"
task :cleanup => :environment do
  UserToken.delete_all(["expired_at < ?", Date.today])
end

end
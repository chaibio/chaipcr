namespace :chaipcr do
  
desc "clear all user_tokens; cleanup orphan experiments"
task :startup => :environment do
  UserToken.delete_all
  Experiment.where("started_at is not NULL and completed_at is NULL").update_all(completed_at: Time.now, completion_status: "FAILED", completion_message: "Instrument failure")
end

desc "delete expired user_tokens"
task :cleanup => :environment do
  UserToken.delete_all(["expired_at < ?", Date.today])
end

desc "swagger json file"
task :swagger => :environment do
  swagger_data = Swagger::Blocks.build_root_json(ApidocsController::SWAGGERED_CLASSES)
  File.open('public/swagger.json', 'w') { |file| file.write(swagger_data.to_json) }
end

end
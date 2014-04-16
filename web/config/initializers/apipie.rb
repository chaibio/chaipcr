Apipie.configure do |config|
  config.app_name                = "qPCR"
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  config.validate                = true
  # were is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/*.rb"
end

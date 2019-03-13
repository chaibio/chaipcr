module SwaggerHelper
  module AuthenticationError
    def self.extended(base)
      base.response 401 do
        key :description, 'Not authorized'
        schema do
          property :errors do
            key :type, :string
            key :enum, ["unauthorized", "sign up", "login in"]
          end
        end
      end
    end
  end
end
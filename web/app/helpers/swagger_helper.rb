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
  
  module PropertyWellnum
    def self.extended(base)
      base.property :well_num do
        key :type, :integer
        key :description, 'Well number from 1 to 16'
      end
    end
  end
end
class ErrorModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :ErrorMessage do
    key :required, [:errors]
    property :errors do
      key :type, :string
    end
  end
  
  swagger_schema :ErrorModel do
    key :required, [:errors]
    property :errors do
      key :type, :array
      items do
        key :type, :string
      end
      key :readOnly, true
    end
  end

end
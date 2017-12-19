class ErrorModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :ErrorModel do
    key :required, [:errors]
    property :errors do
      key :type, :string
    end
  end
end
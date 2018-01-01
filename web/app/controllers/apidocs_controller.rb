class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    key "x-api-id", 'chai'
    info do
      key :version, '1.0.0'
      key :title, 'Swagger ChaiPCR'
      key :description, 'A sample API that uses a petstore as an example to ' \
                        'demonstrate features in the swagger-2.0 specification'
      key :termsOfService, 'http://helloreverb.com/terms/'
      contact do
        key :name, 'Wordnik API Team'
      end
      license do
        key :name, 'MIT'
      end
    end
    key :host, 'chaipcr.readme.io'
    key :basePath, '/api'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    ExperimentsController,
    Experiment,
    Protocol,
    Stage,
    Step,
    Ramp,
    ErrorModel,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
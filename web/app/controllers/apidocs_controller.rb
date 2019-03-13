class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    key "x-api-id", 'chai'
    info do
      key :version, '1.0.0'
      key :title, 'ChaiPCR'
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
		security_definition :access_token do
			key :name, 'access_token'
			key :description, 'An authorization token is returned when you login which needs to be passed for api calls unless the api specifies that the token is not required'
			key :type, :apiKey
			key :in, :header
		end
    key :host, 'chaipcr.readme.io'
    key :basePath, '/api'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
		DevicesController,
    ExperimentsController,
		AmplificationOptionsController,
		ProtocolsController,
		RampsController,
		SessionsController,
		StagesController,
		StepsController,
		UsersController,
    SamplesController,
    TargetsController,
		AmplificationDatum,
		AmplificationOption,
    Device,
    DeviceStatus,
		ErrorModel,
    Experiment,
		MeltCurveDatum,
    Protocol,
    Ramp,
    Stage,
    Step,
    WellLayout,
    Sample,
    SamplesWell,
    Target,
    TargetsWell,
		TemperatureLog,
		User,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end

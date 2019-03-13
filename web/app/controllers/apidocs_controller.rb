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
			key :name, 'Authorization'
			key :description, 'An authorization token is required to be passed for all api calls'
			key :type, :apiKey
			key :in, :header
      key :example, "Authorization: Token GX7ym6gC4gw09LzdlSHBJA"
		end
    key :host, 'chaipcr.readme.io'
    key :basePath, '/api'
    key :consumes, ['application/json']
    key :produces, ['application/json']
    
    parameter :experiment_id do
      key :name, :experiment_id
      key :in, :path
      key :description, 'Experiment ID'
      key :required, true
      key :type, :integer
      key :format, :int64
    end
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

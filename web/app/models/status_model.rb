class StatusModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks


	swagger_schema :Status do
		property :experiment_controller do
			property :machine do
				property :state do
					key :type, :string
					key :description, 'Status of the machine'
				end
				property :thermal_state do
					key :type, :string
					key :description, 'Thermal state of the machine'
				end
			end
		end
		property :heat_block do
			property :zone1 do
				property :temperature do
					key :type, :float
					key :description, 'Temperature in celcius'
				end
				property :target_temperature do
					key :type, :float
					key :description, 'Temperature in celcius'
				end
				property :drive do
					key :type, :float
					key :description, '?'
				end
			end
			property :zone2 do
				property :temperature do
					key :type, :float
					key :description, 'Temperature in celcius'
				end
				property :target_temperature do
					key :type, :float
					key :description, 'Temperature in celcius'
				end
				property :drive do
					key :type, :float
					key :description, '?'
				end
			end
			property :temperature do
				key :type, :float
				key :description, 'Temperature in celcius'
			end
		end
		property :lid do
			property :temperature do
				key :type, :float
				key :description, 'Temperature in celcius'
			end
			property :target_temperature do
				key :type, :float
				key :description, 'Temperature in celcius'
			end
			property :drive do
				key :type, :float
				key :description, '?'
			end
		end
		property :optics do
			property :intensity do
				key :type, :integer
				key :description, '?'
			end
			property :collect_data do
				key :type, :boolean
				key :description, 'If data is being collected or not'
			end
			property :lid_open do
				key :type, :boolean
				key :description, 'If lid is open or closed'
			end
			property :well_number do
				key :type, :integer
				key :description, 'Well number'
			end
			property :photodiode_value do
				key :type, :array
				key :description, '?'
				items do
					key :type, :string
				end
			end
		end
		property :heat_sink do
			property :temperature do
				key :type, :float
				key :description, 'Temperature in celcius'
			end
			property :fan_drive do
				key :type, :float
				key :description, '?'
			end
		end
		property :device do
			property :update_available do
				key :type, :string
				key :description, 'If an update is available or not'
			end
		end
	end




end

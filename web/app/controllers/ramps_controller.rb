#
# Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
# For more information visit http://www.chaibio.com
#
# Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class RampsController < ApplicationController
  include ParamsHelper
	include Swagger::Blocks
  
  before_filter :ensure_authenticated_user
  before_filter :allow_cors
  before_filter :experiment_definition_editable_check

  respond_to :json

  resource_description {
    formats ['json']
  }

  def_param_group :ramp do
    param :ramp, Hash, :desc => "Ramp Info", :required => true do
      param :rate, Float, :desc => "Rate of the ramp, in degrees C/s, set to 100 for max, precision to 8 decimal point", :required => true
      param :collect_data, :bool, :desc => "Collect data, if not provided, default is false", :required => false
    end
  end

	swagger_path '/ramps/{ramp_id}' do
		operation :put do
      extend SwaggerHelper::AuthenticationError
      
			key :summary, 'Update Ramp'
			key :description, 'Updates the passed ramp data for the experiment'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Ramps'
			]
			parameter do
				key :name, :ramp_id
				key :in, :path
				key :description, 'Ramp ID'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :ramp_params
				key :in, :body
				key :description, 'Ramp properties to update'
				key :required, true
				schema do
          property :ramp do
					  key :'$ref', :Ramp
          end
				end
			end
			response 200 do
				key :description, 'Returns an object ramp which has the list of ramp properties'
				schema do
          property :ramp do
					  key :'$ref', :Ramp
          end
				end
			end
		end
	end

  api :PUT, "/ramps/:id", "Update a ramp"
  param_group :ramp
  example "{'ramp':{'id':1,'rate':'100.0','max':true}}"
  def update
    ret  = @ramp.update_attributes(ramp_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  protected

  def get_experiment
    @ramp = Ramp.find_by_id(params[:id])
    @experiment = Experiment.where("experiment_definition_id=?", @ramp.step.stage.protocol.experiment_definition_id).first if !@ramp.nil?
  end

end

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
class AmplificationOptionsController < ApplicationController
  include ParamsHelper
	include Swagger::Blocks

  before_filter :ensure_authenticated_user
  before_filter :allow_cors
  before_filter :get_experiment
  before_filter :amplification_option_editable_check, :except => [:show]

  respond_to :json

  resource_description {
    formats ['json']
  }

  [:cq_method, :min_fluorescence, :min_reliable_cycle, :min_d1, :min_d2, :baseline_cycle_bounds]

  def_param_group :amplification_option do
    param :amplification_option, Hash, :desc => "Amplification Option Info", :required => true do
      param :cq_method, ["Cy0", "cpD2"], :desc => "cq method", :required => false
      param :min_fluorescence, Integer, :desc => "min fluorescence", :required => false
      param :min_reliable_cycle, Integer, :desc => "min reliable cycle", :required => false
      param :min_d1, Integer, :desc => "Min dF/dc - Positive integer, Cy0 only", :required => false
      param :min_d2, Integer, :desc => "Min d2F/dc - Positive integer, cpD2 only", :required => false
      param :baseline_cycle_bounds, Array, :desc => "define upper and lower bounds of cycles", :required => false
    end
  end

	swagger_path '/experiments/{id}/amplification_option' do
		operation :get do
			key :summary, 'Amplification Options'
			key :description, 'Returns the amplification options for the experiment'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			response 200 do
				key :description, 'Returns an object amplification_option which has the list of options'
				schema do
					key :name, :amplification_option
					key :'$ref', :Amplification_option
				end
			end
		end
	end

  api :GET, "/experiments/:id/amplification_option", "Retrieve amplification option"
  param_group :amplification_option
  example "{'amplification_option':{'cq_method':'Cy0','min_fluorescence':123,'min_reliable_cycle':5,'min_d1':472,'min_d2':41,'baseline_cycle_bounds':null}}"
  def show
    @amplification_option = @experiment.experiment_definition.amplification_option
    if @amplification_option.nil?
      @amplification_option = AmplificationOption.new
    end
  end

	swagger_path '/experiments/{id}/amplification_option' do
		operation :put do
			key :summary, 'Update Amplification Options'
			key :description, 'Updates the passed amplification options for the experiment'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'id of the experiment'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :amplification_option_params
				key :in, :body
				key :description, 'Amplification options to update'
				key :required, true
				schema do
					key :'$ref', :Amplification_option
				end
			end
			response 200 do
				key :description, 'Returns an object amplification_option which has the list of options'
				schema do
					key :name, :amplification_option
					key :type, :object
					key :'$ref', :Amplification_option
				end
			end
		end
	end

  api :PUT, "/experiments/:id/amplification_option", "Update amplification option"
  param_group :amplification_option
  def update
    @amplification_option = @experiment.experiment_definition.amplification_option
    if @amplification_option
      @amplification_option.baseline_cycle_bounds = params[:amplification_option][:baseline_cycle_bounds] if params[:amplification_option].key?("baseline_cycle_bounds")
      ret  = @amplification_option.update_attributes(amplification_option_params)
    else
      @amplification_option = AmplificationOption.new(amplification_option_params)
      @amplification_option.baseline_cycle_bounds = params[:amplification_option][:baseline_cycle_bounds] if params[:amplification_option].key?("baseline_cycle_bounds")
      @amplification_option.experiment_definition_id = @experiment.experiment_definition.id
      ret = @amplification_option.save
    end

    if ret && @amplification_option.changed?
      #clear cache
      AmplificationCurve.delete_all(:experiment_id => @experiment.id)
      AmplificationDatum.delete_all(:experiment_id => @experiment.id)
    end

    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  protected

  def get_experiment
    @experiment = Experiment.find_by_id(params[:experiment_id]) if @experiment.nil?
  end

  def amplification_option_editable_check
    if @experiment == nil || !@experiment.experiment_definition.editable?
      render json: {errors: "The amplification options are not editable"}, status: :unprocessable_entity
      return false
    else
      return true
    end
  end


end

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

module ParameterStageId
  def self.extended(base)
		base.parameter do
			key :name, :stage_id
			key :in, :path
			key :description, 'Stage ID'
			key :required, true
			key :type, :integer
			key :format, :int64
		end
  end
end

class StagesController < ApplicationController
  include ParamsHelper
	include Swagger::Blocks
  
  before_filter :ensure_authenticated_user
  before_filter :allow_cors
  before_filter :experiment_definition_editable_check

  respond_to :json

  resource_description {
    formats ['json']
  }

  def_param_group :stage do
    param :stage, Hash, :desc => "Stage Info", :required => true do
      param :stage_type, ["holding", "cycling", "meltcurve"], :desc => "Stage type", :required => true
      param :name, String, :desc => "Name of the stage, if not provided, default name is '<stage type> Stage'", :required => false
      param :num_cycles, Integer, :desc => "Number of cycles in a stage, must be >= 1, default to 1", :required=>false
      param :auto_delta, :bool, :desc => "Auto Delta, default is false", :required=>false
      param :auto_delta_start_cycle, Integer, :desc => "Cycle to start delta temperature", :required=>false
    end
  end

	swagger_path '/protocols/{protocol_id}/stages' do
		operation :post do
      extend SwaggerHelper::AuthenticationError
      
			key :summary, 'Create Stage'
			key :description, 'Create a new stage with default steps created'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Stages'
			]
      
			parameter do
				key :name, :protocol_id
				key :in, :path
				key :description, 'Protocol ID'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
      
      parameter do
        key :name, :stage_params
        key :in, :body
        key :required, false
        schema do
          property :prev_id do
    			   key :type, :integer
    			   key :format, :int64
    			   key :description, 'prev stage id or null if it is the first node'
          end
          property :stage do
            key :'$ref', :Stage
          end
        end
      end
      
			response 200 do
				key :description, 'Created stage is returned'
				schema do
          property :stage do
					  key :'$ref', :FullStage
          end
				end
			end
		end
	end

  api :POST, "/protocols/:protocol_id/stages", "Create a stage"
  param_group :stage
  param :prev_id, Integer, :desc => "prev stage id or null if it is the first node", :required=>false
  example "{'stage':{'id':1,'stage_type':'holding','name':'Holding Stage','num_cycles':1,'steps':[{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180,'ramp':{'id':1,'rate':'100.0','max':true}}}"
  def create
    @stage.prev_id = params[:prev_id]
    ret = @stage.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end

	swagger_path '/stages/{stage_id}' do
		operation :put do
      extend SwaggerHelper::AuthenticationError
      extend ParameterStageId
            
			key :summary, 'Update Stage'
			key :description, 'Update properties of a stage'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Stages'
			]

			parameter do
				key :name, :stage_params
				key :in, :body
				key :description, 'Stage to update'
				key :required, true
				schema do
          property :stage do
            key :'$ref', :Stage
          end
				end
			end
			response 200 do
				key :description, 'Updated stage is returned'
				schema do
          property :stage do
					  key :'$ref', :Stage
          end
				end
			end
		end
	end

  api :PUT, "/stages/:id", "Update a stage"
  param_group :stage
  example "{'stage':{'id':1,'stage_type':'holding','name':'Holding Stage','num_cycles':1}}"
  def update
    ret  = @stage.update_attributes(stage_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

	swagger_path '/stages/{stage_id}/move' do
		operation :post do
      extend SwaggerHelper::AuthenticationError
      extend ParameterStageId
      
			key :summary, 'Reorder Stage'
			key :description, 'Reorder a stage, prev_id is the stage id where this stage goes after'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Stages'
			]
      
			parameter do
				key :name, :prev_id
				key :in, :body
				key :description, 'stage id where this stage goes after'
				key :required, true
				schema do
          property :prev_id do
    			  key :type, :integer
    			  key :format, :int64
    			  key :description, 'prev stage id or null if it is the first node'
          end
				 end
			end
			response 200 do
				key :description, 'Moved Stage'
				schema do
          property :stage do
					  key :'$ref', :Stage
          end
				end
			end
		end
	end

  api :POST, "/stages/:id/move", "Move a stage"
  param :prev_id, Integer, :desc => "prev stage id or null if it is the first node", :required=>true
  def move
    @stage.prev_id = params[:prev_id]
    ret = @stage.save
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

	swagger_path '/stages/{stage_id}' do
		operation :delete do
      extend SwaggerHelper::AuthenticationError
      extend ParameterStageId
      
			key :summary, 'Delete Stage'
			key :description, 'Delete the entire stage'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Stages'
			]

      response 200 do
				key :description, 'Stage is Deleted'
			end
      
			response 422 do
				key :description, 'Stage delete error'
				schema do
					key :'$ref', :ErrorModel
				end
			end
		end
	end

  api :DELETE, "/stages/:id", "Destroy a stage"
  def destroy
    ret = @stage.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  protected

  def get_experiment
    if params[:action] == "create"
      @stage = Stage.new(stage_params)
      @stage.protocol_id = params[:protocol_id]
    else
      @stage = Stage.find_by_id(params[:id])
    end
    @experiment = Experiment.where("experiment_definition_id=?", @stage.protocol.experiment_definition_id).first if !@stage.nil?
  end

end

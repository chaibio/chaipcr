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
class WellsController < ApplicationController
  before_filter :ensure_authenticated_user
	include Swagger::Blocks

  respond_to :json

  resource_description {
    formats ['json']
  }

  def_param_group :well do
    param :well_num, Integer, :desc => "1-16", :required => false
    param :well_type, String, :desc => "positive_control, no_template_control, standard, sample", :required => true
    param :sample_name, String, :desc => "sample name", :required => false
    param :notes, String, :desc => "notes", :required => false
    param :targets, Array, :desc => "['channel1 target', 'channel2 target']", :required => false
  end

	swagger_path '/experiments/{id}/wells' do
		operation :get do
			key :summary, 'List of Wells'
			key :description, 'Returns all wells of the experiment'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Wells'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'id of the experiment'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			response 200 do
				key :description, 'List of all the wells is returned in an array'
				schema do
					key :name, :well
					key :type, :array
					items do
						key :'$ref', :Well
					end
				end
			end
		end
	end

  api :GET, "/wells", "List all the wells"
  def index
    @wells = Well.where("experiment_id=?", params[:experiment_id]).order("well_num")
    respond_to do |format|
      format.json { render "index", :status => :ok}
    end
  end

	swagger_path '/experiments/{id}/wells' do
		operation :put do
			key :summary, 'Update Wells'
			key :description, 'Update multiple wells at the same time for the specified experiment '
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Wells'
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
				key :name, :wells
				key :in, :body
				key :type, :array
				key :description, 'wells to update'
				key :required, true
				schema do
					 key :'$ref', :WellsInput
				 end
			end
			response 200 do
				key :description, 'List of all the wells is returned in an array'
				schema do
					key :type, :array
					items do
						key :'$ref', :Well
					end
				end
			end
		end
	end

  api :PUT, "/experiments/:experiment_id/wells", "Update wells in bulk"
  param_group :well
  example "{'wells':[{'well_num':1,'well_type':'positive_control','sample_name':'test1','notes':'test1notes', 'targets':['channel1_target', 'channel2_target']},
          {'well_num':2,'well_type':'standard','sample_name':'test2','notes':'test2notes', 'targets':['channel1_target', 'channel2_target']}]}"
  def bulk_update
    @wells = Array.new
    params[:wells].each do |params_per_well|
      well = Well.create_or_update(well_params(params_per_well))
      @wells << well if well && well.valid?
    end
    respond_to do |format|
      format.json { render "index", :status => (!@wells.blank?)? :ok :  :unprocessable_entity}
    end
  end

	swagger_path '/experiments/{id}/wells/{well_num}' do
		operation :put do
			key :summary, 'Update Well'
			key :description, 'Update a single well'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Wells'
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
				key :name, :well_num
				key :in, :path
				key :description, 'well number'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :well
				key :in, :body
				key :description, 'well to update'
				key :required, true
				schema do
					 key :'$ref', :Well_Input
				 end
			end
			response 200 do
				key :description, 'Updated well is returned'
				schema do
					key :'$ref', :Well
				end
			end
		end
	end

  api :PUT, "/experiments/:experiment_id/wells/:well_num", "Update a well"
  param_group :well
  example "{'well':{'well_type':'positive_control','sample_name':'test','notes':'blahblah', 'targets':['channel1_target', 'channel2_target']}}"
  def update
    @well = Well.create_or_update(well_params(params[:well]))
    respond_to do |format|
      format.json { render "show", :status => (@well && @well.valid?)? :ok :  :unprocessable_entity}
    end
  end

	swagger_path '/experiments/{id}/wells/{well_num}' do
		operation :delete do
			key :summary, 'Delete Well'
			key :description, 'Deletes the specified well'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Wells'
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
				key :name, :well_num
				key :in, :path
				key :description, 'well number'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			response 200 do
				key :description, 'Specified well is deleted from the experiment'
			end
		end
	end

  api :DELETE, "/experiments/:experiment_id/wells/:well_num", "Destroy a well"
  def destroy
    @well = Well.well(params[:experiment_id], params[:well_num]).first
    ret = @well.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  protected

  def well_params(params_per_well)
    well_params = ActionController::Parameters.new(params_per_well).permit(*Well::ACCESSIBLE_ATTRS).merge(:experiment_id=>params[:experiment_id], :well_num=>(params_per_well[:well_num].blank?)? params[:well_num] : params_per_well[:well_num])
    if !params_per_well[:targets].blank?
      well_params = well_params.merge(:target1=>params_per_well[:targets][0], :target2=>params_per_well[:targets][1])
    end
    well_params
  end

end

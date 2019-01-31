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
require 'zip'
require "httparty"
#require "rserve"

class ExperimentsController < ApplicationController
  include ParamsHelper
  include Swagger::Blocks

  before_filter :ensure_authenticated_user
  before_filter :allow_cors
  before_filter :get_experiment, :except => [:index, :create, :copy]

  respond_to :json

  resource_description {
    formats ['json']
  }

  RSERVE_TIMEOUT  = 240

  BackgroundTask = Struct.new(:action, :experiment_id, :complete_result) do
    def completed?
      complete_result != nil
    end

    def match?(action, experiment_id)
      return self.action == action && self.experiment_id == experiment_id
    end
  end
  @@background_task = nil
  @@background_last_task = nil

  def_param_group :experiment do
    param :experiment, Hash, :desc => "Experiment Info", :required => true do
      param :name, String, :desc => "Name of the experiment", :required => false
      param :guid, String, :desc => "GUID used for diagnostic or calibration", :required => false
    end
  end

  swagger_path '/experiments' do
    operation :get do
      key :summary, 'List all Experiments'
      key :description, 'Returns all experiments from the system sorted by the id'
      key :produces, [
        'application/json',
      ]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :type
				key :in, :query
				key :description, 'filter by type (i.e. standard)'
				key :required, false
        key :type, :string
			end
      response 200 do
        key :description, 'Object containing list of all the experiments'
        schema do
          key :type, :array
          items do
            key :'$ref', :Experiments
          end
        end
      end
    end

    operation :post do
			key :summary, 'Create Experiment'
      key :description, 'Creates a new experiment, default protocol will be created'
      key :produces, [
        'application/json'
      ]
			key :tags, [
				'Experiment'
			]
      parameter do
        key :name, :experiment
        key :in, :body
        key :description, 'Experiment to create'
        key :required, true
        schema do
           key :'$ref', :ExperimentInput
         end
      end
      response 200 do
        key :description, 'Created experiment is returned'
        schema do
          key :'$ref', :Experiment
        end
      end
      response 422 do
        key :description, 'Experiment create error'
				schema do
					key :'$ref', :Experiment
				end
      end
    end
  end

  #api :GET, "/experiments", "List all the experiments"
  #example "[{'experiment':{'id':1,'name':'test1','type':'user','started_at':null,'completed_at':null,'completed_status':null}},{'experiment':{'id':2,'name':'test2','type':'user','started_at':null,'completed_at':null,'completed_status':null}}]"
  def index
    @experiments = Experiment.includes(:experiment_definition).where("experiment_definitions.experiment_type"=>[ExperimentDefinition::TYPE_USER_DEFINED, ExperimentDefinition::TYPE_TESTKIT]).order("experiments.id DESC")
    if params[:type] == "standard"
      @experiments = @experiments.joins(:well_layout).joins("inner join targets_wells on targets_wells.well_layout_id = well_layouts.id").where("targets_wells.well_type"=>TargetsWell::TYPE_STANDARD, "completion_status"=>"success")
    end
    @experiments = @experiments.to_a
 
    respond_to do |format|
      format.json { render "index", :status => :ok }
    end
  end

  api :POST, "/experiments", "Create an experiment"
  param_group :experiment
  description "when experiment is created, default protocol will be created"
  example "{'experiment':{'id':1,'name':'test','type':'user','started_at':null,'completed_at':null,'completed_status':null,'protocol':{'id':1,'lid_temperature':'110.0','stages':[{'stage':{'id':1,'stage_type':'holding','name':'Holding Stage','num_cycles':1,'steps':[{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180,'ramp':{'id':1,'rate':'100.0','max':true}}}]}},{'stage':{'id':2,'stage_type':'cycling','name':'Cycling Stage','num_cycles':40,'steps':[{'step':{'id':2,'name':'Step 2','temperature':'95.0','hold_time':30,'ramp':{'id':2,'rate':'100.0','max':true}}},{'step':{'id':3,'name':'Step 2','temperature':'60.0','hold_time':30,'ramp':{'id':3,'rate':'100.0','max':true}}}]}},{'stage':{'id':3,'stage_type':'holding','name':'Holding Stage','num_cycles':1,'steps':[{'step':{'id':4,'name':'Step 1','temperature':'4.0','hold_time':0,'ramp':{'id':4,'rate':'100.0','max':true}}}]}}]}}}"
  def create
    if params[:experiment][:guid].nil?
      experiment_definition = ExperimentDefinition.new(:experiment_type=>ExperimentDefinition::TYPE_USER_DEFINED)
      experiment_definition.protocol_params = params[:experiment][:protocol]
    else
      experiment_definition = ExperimentDefinition.where("guid=?", params[:experiment][:guid]).first
    end
    @experiment = Experiment.new(:name=>params[:experiment][:name])
    @experiment.experiment_definition = experiment_definition
    ret = @experiment.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok : :unprocessable_entity}
    end
	end

	swagger_path '/experiments/{id}' do
		operation :put do
			key :summary, 'Update Experiment'
			key :description, 'Updates experiment'
			key :produces, [
				'application/json'
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment to update'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :experiment
				key :in, :body
				key :description, 'Experiment to update'
				key :required, true
				schema do
					 key :'$ref', :ExperimentInput
				 end
			end
			response 200 do
				key :description, 'Updated experiment is returned'
				schema do
					key :'$ref', :Experiment
				end
			end
			response 422 do
				key :description, 'Experiment update error'
				schema do
					key :'$ref', :Experiment
				end
			end
		end
	end

  api :PUT, "/experiments/:id", "Update an experiment"
  param_group :experiment
  example "{'experiment':{'id':1,'name':'test','type':'user','started_at':null,'completed_at':null,'completed_status':null}}"
  def update
    if @experiment == nil
      render json: {errors: "The experiment is not found"}, status: :not_found
      return
    end
    @experiment.targets_well_layout_id = WellLayout.for_experiment(params[:experiment][:standard_experiment_id]).pluck(:id).first if params[:experiment][:standard_experiment_id]
    ret = @experiment.update_attributes(experiment_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end

  
	swagger_path '/experiments/{id}/copy' do
		operation :post do
			key :summary, 'Copy Experiment'
			key :description, 'Creates a new copy of the experiment'
			key :produces, [
				'application/json'
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment to copy'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			response 200 do
				key :description, 'Copied experiment is retuned'
				schema do
					key :'$ref', :Experiment
				end
			end
			response 422 do
				key :description, 'Experiment copy error'
				schema do
					key :'$ref', :Experiment
				end
			end
		end
	end

  api :POST, "/experiments/:id/copy", "Copy an experiment"
  see "experiments#create", "json response"
  def copy
    old_experiment = Experiment.includes(:experiment_definition).find_by_id(params[:id]) 
    @experiment = Experiment.new({:name=>(!params[:experiment].blank?)? params[:experiment][:name] : "Copy of #{old_experiment.name}"})
    @experiment.targets_well_layout_id = old_experiment.targets_well_layout_id
    @experiment.experiment_definition = old_experiment.experiment_definition.copy
    if old_experiment.well_layout
      @experiment.well_layout = old_experiment.well_layout.copy
    end
    ret = @experiment.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end

	swagger_path '/experiments/{id}' do
		operation :get do
			key :summary, 'Show Experiment'
			key :description, 'Returns a single experiment based on the id'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment to fetch'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			response 200 do
				key :description, 'Fetched experiment is retuned'
				schema do
					key :'$ref', :Experiment
				end
			end
			response 422 do
				key :description, 'Unexpected error'
				schema do
					key :'$ref', :ErrorModel
				end
			end
		end
	end

  api :GET, "/experiments/:id", "Show an experiment"
  see "experiments#create", "json response"
  def show
		if params[:id] == "filter_by_standard"
			filter_by_standard
			return
		end
    @experiment.experiment_definition.protocol.stages.load
    respond_to do |format|
      format.json { render "fullshow", :status => (@experiment)? :ok :  :unprocessable_entity}
    end
  end

	swagger_path '/experiments/{id}' do
		operation :delete do
			key :summary, 'Delete Experiment'
			key :description, 'Deletes the experiment from the database based on id'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment to delete'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			response 200 do
				key :description, 'Experiment deleted'
			end
			response 422 do
				key :description, 'Unexpected error'
				schema do
					key :'$ref', :Experiment
				end
			end
		end
	end

  api :DELETE, "/experiments/:id", "Destroy an experiment"
  def destroy
    begin
      ret = @experiment.destroy
    rescue  => e
      ret = false
    end
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  def well_layout
    @well_layout = WellLayout.for_experiment(params[:id]).first
    if @well_layout.is_a? WellLayout
      @well_layout = @well_layout.layout
    else
      @well_layout = []
    end
  end
  
	swagger_path '/experiments/{id}/temperature_data' do
		operation :get do
			key :summary, 'Retrieve temperature data'
			key :description, 'Returns the temperature data of an experiment based on the parameters specified'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment for which we need temperature data'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :starttime
				key :in, :query
				key :description, 'Starting time in ms for temperature data'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :endtime
				key :in, :query
				key :description, 'If not specified, it returns everything to the end of the experiment, in ms'
				key :required, false
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :resolution
				key :in, :query
				key :description, 'Include data points for every x milliseconds. Must be a multiple of 1000 ms'
				key :required, false
				key :type, :integer
				key :format, :int64
			end
			response 200 do
				key :description, 'Temperature data'
				schema do
					key :type, :array
					items do
						key :'$ref', :TemperatureData
					end
				end
			end
			response :default do
				key :description, 'Unexpected error'
				schema do
					key :'$ref', :ErrorModel
				end
			end
		end
	end

  api :GET, "/experiments/:id/temperature_data?starttime=xx&endtime=xx&resolution=xx", "Retrieve temperature data"
  param :starttime, Integer, :desc => "0 means start of the experiment, in ms", :required => true
  param :endtime, Integer, :desc => "if not specified, it returns everything to the end of the experiment, in ms"
  param :resolution, Integer, :desc => "Include data points for every x milliseconds. Must be a multiple of 1000 ms"
  def temperature_data
    @temperatures =  @experiment.temperature_logs.with_range(params[:starttime], params[:endtime], params[:resolution])
    respond_to do |format|
      format.json { render "temperature_data", :status => :ok}
    end
  end

	swagger_path '/experiments/{id}/amplification_data' do
		operation :get do
			key :summary, 'Retrieve amplification data'
			key :description, 'Returns the amplification data of an experiment based on the parameters specified'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment for which we need amplification data'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :raw
				key :in, :query
				key :description, 'If raw data should be returned, by default it is not returned'
				key :type, :boolean
				key :required, false
        key :default, false
			end
			parameter do
				key :name, :background
				key :in, :query
				key :description, 'If background subtracted data should be returned, by default it is retuned'
				key :type, :boolean
				key :required, false
        key :default, true
			end
			parameter do
				key :name, :baseline
				key :in, :query
				key :description, 'If baseline subtracted data should be returned, by default it is retuned'
				key :type, :boolean
				key :required, false
        key :default, true
			end
			parameter do
				key :name, :firstderiv
				key :in, :query
				key :description, 'If first derivative data should be returned, by default it is retuned'
				key :type, :boolean
				key :required, false
				key :default, true
			end
			parameter do
				key :name, :secondderiv
				key :in, :query
				key :description, 'If second derivative data should be returned, by default it is retuned'
				key :type, :boolean
				key :required, false
				key :default, true
			end
			parameter do
				key :name, :summary
				key :in, :query
				key :description, 'If cq values should be returned, by default it is retuned'
				key :type, :boolean
				key :required, false
        key :default, true
			end
			parameter do
				key :name, :step_id
				key :in, :query
        key :description, '?'
        key :required, false
			  key :type, :array
			  items do
				  key :type, :integer
          key :format, :int64
        end
			end
			parameter do
				key :name, :ramp_id
				key :in, :query
        key :description, '?'
        key :required, false
			  key :type, :array
			  items do
				  key :type, :integer
          key :format, :int64
        end
			end

			response 200 do
				key :description, 'Amplification data'
				schema do
					key :type, :array
					items do
						key :'$ref', :AmplificationData
					end
				end
			end

			response 202 do
				key :description, 'Job accepted'
			end

      response 304 do
				key :description, 'Amplification data is not modified if etag is the same'
			end

			response :default do
				key :description, 'Unexpected error'
				schema do
					key :'$ref', :ErrorModel
				end
			end
		end
	end

  api :GET, "/experiments/:id/amplification_data?raw=false&background=true&baseline=true&firstderiv=true&secondderiv=true&summary=true&step_id[]=43&step_id[]=44", "Retrieve amplification data"
  example "{'partial':false, 'total_cycles':40, 'steps':['step_id':2,
            'amplification_data':[['target_id', 'well_num', 'cycle_num', 'background_subtracted_value', 'baseline_subtracted_value', 'dr1_pred', 'dr2_pred' 'fluorescence_value'], [1, 1, 1, 25488, -2003, 34543, 453344, 86], [1, 1, 2, 53984, -409, 56345, 848583, 85]],
            'summary_data':[['target_id','well_num','replic_group','cq','quantity_m','quantity_b','mean_cq','mean_quantity_m','mean_quantity_b'], [1,1,null,null,null,null,null,null,null], [2,12,1,7.314787,4.0,2,6.9858934999999995,4.0,2], [2,14,1,6.657,4.0,2,6.9858934999999995,4.0,2], [2,3,null,6.2,5.7952962,14,null,null,null]],
            'targets':[['id','name','equation'],[1,'target1',null],[2,'target2',{'slope':-0.064624,'offset':7.154049,'efficiency':2979647189313701.5,'r2':0.221279}]]
          ]}"
  def amplification_data
    params[:raw] = params[:raw].to_bool if !params[:raw].nil?
    params[:background] = params[:background].to_bool if !params[:background].nil?
		params[:baseline] = params[:baseline].to_bool if !params[:baseline].nil?
		params[:firstderiv] = params[:firstderiv].to_bool if !params[:firstderiv].nil?
		params[:secondderiv] = params[:secondderiv].to_bool if !params[:secondderiv].nil?
    params[:summary] = params[:summary].to_bool if !params[:summary].nil?

    if params[:step_id].nil? && params[:ramp_id].nil?
      #first step that collects data will be returned, if none of the steps can be found, first ramp that collect data will be returned
      params[:raw] = false if params[:raw].nil?
      params[:background] = true if params[:background].nil? && params[:raw] == false
      params[:baseline] = true if params[:baseline].nil? && params[:raw] == false
			params[:firstderiv] = true if params[:firstderiv].nil? && params[:raw] == false
			params[:secondderiv] = true if params[:secondderiv].nil? && params[:raw] == false
      params[:summary] = true if params[:summary].nil? && params[:raw] == false
    else #if step_id is specified, only raw data is returned
      params[:raw] = true
      params[:background] = false
      params[:baseline] = false
			params[:firstderiv] = false
			params[:secondderiv] = false
      params[:summary] = false
    end

    if @experiment
      if @experiment.ran?
        @first_stage_collect_data = Stage.collect_data(@experiment.experiment_definition_id).first
        if !@first_stage_collect_data.blank?
          last_cycle = FluorescenceDatum.last_cycle(@experiment.id, @first_stage_collect_data.id)
          @partial = (@experiment.running? && last_cycle < @first_stage_collect_data.num_cycles)
          analyze_required = params[:background] == true || params[:baseline] == true || params[:firstderiv] == true || params[:secondderiv] == true || params[:summary] == true
          if analyze_required
            begin
              task_submitted = background_calculate_amplification_data(@experiment, @first_stage_collect_data.id)
            rescue => e
              render :json=>e.to_s, :status => 500
              return
            end

            standard_curve_pending = false
            if task_submitted.nil? && params[:summary] == true
              begin
                task_submitted = background_run_standard_curve(@experiment)
              rescue => e
                render :json=>e.to_s, :status => 500
                return
              end
              standard_curve_pending = true if !task_submitted.nil?
            end

            if @partial == false
              @partial = FluorescenceDatum.new_data_generated?(@experiment.id, @first_stage_collect_data.id)
            end

            if !stale?(etag: generate_etag(@partial, AmplificationDatum.maxid(@experiment.id, @first_stage_collect_data.id), standard_curve_pending))
              #render 304 Not Modified
              return
            end

            fake_targets = TargetsWell.fake_targets?(@experiment)
            @amplification_data = AmplificationDatum.retrieve(@experiment, @first_stage_collect_data.id, fake_targets).to_a
            if @amplification_data.blank? && !task_submitted.nil?
              #no data but background task is submitted
              render :nothing => true, :status => (task_submitted)? 202 : 503
              return
            elsif !@amplification_data.blank?
              #set etag
              fresh_when(:etag => generate_etag(@partial, AmplificationDatum.maxid(@experiment.id, @first_stage_collect_data.id), standard_curve_pending))
            end
          end

          if params[:raw] == true
            if !analyze_required && !stale?(etag: generate_etag(@partial, last_cycle, standard_curve_pending))
              #render 304 Not Modified
              return
            end

            #construct OR clause
            conditions = String.new
            wheres = Array.new
            Constants::KEY_NAMES.each do |keyname|
              keyvalue = params[keyname.to_sym]
              if keyvalue
                conditions << " OR " unless conditions.length == 0
                conditions << "#{keyname} IN (?)"
                if keyvalue.is_a? Array
                  wheres << keyvalue
                else
                  wheres << keyvalue.to_i
                end
              end
            end
            wheres.insert(0, conditions) if !conditions.blank?
            #logger.info ("**********#{wheres.join(",")}")
            #query to database
            if !wheres.blank?
              fluorescence_data = FluorescenceDatum.order(Constants::KEY_NAMES.join(", ")).for_experiment(@experiment.id).where(wheres)
            else
              fluorescence_data = FluorescenceDatum.for_stage(@first_stage_collect_data.id).for_experiment(@experiment.id)
            end
            fluorescence_data = fluorescence_data.filtered_by_targets(@experiment.well_layout.id, fake_targets).order_by_target(fake_targets).to_a

            if !analyze_required && !fluorescence_data.blank?
              #set etag
              fresh_when(:etag => generate_etag(@partial, fluorescence_data.last.cycle_num, standard_curve_pending))
            end
          end
        end

        if !@amplification_data.blank?
          if !fluorescence_data.blank?
            #amplification_data only have one step
            fluorescence_offset = 0
            if !@amplification_data[0].sub_type.nil?
              sub_type = (@amplification_data[0].sub_type + "_id").to_sym
              sub_id = @amplification_data[0].send(sub_type)
              while fluorescence_offset < fluorescence_data.count && fluorescence_data[fluorescence_offset].send(sub_type) != sub_id do
                fluorescence_offset += 1
              end
            end
            @amplification_data.each_index do |i|
              @amplification_data[i].fluorescence_value = fluorescence_data[fluorescence_offset+i].fluorescence_value
            end
          end
        elsif !fluorescence_data.blank?
          @amplification_data = fluorescence_data
        end

        #####################################################################################################
        #format output
        @partial = true if standard_curve_pending
        attributes = []
        attributes << "background_subtracted_value" if params[:background] == true
        attributes << "baseline_subtracted_value" if params[:baseline] == true
				attributes << "dr1_pred" if params[:firstderiv] == true
				attributes << "dr2_pred" if params[:secondderiv] == true
        attributes << "fluorescence_value" if params[:raw] == true
        
        #summary data
        summary_data = nil
        if fake_targets == true
          summary_data = AmplificationCurve.retrieve(@experiment.id, @first_stage_collect_data.id).select("channel as target_id").to_a
          targets = TargetsWell.fake_targets
        elsif params[:summary] == true && @first_stage_collect_data
          summary_data = TargetsWell.filtered.with_data(@experiment, @first_stage_collect_data).to_a
          targets = TargetsWell.process_data(summary_data)
        else
          targets = nil
        end
        
        @amplification_data_group = group_by_keynames(@amplification_data, attributes, summary_data, targets)
        #####################################################################################################

        respond_to do |format|
          format.json { render "amplification_data", :status => :ok}
        end
      else
        render :json=>{:errors=>"experiment has not run yet"}, :status => 500
      end
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end

	swagger_path '/experiments/{id}/melt_curve_data' do
		operation :get do
			key :summary, 'Retrieve melt curve data'
			key :description, 'Returns the melt curve data of an experiment based on the parameters specified'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment for which we need melt curve data'
				key :required, true
				key :type, :integer
				key :format, :int64
			end
			parameter do
				key :name, :raw
				key :in, :query
				key :description, 'If raw data should be returned, by default it is not returned'
				key :type, :boolean
				key :required, false
        key :default, false
			end
			parameter do
				key :name, :normalized
				key :in, :query
				key :description, 'If normalized data should be returned, by default it is returned'
				key :type, :boolean
  			key :required, false
        key :default, true
			end
			parameter do
				key :name, :derivative
				key :in, :query
				key :description, 'If derivative data should be returned, by default it is returned'
				key :type, :boolean
        key :required, false
        key :default, true
			end
			parameter do
				key :name, :tm
				key :in, :query
				key :description, 'If tm values should be returned, by default it is returned'
				key :type, :boolean
				key :required, false
        key :default, true
			end
			parameter do
				key :name, :ramp_id
				key :in, :query
        key :description, '?'
        key :required, false
			  key :type, :array
			  items do
				  key :type, :integer
          key :format, :int64
        end
			end

			response 200 do
				key :description, 'Melt curve data along with etag header'
				schema do
					key :type, :array
					items do
						key :'$ref', :MeltData
					end
				end
			end

			response 202 do
				key :description, 'Job accepted'
			end

      response 304 do
				key :description, 'Melt curve data is not modified if etag is the same'
			end

			response :default do
				key :description, 'Unexpected error'
				schema do
					key :'$ref', :ErrorModel
				end
			end
		end
	end

  api :GET, "/experiments/:id/melt_curve_data?raw=false&normalized=true&derivative=true&tm=true&ramp_id[]=43&ramp_id[]=44", "Retrieve melt curve data"
  example "{'partial':false, 'ramps':['ramp_id':22,
            'melt_curve_data':[{'well_num':1, 'target_id':1, 'temperature':[0,1,2,3,4,5], 'normalized_data':[0,1,2,3,4,5], 'derivative_data':[0,1,2,3,4,5], 'tm':[1,2,3], 'area':[2,4,5]},
                               {'well_num':2, 'target_id':1, 'temperature':[0,1,2,3,4,5], 'normalized_data':[0,1,2,3,4,5], 'derivative_data':[0,1,2,3,4,5], 'tm':[1,2,3], 'area':[2,4,5]}]],
            'targets':[{'target_id':1,'target_name':'Ch 1'},{'target_id':2,'target_name':'Ch 2'}]
           }"
  def melt_curve_data
    params[:raw] = params[:raw].to_bool if !params[:raw].nil?
    params[:normalized] = params[:normalized].to_bool if !params[:normalized].nil?
    params[:derivative] = params[:derivative].to_bool if !params[:derivative].nil?
    params[:tm] = params[:tm].to_bool if !params[:tm].nil?

    if params[:ramp_id].nil?
      #first step that collects data will be returned, if none of the steps can be found, first ramp that collect data will be returned
      params[:raw] = false if params[:raw].nil?
      params[:normalized] = true if params[:normalized].nil?
      params[:derivative] = true if params[:derivative].nil?
      params[:tm] = true if params[:tm].nil?
    else #if ramp_id is specified, only raw data is returned
      params[:raw] = true
      params[:normalized] = false
      params[:derivative] = false
      params[:tm] = false
    end

    if @experiment
      if @experiment.ran?
        @first_stage_meltcurve_data = Stage.melt_curve(@experiment.experiment_definition_id).first
        if !@first_stage_meltcurve_data.blank?
          @partial = @experiment.running?
          analyze_required = params[:normalized] == true || params[:derivative] == true || params[:tm] == true
          if analyze_required
            begin
              task_submitted = background_calculate_melt_curve_data(@experiment, @first_stage_meltcurve_data.id)
            rescue => e
              render :json=>e.to_s, :status => 500
              return
            end

            if @partial == false
              @partial = MeltCurveDatum.new_data_generated?(@experiment, @first_stage_meltcurve_data.id) != nil
            end

            if !@experiment.cached_temperature.nil? && !stale?(etag: generate_etag(@partial, @experiment.cached_temperature))
              #render 304 Not Modified
              return
            end

            fake_targets = TargetsWell.fake_targets?(@experiment)
            @melt_curve_data = CachedMeltCurveDatum.retrieve(@experiment, @first_stage_meltcurve_data.id, fake_targets).to_a

            if @melt_curve_data.blank? && !task_submitted.nil?
              #no data but background task is submitted
              render :nothing => true, :status => (task_submitted)? 202 : 503
              return
            elsif !@experiment.cached_temperature.nil?
              #set etag
              fresh_when(:etag => generate_etag(@partial, @experiment.cached_temperature))
            end
          end

          if params[:raw] == true
            if !analyze_required && !stale?(etag: generate_etag(@partial, MeltCurveDatum.maxid(@experiment.id, @first_stage_meltcurve_data.id)))
              #render 304 Not Modified
              return
            end

            #construct OR clause
            conditions = String.new
            wheres = Array.new
            keyvalue = params[:ramp_id]
            if keyvalue
              conditions << " OR " unless conditions.length == 0
              conditions << "ramp_id IN (?)"
              if keyvalue.is_a? Array
                wheres << keyvalue
              else
                wheres << keyvalue.to_i
              end
            end
            wheres.insert(0, conditions) if !conditions.blank?
            #logger.info ("**********#{wheres.join(",")}")

            #query to database
            if !wheres.blank?
              raw_data = MeltCurveDatum.for_experiment(@experiment.id).where(wheres).group_by_well
            else
              raw_data = MeltCurveDatum.for_stage(@first_stage_meltcurve_data.id).for_experiment(@experiment.id).group_by_well
            end
            raw_data = raw_data.filtered_by_targets(@experiment.well_layout.id, fake_targets).order_by_target(fake_targets).to_a

            if !analyze_required && !raw_data.blank?
              #set etag
              max_id = raw_data.max_by(&:id).id
              #logger.info("**************max_id=#{max_id}")
              fresh_when(:etag => generate_etag(@partial, max_id))
            end
          end
        end

        if !@melt_curve_data.blank?
          if !raw_data.blank?
            #melt_curve_data only have one ramp
            ramp_id = @melt_curve_data[0].ramp_id
            fluorescence_offset = 0
            while fluorescence_offset < raw_data.count && raw_data[fluorescence_offset].ramp_id != ramp_id do
              fluorescence_offset += 1
            end
            @melt_curve_data.each_index do |i|
              @melt_curve_data[i].fluorescence_data = raw_data[fluorescence_offset+i].fluorescence_data
            end
          end
        elsif !raw_data.blank?
          @melt_curve_data = raw_data
        end

        if fake_targets == true
          @targets = TargetsWell.fake_targets
        end

        if !@melt_curve_data.blank?
          @melt_curve_data_group = []
          melt_curve_data_hash = @melt_curve_data.group_by { |obj| obj.ramp_id }
          melt_curve_data_hash.each do |ramp_id, data_array|
            @melt_curve_data_group << OpenStruct.new(:ramp_id=>ramp_id, :melt_curve_data=>data_array)
          end
          @targets ||= @melt_curve_data.uniq { |s| s.target_id }
        else
          @targets ||= []
        end

        respond_to do |format|
          format.json { render "melt_curve_data", :status => :ok}
        end
      else
        render :json=>{:errors=>"experiment has not run yet"}, :status => 500
      end
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end
  
	swagger_path '/experiments/{id}/export' do
		operation :get do
			key :summary, 'Export Experiment'
			key :description, 'Downloads a zip file which has csv files for temperature, amplification and meltcurve data'
			key :produces, [
				'application/zip',
			]
			key :tags, [
				'Experiment'
			]
			parameter do
				key :name, :id
				key :in, :path
				key :description, 'Id of the experiment for which we need melt curve data'
				key :required, true
				key :type, :integer
				key :format, :int64
			end

			response 200 do
				key :description, 'Zipped data'
				schema do
          key :type, :string
          key :format, :binary
				end
			end

			response 202 do
				key :description, 'Job accepted'
			end

			response :default do
				key :description, 'Unexpected error'
				schema do
					key :'$ref', :ErrorModel
				end
			end
		end
	end

  api :GET, "/experiments/:id/export", "zip temperature, amplification and meltcurv csv files"
  def export
    t = Tempfile.new("tmpexport_#{request.remote_ip}")
    experiment_dir = "qpcr_experiment_#{(@experiment)? @experiment.name : "null"}"
    begin
      Zip::OutputStream.open(t.path) do |out|
        if request.method != "HEAD"
          out.put_next_entry("#{experiment_dir}/temperature_log.csv")
          out.write TemperatureLog.as_csv(params[:id])
        end

        if request.method != "HEAD"
          out.put_next_entry("#{experiment_dir}/experiment.csv")
          out.write @experiment.as_csv
        end

        fake_targets = TargetsWell.fake_targets?(@experiment)

        first_stage_collect_data = Stage.collect_data(@experiment.experiment_definition_id).first
        if first_stage_collect_data
          begin
            task_submitted = background_calculate_amplification_data(@experiment, first_stage_collect_data.id)
            amplification_data = AmplificationDatum.retrieve(@experiment, first_stage_collect_data.id, fake_targets)

            if !task_submitted.nil? && (!@experiment.running? || amplification_data.blank?)
              #background task is submitted
              #if experiment is finished, wait for the task to complete
              #if amplification_data is empty, wait for the task to complete
              t.close
              render :nothing => true, :status => (task_submitted)? 202 : 503
              return
            end
          rescue => e
            logger.error("export amplification data failed: #{e}")
          end

          if request.method == "HEAD"
            amplification_data = nil
          else
            fluorescence_data = FluorescenceDatum.for_stage(first_stage_collect_data.id).for_experiment(@experiment.id).filtered_by_targets(@experiment.well_layout.id, fake_targets).order_by_target(fake_targets).to_a

            if fake_targets == true
              targets = AmplificationCurve.retrieve(@experiment.id, first_stage_collect_data.id).filtered_by_targets(@experiment.well_layout.id, fake_targets).to_a
            else
              targets = TargetsWell.with_data(@experiment, first_stage_collect_data).with_samples.to_a
              TargetsWell.process_data(targets)
            end
          end
        end

        if amplification_data
          out.put_next_entry("#{experiment_dir}/amplification_data.csv")
          columns = ["baseline_subtracted_value", "background_subtracted_value", "dr1_pred", "dr2_pred", "fluorescence_value", "channel", "well_num", "target_name", "cycle_num"]
          fluorescence_index = 0
          csv_string = CSV.generate do |csv|
            csv << columns
            amplification_data.each do |data|
              while (fluorescence_index < fluorescence_data.length &&
                    !(fluorescence_data[fluorescence_index].channel == data.channel &&
                      fluorescence_data[fluorescence_index].well_num == data.well_num &&
                      fluorescence_data[fluorescence_index].cycle_num == data.cycle_num)) do
                        fluorescence_index += 1
              end
              fluorescence_value = (fluorescence_index < fluorescence_data.length)? fluorescence_data[fluorescence_index].fluorescence_value : nil
              attributes = data.attributes
              attributes["fluorescence_value"] = fluorescence_value
              csv << attributes.values_at(*columns)
              fluorescence_index += 1
            end
          end
          out.write csv_string
        end

        first_stage_meltcurve_data = Stage.melt_curve(@experiment.experiment_definition_id).first
        if first_stage_meltcurve_data
          begin
            task_submitted = background_calculate_melt_curve_data(@experiment, first_stage_meltcurve_data.id)
            melt_curve_data = CachedMeltCurveDatum.retrieve(@experiment, first_stage_meltcurve_data.id, fake_targets)

            if !task_submitted.nil? && (!@experiment.running? || melt_curve_data.blank?)
              #background task is submitted
              #if experiment is finished, wait for the task to complete
              #if amplification_data is empty, wait for the task to complete
              t.close
              render :nothing => true, :status => (task_submitted)? 202 : 503
              return
            end
          rescue => e
            logger.error("export melt curve data failed: #{e}")
          end

          if request.method == "HEAD"
            melt_curve_data = nil
          end
        end

        if melt_curve_data
          out.put_next_entry("#{experiment_dir}/melt_curve_data.csv")
          columns = ["channel", "well_num", "target_name", "temperature", "normalized_data", "derivative_data"]
          out.write columns.to_csv

          targets ||= []
          if fake_targets == false
            melt_curve_data = melt_curve_data.with_samples.select("targets_wells.omit as omit, targets_wells.well_type as well_type, targets_wells.quantity_m as quantity_m, targets_wells.quantity_b as quantity_b").unscope(where: :targets_wells)
          end
          melt_curve_data.each do |data|
            if !data.respond_to?(:omit) || data.omit == 0
              data.temperature.each_index do |index|
                out.write "#{data.channel}, #{data.well_num}, #{data.target_name}, #{data.temperature[index]}, #{data.normalized_data[index]}, #{data.derivative_data[index]}\r\n"
              end
            end

            index = targets.index { |x| x.well_num == data.well_num && x.target_id == data.target_id }
            if index
              if data.tm
                targets[index].class.send(:define_method, :tm) { return @tm }
                targets[index].instance_variable_set("@tm", data.tm)
              end
            else
              targets.push(TargetsWell.new(data))
            end
          end
        end

        if targets
          targets = targets.sort_by { |target| [target.well_num, target.target_name] }
          out.put_next_entry("#{experiment_dir}/analysis.csv")
          csv_string = CSV.generate do |csv|
            csv << ["well_num", "well", "omit", "sample_name", "target_type", "target_name", "channel", "cq", "cq_mean", "quantity", "quantity_mean", "Tm1", "Tm2", "Tm3", "Tm4"];
            targets.each do |target|
              csv << [target.well_num, well_name(target.well_num), 
                      (target.respond_to?(:omit))? target.omit : nil, 
                      (target.respond_to?(:sample_name))? target.sample_name : nil, 
                      (target.respond_to?(:well_type))? target.well_type : nil, 
                      target.target_name,
                      target.channel, 
                      target.cq, 
                      (target.respond_to?(:mean_cq))? target.mean_cq : nil, 
                      (target.respond_to?(:quantity))? TargetsWell.to_scientific_notation_str(target.quantity) : nil, 
                      (target.respond_to?(:mean_quantity))? TargetsWell.to_scientific_notation_str(target.mean_quantity) : nil] + ((target.respond_to?(:tm))? target.tm : [nil, nil, nil, nil])
            end
          end
          out.write csv_string
        end
      end
      send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "export.zip"
    ensure
      t.close
    end
  end

  def analyze
    if @experiment && !@experiment.experiment_definition.guid.blank?
      if @experiment.completion_status == "success"
        cached_data = CachedAnalyzeDatum.where(:experiment_id=>@experiment.id).first
        if cached_data.nil? #no cache data found
          begin
            task_submitted = background_analyze_data(@experiment)
            render :nothing => true, :status => (task_submitted)? 202 : 503
          rescue  => e
            render :json=>e.to_s, :status => 500
          end
        else
          render :json=>cached_data.analyze_result
        end
      elsif !@experiment.ran?
        render :json=>{:errors=>"Please run the experiment before calling analyze"}, :status => 500
      elsif !@experiment.running?
        render :json=>{:errors=>"Please wait for the experiment to be completed before calling analyze"}, :status => 500
      else
        render :json=>{:errors=>"experiment cannot be analyzed because it wasn't completed successfully (status=#{completion_status})"}, :status => 500
      end
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end
  
  protected

  def well_name(well_num)
    if well_num >= 1 && well_num <= 8
      return "A#{well_num}"
    else
      return "B#{well_num-8}"
    end
  end

  def get_experiment
    @experiment = Experiment.find_by_id(params[:id]) if @experiment.nil?
  end

  def generate_etag(partial, tag1, tag2=nil)
    return "partial:#{partial} tag:#{tag1} #{(tag2)? "tag2:"+tag2.to_s : ""}"
  end
  
  def background_standard_curve_data(experiment)
    if experiment.completion_status != "success"
      return nil
    end
    
    well_layout = WellLayout.for_experiment(experiment.id).first
    if well_layout.is_a? WellLayout
      wells = well_layout.standard_curve
    else
      wells = []
    end
    body = wells.map {|well| (well)? well.as_json_standard_curve : {}}
    logger.info("body=#{body.to_json}")
    
    if body.blank?
      return nil
    end
 
    background("standardcurve", experiment.id) do
      begin
        start_time = Time.now
        response = HTTParty.post("http://127.0.0.1:8081/experiments/#{@experiment.id}/standard_curve", body: body.to_json)
        logger.info("Julia code time #{Time.now-start_time}")
        if response.code != 200
          raise_julia_error(response)
        else
          jsonbody = JSON.parse(response.body)
          if jsonbody["targets"]
            equations = []
            jsonbody["targets"].each do |target_body|
              target_id = target_body.delete("target_id")
              equations << CachedStandardCurveDatum.new(:well_layout_id=>well_layout.id, :target_id=>target_id, :equation=>target_body.to_json) if !target_id.blank?
            end
          end
        end
      rescue  => e
        logger.error("Julia error: #{e}")
        raise e
      ensure
      end
      #update cache
      CachedStandardCurveDatum.import equations, :on_duplicate_key_update => [:equation] if !equations.blank?
    end
    
  end
  

  def background_calculate_amplification_data(experiment, stage_id)
    return nil if !FluorescenceDatum.new_data_generated?(experiment.id, stage_id)
    experiment.experiment_definition #load experiment_definition before go to background thread
    return background("amplification", experiment.id) do
      amplification_data, cts = calculate_amplification_data(experiment, stage_id, experiment.calibration_id)
      #update cache
      AmplificationDatum.import amplification_data, :on_duplicate_key_update => [:background_subtracted_value,:baseline_subtracted_value,:dr1_pred,:dr2_pred]
      AmplificationCurve.import cts, :on_duplicate_key_update => [:ct]
    end
  end

  def calculate_amplification_data(experiment, stage_id, calibration_id)
   # sleep(10)
  #  return  [AmplificationDatum.new(:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>1, :well_num=>1, :cycle_num=>1, :background_subtracted_value=>1001, :baseline_subtracted_value=>102)], [AmplificationCurve.new(:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>1, :well_num=>1, :ct=>10)]

    step = Step.collect_data(stage_id).first
    if step
      sub_id = step.id
      sub_type = "step"
    else
      ramp = Ramp.collect_data(stage_id).first
      if ramp
        sub_id = ramp.id
        sub_type = "ramp"
      else
        return nil, nil
      end
    end

#    config   = Rails.configuration.database_configuration
#    connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
    start_time = Time.now
    begin
      body = {calibration_info: calibrate_hash(calibration_id), experiment_id: experiment.id, raw_data: FluorescenceDatum.julia_hash(experiment.id, sub_type, sub_id)}
      amplification_option = (experiment.experiment_definition.amplification_option.nil?)? AmplificationOption.new : experiment.experiment_definition.amplification_option
      body = body.merge(amplification_option.to_hash)
      body = body.merge("#{sub_type}_id"=>sub_id)
      logger.info("body=#{body.to_json}")
      response = HTTParty.post("http://127.0.0.1:8081/experiments/#{experiment.id}/amplification", body: body.to_json, timeout: 180)
      if response.code != 200
        raise_julia_error(response)
      else
        results = JSON.parse(response.body)
      end

#     results = connection.eval("tryCatchError(get_amplification_data, '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment.id}, list(#{sub_type}_id=#{sub_id}), #{calibrate_info(calibration_id)} #{","+experiment.experiment_definition.amplification_option.to_rserve_params if !experiment.experiment_definition.amplification_option.nil?})")
#      results = results.to_ruby
    rescue  => e
      logger.error("Julia error: #{e}")
#      kill_process("Rserve") if e.is_a? Rserve::Talk::SocketTimeoutError
      raise e
    ensure
#      connection.close
    end
    logger.info("R code time #{Time.now-start_time}")
    logger.info("results=#{results}")
    start_time = Time.now
    amplification_data = []
    cts = []
    if !results.blank?
#     new julia code
      background_subtracted_results = results["rbbs_ary3"]
      baseline_subtracted_results = results["blsub_fluos"]
			first_derivative_results = results["dr1_pred"]
			second_derivative_results = results["dr2_pred"]
      cq_results = results["cq"]
      (0...background_subtracted_results.length).each do |channel|
        num_wells = background_subtracted_results[channel].length
        (0...num_wells).each do |well_num|
          num_cycles = background_subtracted_results[channel][well_num].length
          (0...num_cycles).each do |cycle_num|
            background_subtracted_value = background_subtracted_results[channel][well_num][cycle_num]
            baseline_subtracted_value = baseline_subtracted_results[channel][well_num][cycle_num]
						dr1_pred = first_derivative_results[channel][well_num][cycle_num]
						dr2_pred = second_derivative_results[channel][well_num][cycle_num]
            amplification_data << AmplificationDatum.new(:experiment_id=>experiment.id, :stage_id=>stage_id, :sub_type=>sub_type, :sub_id=>sub_id, :channel=>channel+1, :well_num=>well_num+1, :cycle_num=>cycle_num+1, :background_subtracted_value=>background_subtracted_value,
																												 :baseline_subtracted_value=>baseline_subtracted_value, :dr1_pred=>dr1_pred, :dr2_pred=>dr2_pred)
          end
        end
        (0...cq_results[channel].length).each do |well_num|
          cts << AmplificationCurve.new(:experiment_id=>experiment.id, :stage_id=>stage_id, :channel=>channel+1, :well_num=>well_num+1, :ct=>cq_results[channel][well_num])
        end
      end
=begin
      raise results["message"] if !results["message"].blank? #catched error
      (0...results[0].length).each do |channel|
         background_subtracted_results = results[0][channel]
         baseline_subtracted_results = results[1][channel]
         if background_subtracted_results.is_a? Array
           num_cycles = 1
           num_wells = background_subtracted_results.length-1
         else
           num_cycles = background_subtracted_results.row_size
           num_wells = background_subtracted_results.column_size-1
         end
         (0...num_wells).each do |well_num|
           (0...num_cycles).each do |cycle_num|
             background_subtracted_value = (background_subtracted_results.is_a? Array)? background_subtracted_results[well_num+1] : background_subtracted_results[cycle_num, well_num+1]
             baseline_subtracted_value = (baseline_subtracted_results.is_a? Array)? baseline_subtracted_results[well_num] : baseline_subtracted_results[cycle_num, well_num]
             amplification_data << AmplificationDatum.new(:experiment_id=>experiment.id, :stage_id=>stage_id, :sub_type=>sub_type, :sub_id=>sub_id, :channel=>channel+1, :well_num=>well_num+1, :cycle_num=>cycle_num+1, :background_subtracted_value=>background_subtracted_value, :baseline_subtracted_value=>baseline_subtracted_value)
           end
         end
         ct_results = results[2][channel]
         (0...ct_results.column_size).each do |well_num|
           cts << AmplificationCurve.new(:experiment_id=>experiment.id, :stage_id=>stage_id, :channel=>channel+1, :well_num=>well_num+1, :ct=>ct_results[0,well_num])
         end
      end
      #amplification_data.sort_by!{|x| [x.channel,x.well_num,x.cycle_num]}
=end
    end
    logger.info("Rails code time #{Time.now-start_time}")
    return amplification_data, cts
  end

  def background_calculate_melt_curve_data(experiment, stage_id)
    new_data = MeltCurveDatum.new_data_generated?(experiment, stage_id)
    return nil if new_data.nil?
    return background("meltcurve", experiment.id) do
      melt_curve_data = calculate_melt_curve_data(experiment, stage_id, experiment.calibration_id)
      #update cache
      CachedMeltCurveDatum.import melt_curve_data, :on_duplicate_key_update => [:temperature_text, :normalized_data_text, :derivative_data_text, :tm_text, :area_text]
      #update cached_temperature
      if melt_curve_data.last
        cached_temperature = (experiment.running?)? melt_curve_data.last.temperature.last : new_data.temperature
        if cached_temperature
          experiment.update_attributes(:cached_temperature=>cached_temperature)
        end
      end
    end
  end

  def calculate_melt_curve_data(experiment, stage_id, calibration_id)
  #  sleep(10)
  #  return [CachedMeltCurveDatum.new({:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>1, :well_num=>1, :temperature=>[121,122], :fluorescence_data=>[1001, 1002], :derivative=>[3,4], :tm=>[1,2,3], :area=>[1,2,5]})]

#    config   = Rails.configuration.database_configuration
#    connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
    start_time = Time.now
    begin
      body = {calibration_info: calibrate_hash(calibration_id), experiment_id: experiment.id, stage_id: stage_id, raw_data: MeltCurveDatum.julia_hash(experiment.id, stage_id)}
      body = body.merge({qt_prob: 0.1, max_normd_qtv:0.9}) if experiment.experiment_definition.guid == "thermal_consistency"
      logger.info("body=#{body.to_json}")
      response = HTTParty.post("http://127.0.0.1:8081/experiments/#{experiment.id}/meltcurve", body: body.to_json)
      if response.code != 200
        raise_julia_error(response)
      else
        results = JSON.parse(response.body)
      end

#      results = connection.eval("tryCatchError(process_mc, '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment.id}, #{stage_id}, #{calibrate_info(calibration_id)} #{", qt_prob=0.1, max_normd_qtv=0.9" if experiment.experiment_definition.guid == "thermal_consistency"})")
#      results = results.to_ruby
    rescue  => e
      logger.error("Julia error: #{e}")
#      kill_process("Rserve") if e.is_a? Rserve::Talk::SocketTimeoutError
      raise e
    ensure
#      connection.close
    end
    logger.info("R code time #{Time.now-start_time}")
    #logger.info("results=#{results}")
    start_time = Time.now
    ramp = Ramp.collect_data(stage_id).first
    melt_curve_data = []
    if !results.blank?
      melt_curve_results = results["melt_curve_data"]
      melt_curve_analysis_results = results["melt_curve_analysis"]
      (0...melt_curve_results.length).each do |channel|
        melt_curve_results[channel].each_index do |i|
          melt_curve_results_per_well = melt_curve_results[channel][i]
          melt_curve_analysis_per_well = melt_curve_analysis_results[channel][i]
          hash = CachedMeltCurveDatum.new({:experiment_id=>experiment.id, :stage_id=>stage_id, :ramp_id=>(ramp)? ramp.id : nil, :channel=>channel+1, :well_num=>i+1, :temperature=>melt_curve_results_per_well[0], :normalized_data=>melt_curve_results_per_well[1], :derivative_data=>melt_curve_results_per_well[2], :tm=>melt_curve_analysis_per_well[0], :area=>melt_curve_analysis_per_well[1]})
          melt_curve_data << hash
        end
      end
=begin
      raise results["message"] if !results["message"].blank? #catched error
      (0...results.length).each do |channel|
        results[channel].each_index do |i|
          results_per_well = results[channel][i]
          hash = CachedMeltCurveDatum.new({:experiment_id=>experiment.id, :stage_id=>stage_id, :ramp_id=>(ramp)? ramp.id : nil, :channel=>channel+1, :well_num=>i+1, :temperature=>results_per_well[0][0], :normalized_data=>results_per_well[0][1], :derivative_data=>results_per_well[0][2], :tm=>(results_per_well[1][0].blank?)? [] : (results_per_well[1][0].is_a? Array)? results_per_well[1][0] : [results_per_well[1][0]], :area=>(results_per_well[1][1].blank?)? [] : (results_per_well[1][1].is_a? Array)? results_per_well[1][1] : [results_per_well[1][1]]})
          melt_curve_data << hash
        end
      end
=end
    end
    logger.info("Rails code time #{Time.now-start_time}")
    return melt_curve_data
  end

  def optical_cal(experiment)
    {calibration_info: calibrate_hash(experiment.id)}
  end
  
  def thermal_performance_diagnostic(experiment)
    TemperatureLog.julia_hash(experiment.id)
  end
  
  def thermal_consistency(experiment)
    {calibration_info: calibrate_hash(experiment.calibration_id), raw_data: MeltCurveDatum.julia_hash(experiment.id, 4)}
  end
  
  def optical_test_single_channel(experiment)
    fluorescence_values = FluorescenceDatum.fluorescence_for_steps(experiment.id, [12, 13])
    #??? fluorescence_values check nil
    {baseline: {fluorescence_value: fluorescence_values[0][0]}, excitation:{fluorescence_value: fluorescence_values[1][0]}}
  end
  
  def optical_test_dual_channel(experiment)
    fluorescence_values = FluorescenceDatum.fluorescence_for_steps(experiment.id, [14, 15, 17, 19])
    {baseline: {fluorescence_value: fluorescence_values[0]},
     water: {fluorescence_value: fluorescence_values[1]},
     FAM: {fluorescence_value: fluorescence_values[2]},
     HEX: {fluorescence_value: fluorescence_values[3]}}
  end
  
  def background_analyze_data(experiment)
    background("analyze", experiment.id) do
#      config   = Rails.configuration.database_configuration
#      connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
      begin
        if experiment.experiment_definition.guid == "optical_cal" || experiment.experiment_definition.guid == "dual_channel_optical_cal_v2"
          body = optical_cal(experiment)
          logger.info("body=#{body.to_json}")
          response = HTTParty.post("http://127.0.0.1:8081/experiments/#{experiment.id}/optical_cal", body: body.to_json)
        elsif self.class.method_defined?(experiment.experiment_definition.guid)
          body = send(experiment.experiment_definition.guid, experiment)
          logger.info("body=#{body.to_json}")
          response = HTTParty.post("http://127.0.0.1:8081/experiments/#{experiment.id}/#{experiment.experiment_definition.guid}", body: body.to_json)
        else
          raise "**#{experiment.experiment_definition.guid}** not implemented"
        end
      
        if response.code != 200
          raise_julia_error(response)
        else
          new_data = CachedAnalyzeDatum.new(:experiment_id=>experiment.id, :analyze_result=>response.body)
          #update analyze status
          if experiment.diagnostic?
            analysis_results = JSON.parse(response.body)
            experiment.update_attributes(:analyze_status=>(analysis_results["valid"] != true)? "failed" : "success")
          end
        end

#        connection.eval("source(\"#{Rails.configuration.dynamic_file_path}/#{experiment.experiment_definition.guid}/analyze.R\")")
#        response = connection.eval("tryCatchError(analyze, '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment.id}, #{calibrate_info(experiment.calibration_id)})").to_ruby
      rescue  => e
        logger.error("Julia error: #{e}")
#        kill_process("Rserve") if e.is_a? Rserve::Talk::SocketTimeoutError
        raise e
      ensure
#        connection.close
      end
#      raise response["message"] if response && response.is_a?(Array) && !response["message"].blank?

      #update cache
      CachedAnalyzeDatum.import [new_data], :on_duplicate_key_update => [:analyze_result]
    end
  end

  def calibrate_info(calibration_id)
    protocol = Protocol.includes(:stages).where("protocols.experiment_definition_id=(SELECT experiment_definition_id from experiments where experiments.id=#{calibration_id} LIMIT 1)").first
    if protocol && protocol.stages[0]
      water_index = protocol.stages[0].steps.find_index{|item| item.name == "Water"}
      step_water = (!water_index.nil?)? protocol.stages[0].steps[water_index].id : nil
      if Device.dual_channel?
        if calibration_id == 1
          channel_1_index = protocol.stages[0].steps.find_index{|item| item.name == "Signal"}
          channel_2_index = channel_1_index
        else
          channel_1_index = protocol.stages[0].steps.find_index{|item| item.name == "FAM"}
          channel_2_index = protocol.stages[0].steps.find_index{|item| item.name == "HEX"}
          baseline_index = protocol.stages[0].steps.find_index{|item| item.name == "Baseline"}
        end
      else
        channel_1_index = protocol.stages[0].steps.find_index{|item| item.name == "Signal"}
        channel_2_index = nil
      end
      step_channel_1 = (!channel_1_index.nil?)? protocol.stages[0].steps[channel_1_index].id : nil
      step_channel_2 = (!channel_2_index.nil?)? protocol.stages[0].steps[channel_2_index].id : nil
      step_baseline = (!baseline_index.nil?)? protocol.stages[0].steps[baseline_index].id : nil
      result = "list(water=list(calibration_id=#{calibration_id},step_id=#{step_water}), channel_1=list(calibration_id=#{calibration_id},step_id=#{step_channel_1}) \
              #{(step_channel_2)? ", channel_2=list(calibration_id="+calibration_id.to_s+",step_id="+step_channel_2.to_s+")" : ""} \
              #{(step_baseline)? ", baseline=list(calibration_id="+calibration_id.to_s+",step_id="+step_baseline.to_s+")" : ""})"
    end
    result
  end

  def calibrate_hash(calibration_id)
    if calibration_id == 1
      if Device.dual_channel?
        result = {:water=>{:fluorescence_value=>FluorescenceDatum::FAKE_CALIBRATION_DUAL_CHANNEL_WATER},
                  :channel_1=>{:fluorescence_value=>FluorescenceDatum::FAKE_CALIBRATION_DUAL_CHANNEL_FAM},
                  :channel_2=>{:fluorescence_value=>FluorescenceDatum::FAKE_CALIBRATION_DUAL_CHANNEL_HEX}}
      else
        result = {:water=>{:fluorescence_value=>FluorescenceDatum::FAKE_CALIBRATION_SINGLE_CHANNEL_WATER},
                  :channel_1=>{:fluorescence_value=>FluorescenceDatum::FAKE_CALIBRATION_SINGLE_CHANNEL_SIGNAL}}
      end
    else
      protocol = Protocol.includes(:stages).where("protocols.experiment_definition_id=(SELECT experiment_definition_id from experiments where experiments.id=#{calibration_id} LIMIT 1)").references(:stages).first
      if protocol && protocol.stages[0]
        water_index = protocol.stages[0].steps.find_index{|item| item.name == "Water"}
        step_water = (!water_index.nil?)? protocol.stages[0].steps[water_index].id : nil
        if Device.dual_channel?
          channel_1_index = protocol.stages[0].steps.find_index{|item| item.name == "FAM"}
          channel_2_index = protocol.stages[0].steps.find_index{|item| item.name == "HEX"}
          baseline_index = protocol.stages[0].steps.find_index{|item| item.name == "Baseline"}
        else
          channel_1_index = protocol.stages[0].steps.find_index{|item| item.name == "Signal"}
          channel_2_index = nil
        end
        step_channel_1 = (!channel_1_index.nil?)? protocol.stages[0].steps[channel_1_index].id : nil
        step_channel_2 = (!channel_2_index.nil?)? protocol.stages[0].steps[channel_2_index].id : nil
        step_baseline = (!baseline_index.nil?)? protocol.stages[0].steps[baseline_index].id : nil

        logger.info ("************calibration_id=#{calibration_id} channel_1=#{step_channel_1}, channel_2=#{step_channel_2}, baseline=#{step_baseline}")
        fluorescence_values = FluorescenceDatum.fluorescence_for_steps(calibration_id, [step_water, step_channel_1, step_channel_2, step_baseline])

        result = {:water=>{:fluorescence_value=>fluorescence_values[0]},
                  :channel_1=>{:fluorescence_value=>fluorescence_values[1]}}
        result.merge!(:channel_2=>{:fluorescence_value=>fluorescence_values[2]}) if !fluorescence_values[2].nil?
        result.merge!(:baseline=>{:fluorescence_value=>fluorescence_values[3]}) if !fluorescence_values[3].nil?
      end
    end
    result
  end
  
  def background(action, experiment_id, &block)
    if @@background_last_task && @@background_last_task.match?(action, experiment_id)
      error = @@background_last_task.complete_result
      @@background_last_task = nil
      raise error
    elsif @@background_task == nil
      @@background_task = BackgroundTask.new(action, experiment_id, nil)
      Thread.new do
        begin
          yield
        rescue => e
          logger.error ("background task error: #{e}")
          @@background_task.complete_result = e
          @@background_last_task = @@background_task
        ensure
          ActiveRecord::Base.connection.close
          @@background_task = nil
        end
      end
      return true #background process is started
    elsif @@background_task.match?(action, experiment_id)
      return true #@@background_task process is still in progress
    else
      return false #there is already another background process, return resource unavailable
    end
  end

  def group_by_keynames(data, data_attributes, summary_data, targets)
    return nil if data.nil?

    keyname = nil
    key = nil
    data_array = nil
    group = Array.new
    column_names = ["target_id","well_num","cycle_num"]+data_attributes

    data.each do |node|
      Constants::KEY_NAMES.each do |newkeyname|
        newkeyname = newkeyname.to_sym
        sub_id = node.send(newkeyname)
        if sub_id != nil && sub_id != key
          group << OpenStruct.new(keyname=>key, :amplification_data=>data_array) if key != nil
          keyname = newkeyname
          key = sub_id
          data_array = []
          data_array << column_names
        end
      end
      data_array << column_names.map {|method| node.send(method)}
    end

    if key != nil
      elem = OpenStruct.new(keyname=>key, :amplification_data=>data_array)
      if !summary_data.blank?
        elem.summary_data = [["target_id","well_num","replic_group", "cq", "quantity_m", "quantity_b", "mean_cq", "mean_quantity_m", "mean_quantity_b"]]+summary_data.map {|data| 
                             [data.target_id,data.well_num,data.replic,data.cq,data.quantity[0],data.quantity[1],data.mean_cq,data.mean_quantity[0],data.mean_quantity[1]]}
      end
      if !targets.blank?
        elem.targets = [["id", "name", "equation"]] + targets.map {|target| [target.target_id, target.target_name, target.target_equation]}
      end
      group << elem
    end

    return group
  end

  def raise_julia_error(response)
    logger.error("Julia error response code: #{response.code}, #{response.body}")
    if response.code == 500 && !response.body.blank?
      error = JSON.parse(response.body)["error"]
      error = error["msg"] if error.is_a?(Hash) && !error["msg"].blank?
      raise ({errors: error}.to_json)
    else
      raise "Julia error (code=#{response.code}): #{response.inspect}"
    end
  end
  
  def background_run_standard_curve(experiment)
    if experiment.targets_well_layout_id
      if !CachedStandardCurveDatum.where(:well_layout_id=>experiment.targets_well_layout_id).exists?
        parent_experiment = Experiment.for_well_layout(experiment.targets_well_layout_id)
        first_stage_collect_data = Stage.collect_data(parent_experiment.experiment_definition_id).first
        if first_stage_collect_data
          task_submitted = background_calculate_amplification_data(parent_experiment, first_stage_collect_data.id)
        end
        if task_submitted.nil?
          task_submitted = background_standard_curve_data(parent_experiment)
        end
      end
    end
    
    if task_submitted.nil? && experiment.well_layout && !CachedStandardCurveDatum.where(:well_layout_id=>experiment.well_layout.id).exists?
      logger.info("***********background run standard curve #{task_submitted}")
      task_submitted = background_standard_curve_data(experiment)
    end
    
    task_submitted
  end
  
end

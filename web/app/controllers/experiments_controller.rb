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
require 'rserve'

class ExperimentsController < ApplicationController
  include ParamsHelper
  
  before_filter :ensure_authenticated_user
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
  
  api :GET, "/experiments", "List all the experiments"
  example "[{'experiment':{'id':1,'name':'test1','type':'user','started_at':null,'completed_at':null,'completed_status':null}},{'experiment':{'id':2,'name':'test2','type':'user','started_at':null,'completed_at':null,'completed_status':null}}]"
  def index
    @experiments = Experiment.includes(:experiment_definition).where("experiment_definitions.experiment_type"=>"user").load
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
      experiment_definition = ExperimentDefinition.new(:name=>params[:experiment][:name], :experiment_type=>ExperimentDefinition::TYPE_USER_DEFINED)
      experiment_definition.protocol_params = params[:experiment][:protocol]
    else
      experiment_definition = ExperimentDefinition.where("guid=?", params[:experiment][:guid]).first
    end
    @experiment = Experiment.new
    @experiment.experiment_definition = experiment_definition
    ret = @experiment.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :PUT, "/experiments/:id", "Update an experiment"
  param_group :experiment
  example "{'experiment':{'id':1,'name':'test','type':'user','started_at':null,'completed_at':null,'completed_status':null}}"
  def update
    if @experiment == nil || !@experiment.experiment_definition.editable? #if experiment has been run, the name is still editable
      render json: {errors: "The experiment is not editable"}, status: :unprocessable_entity
      return
    end
    ret = @experiment.experiment_definition.update_attributes(experiment_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :POST, "/experiments/:id/copy", "Copy an experiment"
  see "experiments#create", "json response"
  def copy
    old_experiment = Experiment.includes(:experiment_definition).find_by_id(params[:id])
    experiment_definition = old_experiment.experiment_definition.copy(params[:experiment]? experiment_params : nil)
    @experiment = Experiment.new
    @experiment.experiment_definition = experiment_definition
    ret = @experiment.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :GET, "/experiments/:id", "Show an experiment"
  see "experiments#create", "json response"
  def show
    @experiment.experiment_definition.protocol.stages.load
    respond_to do |format|
      format.json { render "fullshow", :status => (@experiment)? :ok :  :unprocessable_entity}
    end
  end
  
  api :DELETE, "/experiments/:id", "Destroy an experiment"
  def destroy
    ret = @experiment.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok :  :unprocessable_entity}
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

  api :GET, "/experiments/:id/amplification_data", "Retrieve amplification data"
  example "{'total_cycles':40,
            'amplification_data':[['channel', 'well_num', 'cycle_num', 'background_substracted_value', 'baseline_Substracted_value'], [1, 1, 1, 25488, -2003], [1, 1, 2, 53984, -409]],
            'ct':[['channel', 'well_num', 'ct'], [1, 1, 12.11], [1, 2, 15.77], [1, 3, null]]}"
  def amplification_data
    if @experiment
      if @experiment.ran?
        if params[:step_id] == nil && params[:ramp_id] == nil
          @first_stage_collect_data = Stage.collect_data.where(["experiment_definition_id=?",@experiment.experiment_definition_id]).first
          if !@first_stage_collect_data.blank?
            begin
              task_submitted = background_calculate_amplification_data(@experiment, @first_stage_collect_data.id)
            rescue => e
              render :json=>{:errors=>e.to_s}, :status => 500
              return
            end

            if !stale?(etag: AmplificationDatum.maxid(@experiment.id, @first_stage_collect_data.id))
              #render 304 Not Modified
              return
            end

            @amplification_data = AmplificationDatum.retrieve(@experiment.id, @first_stage_collect_data.id)
            @cts = AmplificationCurve.retrieve(@experiment.id, @first_stage_collect_data.id)

            if @amplification_data.blank? && !task_submitted.nil?
              #no data but background task is submitted
              render :nothing => true, :status => (task_submitted)? 202 : 503
              return
            elsif @amplification_data && @amplification_data.last
              #set etag
              fresh_when(:etag => @amplification_data.last.id)
              @partial = (@first_stage_collect_data.num_cycles > @amplification_data.last.cycle_num)
            else
              @partial = true
            end
          else
            @amplification_data = []
            @cts = []
            @partial = false
          end
        else
          #construct OR clause
          conditions = String.new
          wheres = Array.new
          if params[:step_id]
            conditions << " OR " unless conditions.length == 0
            conditions << "step_id IN (?)"
            wheres << params[:step_id].map(&:to_i)
          end
          if params[:ramp_id]
            conditions << " OR " unless conditions.length == 0
            conditions << "ramp_id IN (?)"
            wheres << params[:ramp_id].map(&:to_i)
          end
          wheres.insert(0, conditions)
          #query to database
          @fluorescence_data = FluorescenceDatum.where("experiment_id=?",@experiment.id).where(wheres).order("step_id, ramp_id, cycle_num, well_num")
          #group data
          keyname = nil
          key = nil
          datalist = nil
          @amplification_data_group = Array.new
          @fluorescence_data.each do |data|
            if data.step_id != nil && data.step_id != key
              @amplification_data_group << OpenStruct.new(keyname=>key, :data=>datalist) if key != nil
              key = data.step_id
              keyname = :step_id
              datalist = [data]
            elsif data.ramp_id != nil && data.ramp_id != key
              @amplification_data_group << OpenStruct.new(keyname=>key, :data=>datalist) if key != nil
              key = data.ramp_id
              keyname = :ramp_id
              datalist = [data]
            else
              datalist << data
            end
          end
          @amplification_data_group << OpenStruct.new(keyname=>key, :data=>datalist) if key != nil
          respond_to do |format|
            format.json { render "amplification_data_group", :status => :ok}
          end
          return
        end
      else
        @amplification_data = []
        @cts = []
        @partial = false
      end
    
      @amplification_data = (!@amplification_data.blank?)? [["channel","well_num","cycle_num","background_substracted_value", "baseline_Substracted_value"]]+@amplification_data.map {|data| [data.channel,data.well_num,data.cycle_num,data.background_subtracted_value,data.baseline_subtracted_value]} : nil
      @cts = (!@cts.blank?)? [["channel","well_num","ct"]]+@cts.map {|ct| [ct.channel,ct.well_num,ct.ct]} : nil
      respond_to do |format|
        format.json { render "amplification_data", :status => :ok}
      end
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end
  
  api :GET, "/experiments/:id/melt_curve_data", "Retrieve melt curve data"
  example "{'melt_curve_data':[{'well_num':0, 'temperature':[0,1,2,3,4,5], 'fluorescence_data':[0,1,2,3,4,5], 'derivative':[0,1,2,3,4,5], 'tm':[1,2,3], 'area':[2,4,5]},
                               {'well_num':1, 'temperature':[0,1,2,3,4,5], 'fluorescence_data':[0,1,2,3,4,5], 'derivative':[0,1,2,3,4,5], 'tm':[1,2,3], 'area':[2,4,5]}]}"
  def melt_curve_data
    if @experiment
      if @experiment.ran?
        @first_stage_meltcurve_data = Stage.joins(:protocol).where(["experiment_definition_id=? and stage_type='meltcurve'", @experiment.experiment_definition_id]).first
        if !@first_stage_meltcurve_data.blank?
          begin
            task_submitted = background_calculate_melt_curve_data(@experiment, @first_stage_meltcurve_data.id)
          rescue => e
            render :json=>{:errors=>e.to_s}, :status => 500
            return
          end

          if !stale?(etag: CachedMeltCurveDatum.maxid(@experiment.id, @first_stage_meltcurve_data.id))
            #render 304 Not Modified
            return
          end

          @melt_curve_data = CachedMeltCurveDatum.retrieve(@experiment.id, @first_stage_meltcurve_data.id)

          if @melt_curve_data.blank? && !task_submitted.nil?
            #no data but background task is submitted
            render :nothing => true, :status => (task_submitted)? 202 : 503
            return
          elsif @melt_curve_data && @melt_curve_data.last
            #set etag
            fresh_when(:etag => @melt_curve_data.last.id)
          end
          @partial = @experiment.running? || !MeltCurveDatum.new_data_generated?(@experiment, @first_stage_meltcurve_data.id).nil?
        else
          @melt_curve_data = []
          @partial = false
        end
      else
        @melt_curve_data = []
        @partial = false
      end
      respond_to do |format|
        format.json { render "melt_curve_data", :status => :ok}
      end
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end

  api :GET, "/experiments/:id/export", "zip temperature, amplification and meltcurv csv files"
  def export
    t = Tempfile.new("tmpexport_#{request.remote_ip}")
    buffer = Zip::OutputStream.open(t.path) do |out|
      out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/temperature_log.csv")
      out.write TemperatureLog.as_csv(params[:id])
      
      first_stage_collect_data = Stage.collect_data.where(["experiment_definition_id=?",@experiment.experiment_definition_id]).first
      if first_stage_collect_data
        begin
          task_submitted = background_calculate_amplification_data(@experiment, first_stage_collect_data.id)
          if task_submitted.nil? #cached
            amplification_data = AmplificationDatum.retrieve(@experiment, first_stage_collect_data.id)
            cts = AmplificationCurve.retrieve(@experiment, first_stage_collect_data.id)
          else
            t.close
            render :nothing => true, :status => (task_submitted)? 202 : 503
            return
          end
        rescue => e
          logger.error("export amplification data failed: #{e}")
        end
        fluorescence_data = FluorescenceDatum.data(@experiment.id, first_stage_collect_data.id)
      end
      
      if amplification_data
        out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/amplification.csv")
        columns = ["channel", "well_num", "cycle_num"]
        fluorescence_index = 0
        csv_string = CSV.generate do |csv|
          csv << ["baseline_subtracted_value", "background_subtracted_value", "fluorescence_value"]+columns
          amplification_data.each do |data|
            while (fluorescence_index < fluorescence_data.length && 
                  !(fluorescence_data[fluorescence_index].channel == data.channel && 
                    fluorescence_data[fluorescence_index].well_num+1 == data.well_num && 
                    fluorescence_data[fluorescence_index].cycle_num == data.cycle_num)) do
                  fluorescence_index += 1
            end
            fluorescence_value = (fluorescence_index < fluorescence_data.length)? fluorescence_data[fluorescence_index].fluorescence_value : nil
            csv << [data.baseline_subtracted_value, data.background_subtracted_value, fluorescence_value]+data.attributes.values_at(*columns)
            fluorescence_index += 1
          end
        end
        out.write csv_string
      end

      if cts
        out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/ct.csv")
        csv_string = CSV.generate do |csv|
          csv << ["channel", "well_num", "ct"];
          cts.each do |ct|
            csv << [ct.channel, ct.well_num, ct.ct]
          end
        end
        out.write csv_string
      end

      first_stage_meltcurve_data = Stage.joins(:protocol).where(["experiment_definition_id=? and stage_type='meltcurve'", @experiment.experiment_definition_id]).first
      if first_stage_meltcurve_data
        begin
          task_submitted = background_calculate_melt_curve_data(@experiment, first_stage_meltcurve_data.id)
          if task_submitted.nil? #cached
            melt_curve_data = CachedMeltCurveDatum.retrieve(@experiment.id, first_stage_meltcurve_data.id)
          else
            t.close
            render :nothing => true, :status => (task_submitted)? 202 : 503
            return
          end
        rescue => e
          logger.error("export melt curve data failed: #{e}")
        end
      end

      if melt_curve_data
        out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/melt_curve_data.csv")
        columns = ["channel", "well_num", "temperature", "fluorescence_data", "derivative"]
        out.write columns.to_csv
        melt_curve_data.each do |data|
          data.temperature.each_index do |index|
            out.write "#{data.channel}, #{data.well_num}, #{data.temperature[index]}, #{data.fluorescence_data[index]}, #{data.derivative[index]}\r\n"
          end
        end

        out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/melt_curve_analysis.csv")
        columns = ["channel", "well_num", "Tm1", "Tm2", "Tm3", "Tm4", "area1", "area2", "area3", "area4"]
        csv_string = CSV.generate do |csv|
          csv << columns
          melt_curve_data.each do |data|
            tm_arr = Array.new(4)
            data.tm.each_index{|i| tm_arr[i] = data.tm[i]}
            area_arr = Array.new(4)
            data.area.each_index{|i| area_arr[i] = data.area[i]}
            csv << [data.channel, data.well_num]+tm_arr+area_arr
          end
        end
        
        out.write csv_string
      end
    end
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "export.zip"
    t.close
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
            render :json=>{:errors=>e}, :status => 500
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
  
  def get_experiment
    @experiment = Experiment.find_by_id(params[:id]) if @experiment.nil?
  end
  
  def background_calculate_amplification_data(experiment, stage_id)
    return nil if !FluorescenceDatum.new_data_generated?(experiment.id, stage_id)
    return background("amplification", experiment.id) do
      amplification_data, cts = calculate_amplification_data(experiment.id, stage_id, experiment.calibration_id)
      #update cache
      AmplificationDatum.import amplification_data, :on_duplicate_key_update => [:background_subtracted_value,:baseline_subtracted_value]
      AmplificationCurve.import cts, :on_duplicate_key_update => [:ct]
    end
  end
  
  def calculate_amplification_data(experiment_id, stage_id, calibration_id)
   # sleep(10)
  #  return  [AmplificationDatum.new(:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>1, :well_num=>1, :cycle_num=>1, :background_subtracted_value=>1001, :baseline_subtracted_value=>102)], [AmplificationCurve.new(:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>1, :well_num=>1, :ct=>10)]
    config   = Rails.configuration.database_configuration
    connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
    start_time = Time.now
    begin
      results = connection.eval("tryCatchError(get_amplification_data, '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment_id}, #{stage_id}, #{calibrate_info(calibration_id)})")
    rescue  => e
      logger.error("Rserve error: #{e}")
      kill_process("Rserve") if e.is_a? Rserve::Talk::SocketTimeoutError
      raise e
    ensure
      connection.close
    end
    logger.info("R code time #{Time.now-start_time}")
    start_time = Time.now
    results = results.to_ruby
    amplification_data = []
    cts = []
    if !results.blank?
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
             amplification_data << AmplificationDatum.new(:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>channel+1, :well_num=>well_num+1, :cycle_num=>cycle_num+1, :background_subtracted_value=>background_subtracted_value, :baseline_subtracted_value=>baseline_subtracted_value)
           end
         end
         ct_results = results[2][channel]
         (0...ct_results.column_size).each do |well_num|
           cts << AmplificationCurve.new(:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>channel+1, :well_num=>well_num+1, :ct=>ct_results[0,well_num])
         end
      end
      #amplification_data.sort_by!{|x| [x.channel,x.well_num,x.cycle_num]}
    end
    logger.info("Rails code time #{Time.now-start_time}")
    return amplification_data, cts
  end

  def background_calculate_melt_curve_data(experiment, stage_id)
    new_data = MeltCurveDatum.new_data_generated?(experiment, stage_id)
    return nil if new_data.nil?
    return background("meltcurve", experiment.id) do
      melt_curve_data = calculate_melt_curve_data(experiment.id, stage_id, experiment.calibration_id)
      #update cache
      CachedMeltCurveDatum.import melt_curve_data, :on_duplicate_key_update => [:temperature_text, :fluorescence_data_text, :derivative_text, :tm_text, :area_text]
      #update cached_temperature
      if melt_curve_data.last
        cached_temperature = (experiment.running?)? melt_curve_data.last.temperature.last : new_data.temperature
        if cached_temperature
          experiment.update_attributes(:cached_temperature=>cached_temperature)
        end
      end
    end
  end
  
  def calculate_melt_curve_data(experiment_id, stage_id, calibration_id)
  #  sleep(10)
  #  return [CachedMeltCurveDatum.new({:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>1, :well_num=>1, :temperature=>[121,122], :fluorescence_data=>[1001, 1002], :derivative=>[3,4], :tm=>[1,2,3], :area=>[1,2,5]})]
    
    config   = Rails.configuration.database_configuration
    connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
    start_time = Time.now
    begin
      results = connection.eval("tryCatchError(process_mc, '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment_id}, #{stage_id}, #{calibrate_info(calibration_id)})")
    rescue  => e
      logger.error("Rserve error: #{e}")
      kill_process("Rserve") if e.is_a? Rserve::Talk::SocketTimeoutError
      raise e
    ensure
      connection.close
    end
    logger.info("R code time #{Time.now-start_time}")
    start_time = Time.now
    results = results.to_ruby
    melt_curve_data = []
    if !results.blank?
      raise results["message"] if !results["message"].blank? #catched error
      (0...results.length).each do |channel|
        results[channel].each_index do |i|
          results_per_well = results[channel][i]
          hash = CachedMeltCurveDatum.new({:experiment_id=>experiment_id, :stage_id=>stage_id, :channel=>channel+1, :well_num=>i+1, :temperature=>results_per_well[0][0], :fluorescence_data=>results_per_well[0][1], :derivative=>results_per_well[0][2], :tm=>(results_per_well[1][0].blank?)? [] : (results_per_well[1][0].is_a? Array)? results_per_well[1][0] : [results_per_well[1][0]], :area=>(results_per_well[1][1].blank?)? [] : (results_per_well[1][1].is_a? Array)? results_per_well[1][1] : [results_per_well[1][1]]})
          melt_curve_data << hash
        end
      end
    end 
    logger.info("Rails code time #{Time.now-start_time}")
    return melt_curve_data
  end

  def background_analyze_data(experiment)
    background("analyze", experiment.id) do
      config   = Rails.configuration.database_configuration
      connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
      begin
        connection.eval("source(\"#{Rails.configuration.dynamic_file_path}/#{experiment.experiment_definition.guid}/analyze.R\")")
        response = connection.eval("tryCatchError(analyze, '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment.id}, #{calibrate_info(experiment.calibration_id)})").to_ruby
        new_data = CachedAnalyzeDatum.new(:experiment_id=>experiment.id, :analyze_result=>response)
      rescue  => e
        logger.error("Rserve error: #{e}")
        kill_process("Rserve") if e.is_a? Rserve::Talk::SocketTimeoutError
        raise e
      ensure
        connection.close
      end
      raise response["message"] if response && !response["message"].blank? #catched error

      #update analyze status
      if experiment.diagnostic?
        experiment.update_attributes(:analyze_status=>(response.include?("false"))? "failed" : "success")
      end
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
  
end

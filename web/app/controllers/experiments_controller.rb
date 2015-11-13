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
  
  RSERVE_TIMEOUT  = 30
  
  def_param_group :experiment do
    param :experiment, Hash, :desc => "Experiment Info", :required => true do
      param :name, String, :desc => "Name of the experiment", :required => false
      param :guid, String, :desc => "GUID used for diagnostic or calibration", :required => false
    end
  end
  
  api :GET, "/experiments", "List all the experiments"
  example "[{'experiment':{'id':1,'name':'test1','type':'user','started_at':null,'completed_at':null,'completed_status':null}},{'experiment':{'id':2,'name':'test2','type':'user','started_at':null,'completed_at':null,'completed_status':null}}]"
  def index
    @experiments = Experiment.includes(:experiment_definition).where("experiment_definitions.experiment_type"=>"user").all
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
    @experiment.experiment_definition.protocol.stages.all
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

  api :GET, "/experiments/:id/fluorescence_data", "Retrieve fluorescence data"
  example "{'fluorescence_datum':{'baseline_subtracted_value':1.4299,'background_subtracted_value':1.234,'well_num':1,'cycle_num':1}, 'fluorescence_datum':{'baseline_subtracted_value':1.4299,'background_subtracted_value':1.234,'well_num':2,'cycle_num':1}}"
  def fluorescence_data
    if @experiment
      @first_stage_collect_data = Stage.collect_data.where(["experiment_definition_id=?",@experiment.experiment_definition_id]).first
      if !@first_stage_collect_data.blank?
        begin
          @fluorescence_data, @ct = retrieve_fluorescence_data(@experiment.id, @first_stage_collect_data.id, @experiment.calibration_id)
        rescue => e
           render :json=>{:errors=>"Internal Server Error (#{e})"}, :status => 500
           return
        end
      end
      respond_to do |format|
        format.json { render "fluorescence_data", :status => :ok}
      end
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end
  
  api :GET, "/experiments/:id/melt_curve_data", "Retrieve melt curve data"
  example "{'melt_curve_datum':{'well_num':0, 'temperature':[0,1,2,3,4,5], 'fluorescence_data':[0,1,2,3,4,5], 'derivative':[0,1,2,3,4,5]}}"
  def melt_curve_data
    if @experiment
      @first_stage_meltcurve_data = Stage.joins(:protocol).where(["experiment_definition_id=? and stage_type='meltcurve'", @experiment.experiment_definition_id]).first
      if !@first_stage_meltcurve_data.blank?
        begin
          @melt_curve_data = retrieve_melt_curve_data(@experiment.id, @first_stage_meltcurve_data.id, @experiment.calibration_id)
        rescue => e
           render :json=>{:errors=>"Internal Server Error (#{e})"}, :status => 500
           return
        end
      end
      respond_to do |format|
        format.json { render "melt_curve_data", :status => :ok}
      end
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end
    
  api :GET, "/experiments/:id/export.zip", "zip temperature, fluorescence and meltcurv csv files"
  def export
    respond_to do |format|
      format.zip {
        buffer = Zip::OutputStream.write_buffer do |out|
          out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/temperature_log.csv")
          out.write TemperatureLog.as_csv(params[:id])
          
          first_stage_collect_data = Stage.collect_data.where(["experiment_definition_id=?",@experiment.experiment_definition_id]).first
          if first_stage_collect_data
            begin
              fluorescence_data, ct = retrieve_fluorescence_data(@experiment.id, first_stage_collect_data.id, @experiment.calibration_id)
            rescue => e
            end
          end
          
          out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/fluorescence.csv")
          columns = ["well_num", "cycle_num"]
          csv_string = CSV.generate do |csv|
            csv << ["baseline_subtracted_value", "background_subtracted_value"]+columns
            if fluorescence_data
              fluorescence_data.each do |fluorescence_data|
                csv << [fluorescence_data.baseline_subtracted_value, fluorescence_data.background_subtracted_value]+fluorescence_data.attributes.values_at(*columns)
              end
            end
          end
          out.write csv_string
          
          out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/ct.csv")
          csv_string = CSV.generate do |csv|
            csv << ["well_num", "ct"];
            if ct
              i = 0
              ct.each do |e|
                csv << [i, e]
                i += 1
              end
            end
          end
          out.write csv_string
          
          out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/melt_curve.csv")
          out.write MeltCurveDatum.as_csv(params[:id])
        end
        buffer.rewind
        send_data buffer.sysread
      }
    end
  end
  
  def analyze
    if @experiment && !@experiment.experiment_definition.guid.blank?
      config   = Rails.configuration.database_configuration
      connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
      begin
        connection.eval("source(\"#{Rails.configuration.dynamic_file_path}/#{@experiment.experiment_definition.guid}/analyze.R\")")
        response = connection.eval("analyze('#{config[Rails.env]["database"]}', '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', #{@experiment.id})").to_ruby
      rescue  => e
        logger.error("Rserve error: #{e}")
        kill_rserve
        render :json=>{:errors=>"Internal Server Error (#{e})"}, :status => 500
      ensure
        connection.close
      end
      json = JSON.parse(response)
      render :json=>json
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end
  
  protected
  
  def get_experiment
    @experiment = Experiment.find_by_id(params[:id]) if @experiment.nil?
  end
  
  def retrieve_fluorescence_data(experiment_id, stage_id, calibration_id)
    config   = Rails.configuration.database_configuration
    connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
    start_time = Time.now
    begin
      logger.info("*************call amplification_data")
      results = connection.eval("get_amplification_data('#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment_id}, #{stage_id}, #{calibration_id})")
    rescue  => e
      logger.error("Rserve error: #{e}")
      kill_rserve
      raise e
    ensure
      connection.close
    end
    logger.info("R code time #{Time.now-start_time}")
    start_time = Time.now
    results = results.to_ruby
    fluorescence_data = []
    if !results.blank?
      background_subtracted_results = results[0]
      baseline_subtracted_results = results[1][0]
      (1...background_subtracted_results.length).each do |well_num|
        (0...background_subtracted_results[well_num].length).each do |cycle_num|
          fluorescence_data << FluorescenceDatum.new(:experiment_id=>params[:id], :well_num=>well_num-1, :cycle_num=>cycle_num+1, :background_subtracted_value=>background_subtracted_results[well_num][cycle_num], :baseline_subtracted_value=>baseline_subtracted_results[cycle_num, well_num-1])
        end
      end
      ct = results[2][0].row(0)
    end 
    logger.info("Rails code time #{Time.now-start_time}")
    return fluorescence_data, ct
  end
  
  def retrieve_melt_curve_data(experiment_id, stage_id, calibration_id)
    config   = Rails.configuration.database_configuration
    connection = Rserve::Connection.new(:timeout=>RSERVE_TIMEOUT)
    start_time = Time.now
    begin
      results = connection.eval("process_mc('#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment_id}, #{stage_id}, #{calibration_id})")
    rescue  => e
      logger.error("Rserve error: #{e}")
      kill_rserve
      raise e
    ensure
      connection.close
    end
    logger.info("R code time #{Time.now-start_time}")
    start_time = Time.now
    results = results.to_ruby
    melt_curve_data = []
    if !results.blank?
      results.each_index do |i|
        results_per_well = results[i]
        hash = OpenStruct.new({:well_num=>i, :temperature=>results_per_well[0][0], :fluorescence_data=>results_per_well[0][1], :derivative=>results_per_well[0][2]})
        melt_curve_data << hash
      end
    end 
    logger.info("Rails code time #{Time.now-start_time}")
    return melt_curve_data
  end
  
  def kill_rserve
    processes = `ps -ef | grep Rserve`
    logger.info(processes)
    processes.lines.each do |process|
      nodes = process.split(/\W+/)
      cmd = "kill -9 #{nodes[1]}"
      logger.info(cmd)
      system(cmd)
    end
  end
  
end
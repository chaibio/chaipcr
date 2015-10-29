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

  api :GET, "/experiments/:id/fluorescence_data?mode=[background_subtracted:baseline_subtracted]", "Retrieve fluorescence data"
  example "{'fluorescence_datum':{'calibrated_value':1.4299,'well_num':1,'cycle_num':1}, 'fluorescence_datum':{'calibrated_value':1.4974,'well_num':2,'cycle_num':1}}"
  
#  def fluorescence_data
#    @fluorescence_data = @experiment.fluorescence_data.select("cycle_num, well_num, AVG(fluorescence_value) as fluorescence_value").group("cycle_num, well_num").order("cycle_num, well_num")
#    respond_to do |format|
#      format.json { render "fluorescence_data", :status => :ok}
#    end
#  end
  
  def fluorescence_data
    if @experiment
      @first_stage_collect_data = Stage.collect_data.where(["experiment_definition_id=?",@experiment.experiment_definition_id]).first
      if !@first_stage_collect_data.blank?
        if params[:mode] == "baseline_subtracted"
          @fluorescence_data = retrieve_baseline_data(@experiment.id, @first_stage_collect_data.id, @experiment.calibration_id)
        else
          @fluorescence_data = retrieve_fluorescence_data(@experiment.id, @first_stage_collect_data.id, @experiment.calibration_id)
        end
      end
      respond_to do |format|
        format.json { render "fluorescence_data", :status => :ok}
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
          
          out.put_next_entry("qpcr_experiment_#{(@experiment)? @experiment.name : "null"}/fluorescence.csv")
          first_stage_collect_data = Stage.collect_data.where(["experiment_definition_id=?",@experiment.experiment_definition_id]).first
          columns = ["well_num", "cycle_num"]
          csv_string = CSV.generate do |csv|
            csv << ["calibrated_value"]+columns
            if first_stage_collect_data
              retrieve_fluorescence_data(@experiment.id, first_stage_collect_data.id, @experiment.calibration_id).each do |fluorescence_data|
                csv << [fluorescence_data.calibrated_value]+fluorescence_data.attributes.values_at(*columns)
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
      connection = Rserve::Connection.new
      connection.eval("source(\"#{Rails.configuration.dynamic_file_path}/#{@experiment.experiment_definition.guid}/analyze.R\")")
      response = connection.eval("analyze('#{config[Rails.env]["database"]}', '#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', #{@experiment.id})").to_ruby
      connection.close
      json = JSON.parse(response)
      render :text=>json
    else
      render :json=>{:errors=>"experiment not found"}, :status => :not_found
    end
  end
  
  protected
  
  def get_experiment
    @experiment = Experiment.find_by_id(params[:id]) if @experiment.nil?
  end
  
  def retrieve_fluorescence_data(experiment_id, stage_id, calibration_id)
    fluorescence_data = []
    config   = Rails.configuration.database_configuration
    connection = Rserve::Connection.new
    start_time = Time.now
    results = connection.eval("get_data_calib('#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment_id}, #{stage_id}, #{calibration_id})")
    connection.close
    logger.info("R code time #{Time.now-start_time}")
    start_time = Time.now
    results = results.to_ruby
    if !results.blank?
      (1...results.length).each do |well_num|
        (0...results[well_num].length).each do |cycle_num|
          fluorescence_data << FluorescenceDatum.new(:experiment_id=>params[:id], :well_num=>well_num-1, :cycle_num=>cycle_num+1, :calibrated_value=>results[well_num][cycle_num])
        end
      end
    end 
    logger.info("Rails code time #{Time.now-start_time}")
    return fluorescence_data
  end
  
  def retrieve_baseline_data(experiment_id, stage_id, calibration_id)
    fluorescence_data = []
    config   = Rails.configuration.database_configuration
    connection = Rserve::Connection.new
    start_time = Time.now
    results = connection.eval("get_data_baseline('#{config[Rails.env]["username"]}', '#{(config[Rails.env]["password"])? config[Rails.env]["password"] : ""}', '#{(config[Rails.env]["host"])? config[Rails.env]["host"] : "localhost"}', #{(config[Rails.env]["port"])? config[Rails.env]["port"] : 3306}, '#{config[Rails.env]["database"]}', #{experiment_id}, #{stage_id}, #{calibration_id})")
    connection.close
    logger.info("R code time #{Time.now-start_time}")
    start_time = Time.now
    results = results.to_ruby
    if !results[0].blank?
      results[0].each_with_index do |e, cycle_num, well_num|
        fluorescence_data << FluorescenceDatum.new(:experiment_id=>params[:id], :well_num=>well_num, :cycle_num=>cycle_num+1, :calibrated_value=>e)
      end
    end 
    logger.info("Rails code time #{Time.now-start_time}")
    return fluorescence_data
  end
  
end
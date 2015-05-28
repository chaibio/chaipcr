require 'zip'

class ExperimentsController < ApplicationController
  include ParamsHelper
  respond_to :json

  resource_description { 
    formats ['json']
  }
  
  def_param_group :experiment do
    param :experiment, Hash, :desc => "Experiment Info", :required => true do
      param :name, String, :desc => "Name of the experiment", :required => true
      param :qpcr, :bool, :desc => "Define whether it is an pcr or qpcr experiment"
    end
  end
  
  api :GET, "/experiments", "List all the experiments"
  example "[{'experiment':{'id':1,'name':'test1','qpcr':true,'started_at':null,'completed_at':null,'completed_status':null}},{'experiment':{'id':2,'name':'test2','qpcr':true,'started_at':null,'completed_at':null,'completed_status':null}}]"
  def index
    @experiments = Experiment.all
    respond_to do |format|
      format.json { render "index", :status => :ok }
    end
  end
  
  api :POST, "/experiments", "Create an experiment"
  param_group :experiment
  description "when experiment is created, default protocol will be created"
  example "{'experiment':{'id':1,'name':'test','qpcr':true,'started_at':null,'completed_at':null,'completed_status':null,'protocol':{'id':1,'lid_temperature':'110.0','stages':[{'stage':{'id':1,'stage_type':'holding','name':'Holding Stage','num_cycles':1,'steps':[{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180,'ramp':{'id':1,'rate':'100.0','max':true}}}]}},{'stage':{'id':2,'stage_type':'cycling','name':'Cycling Stage','num_cycles':40,'steps':[{'step':{'id':2,'name':'Step 2','temperature':'95.0','hold_time':30,'ramp':{'id':2,'rate':'100.0','max':true}}},{'step':{'id':3,'name':'Step 2','temperature':'60.0','hold_time':30,'ramp':{'id':3,'rate':'100.0','max':true}}}]}},{'stage':{'id':3,'stage_type':'holding','name':'Holding Stage','num_cycles':1,'steps':[{'step':{'id':4,'name':'Step 1','temperature':'4.0','hold_time':0,'ramp':{'id':4,'rate':'100.0','max':true}}}]}}]}}}"
  def create
    @experiment = Experiment.new(experiment_params)
    ret = @experiment.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :PUT, "/experiments/:id", "Update an experiment"
  param_group :experiment
  example "{'experiment':{'id':1,'name':'test','qpcr':true,'started_at':null,'completed_at':null,'completed_status':null}}"
  def update
    @experiment = Experiment.find_by_id(params[:id])
    ret = @experiment.update_attributes(experiment_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :POST, "/experiments/:id/copy", "Copy an experiment"
  see "experiments#create", "json response"
  def copy
    old_experiment = Experiment.find_by_id(params[:id])
    @experiment = old_experiment.copy(params[:experiment])
    ret = @experiment.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :GET, "/experiments/:id", "Show an experiment"
  see "experiments#create", "json response"
  def show
    @experiment = Experiment.find_by_id(params[:id]) 
    respond_to do |format|
      format.json { render "fullshow", :status => (@experiment)? :ok :  :unprocessable_entity}
    end
  end
  
  api :GET, "/experiments/:id/status", "Show an experiment running status"
  def status
  end
  
  api :POST, "/experiments/:id/start", "Start an experiment"
  def start
    @experiment = Experiment.find_by_id(params[:id])
    respond_to do |format|
      format.json { render "status", :status => (@experiment)? :ok :  :unprocessable_entity}
    end
  end
  
  api :POST, "/experiments/:id/stop", "Stop an experiment"
  def stop
  end
  
  api :DELETE, "/experiments/:id", "Destroy an experiment"
  def destroy
    @experiment = Experiment.find_by_id(params[:id])
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
    @experiment = Experiment.find_by_id(params[:id]) 
    @temperatures =  @experiment.temperature_logs.with_range(params[:starttime], params[:endtime], params[:resolution])
    respond_to do |format|
      format.json { render "temperature_data", :status => :ok}
    end
  end

  api :GET, "/experiments/:id/fluorescence_data", "Retrieve fluorescence data"
  example "{'fluorescence_datum':{'fluorescence_value':75,'well_num':1,'cycle_num':1}, 'fluorescence_datum':{'fluorescence_value':50,'well_num':2,'cycle_num':1}}"
  def fluorescence_data
    @experiment = Experiment.find_by_id(params[:id]) 
    @fluorescence_data = @experiment.fluorescence_data.select("cycle_num, well_num, AVG(fluorescence_value) as fluorescence_value").group("cycle_num, well_num").order("cycle_num, well_num")
    respond_to do |format|
      format.json { render "fluorescence_data", :status => :ok}
    end
  end
  
  api :GET, "/experiments/:id/export.zip", "zip temperature, fluorescence and meltcurv csv files"
  def export
    experiment = Experiment.find_by_id(params[:id])
    respond_to do |format|
      format.zip {
        buffer = Zip::OutputStream.write_buffer do |out|
          out.put_next_entry("qpcr_experiment_#{(experiment)? experiment.name : "null"}/temperature_log.csv")
          out.write TemperatureLog.as_csv(params[:id])
          out.put_next_entry("qpcr_experiment_#{(experiment)? experiment.name : "null"}/fluorescence.csv")
          out.write FluorescenceDatum.as_csv(params[:id])
          out.put_next_entry("qpcr_experiment_#{(experiment)? experiment.name : "null"}/melt_curve.csv")
          out.write MeltCurveDatum.as_csv(params[:id])
        end
        buffer.rewind
        send_data buffer.sysread
      }
    end
  end
    
end
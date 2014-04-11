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
  
  api :POST, "/experiment/:id/copy", "Copy an experiment"
  see "experiments#create", "json response"
  def copy
    old_experiment = Experiment.find_by_id(params[:id])
    @experiment = old_experiment.copy(params[:experiment])
    ret = @experiment.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :GET, "/experiment/:id", "Show an experiment"
  see "experiments#create", "json response"
  def show
    @experiment = Experiment.find_by_id(params[:id]) 
    respond_to do |format|
      format.json { render "fullshow", :status => (@experiment)? :ok :  :unprocessable_entity}
    end
  end
  
  api :GET, "/experiment/:id/status", "Show an experiment running status"
  def status
  end
  
  api :POST, "/experiment/:id/start", "Start an experiment"
  def start
    @experiment = Experiment.find_by_id(params[:id])
    respond_to do |format|
      format.json { render "status", :status => (@experiment)? :ok :  :unprocessable_entity}
    end
  end
  
  api :POST, "/experiment/:id/stop", "Stop an experiment"
  def stop
  end
  
  api :DELETE, "/experiment/:id", "Destroy an experiment"
  def destroy
    @experiment = Experiment.find_by_id(params[:id])
    ret = @experiment.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
end
class StagesController < ApplicationController
  include ParamsHelper
  respond_to :json  
 
  resource_description { 
    formats ['json']
  }
  
  def_param_group :stage do
    param :stage, Hash, :desc => "Stage Info", :required => true do
      param :stage_type, ["holding", "cycling", "meltcurve"], :desc => "Stage type", :required => true
      param :name, String, :desc => "Name of the stage, if not provided, default name is '<stage type> Stage'", :required => false
      param :num_cycles, Integer, :desc => "Number of cycles in a stage, must be >= 1, default to 1", :required=>false
    end
  end
   
  api :POST, "/protocols/:protocol_id/stages", "Create a stage"
  param_group :stage
  param :prev_id, Integer, :desc => "prev stage id or null if it is the first node", :required=>true
  example "{'stage':{'id':1,'stage_type':'holding','name':'Holding Stage','num_cycles':1,'steps':[{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180,'ramp':{'id':1,'rate':'100.0','max':true}}}"
  def create
    @stage = Stage.new(stage_params)
    @stage.protocol_id = params[:protocol_id]
    @stage.prev_id = params[:prev_id]
    @step = Step.new(step_params)
    @stage.steps << @step
    ret = @stage.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :PUT, "/stages/:id", "Update a stage"
  param_group :stage
  example "{'stage':{'id':1,'stage_type':'holding','name':'Holding Stage','num_cycles':1}}"
  def update
    @stage = Stage.find(params[:id])
    ret  = @stage.update_attributes(stage_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :POST, "/stages/:id/move", "Move a stage"
  param :prev_id, Integer, :desc => "prev stage id or null if it is the first node", :required=>true
  def move
    @stage = Stage.find(params[:id])
    @stage.prev_id = params[:prev_id]
    ret = @stage.save
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :DELETE, "/stages/:id", "Destroy a stage"
  def destroy
    @stage = Stage.find(params[:id])
    ret = @stage.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
end
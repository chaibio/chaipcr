class StepsController < ApplicationController
  include ParamsHelper
  respond_to :json  
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :step do
    param :step, Hash, :desc => "Step Info", :required => true do
      param :temperature, BigDecimal, :desc => "Temperature of the step, in degree C, with precision to one decimal point", :required => false
      param :hold_time, Integer, :desc => "Hold time of the step, in seconds, 0 means infinite", :required=>false
      param :name, String, :desc => "Name of the step, if not provided, default name is 'Step <order_number>'", :required => false
    end
  end
  
  api :POST, "/stages/:stage_id/steps", "Create a step"
  param_group :step
  param :prev_id, Integer, :desc => "prev step id or null if it is the first node", :required=>true
  description <<-EOS
    if step is created with no params, it will be the same as previous step;
    when step is created, default ramp with max rate (100) will be created
  EOS
  example "{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180,'ramp':{'id':1,'rate':'100.0','max':true}}}"
  def create
    @step = Step.new(step_params)
    @step.stage_id = params[:stage_id]
    @step.prev_id = params[:prev_id]
    ret = @step.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :PUT, "/steps/:id", "Update a step"
  param_group :step
  example "{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180}}"
  def update
    @step = Step.find(params[:id])
    ret  = @step.update_attributes(step_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :POST, "/steps/:id/move", "Move a step"
  param :prev_id, Integer, :desc => "prev step id or null if it is the first node", :required=>true
  def move
    @step = Step.find(params[:id])
    @step.stage_id = params[:stage_id]
    @step.prev_id = params[:prev_id]
    ret = @step.save
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :DELETE, "/steps/:id", "Destroy a step"
  description "if last step in the asoociated stage is destroyed, the stage will be destroyed too if it is not the last stage in the protocol."
  example "{'step':{'destroyed_stage_id':1}}"
  def destroy
    @step = Step.find(params[:id])
    ret = @step.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
end
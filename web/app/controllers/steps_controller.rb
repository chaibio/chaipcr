class StepsController < ApplicationController
  include ParamsHelper
  before_filter :experiment_definition_editable_check
  
  respond_to :json
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :step do
    param :step, Hash, :desc => "Step Info", :required => true do
      param :temperature, Float, :desc => "Temperature of the step, in degree C, with precision to one decimal point", :required => false
      param :hold_time, Integer, :desc => "Hold time of the step, in seconds, 0 means infinite", :required=>false
      param :name, String, :desc => "Name of the step, if not provided, default name is 'Step <order_number>'", :required => false
      param :pause, :bool, :desc => "machine will be paused when the step is reached", :required=>false
      param :collect_data, :bool, :desc => "Collect data, if not provided, default is false", :required => false
      param :delta_temperature, Float, :desc => "Delta temperature, in degree C, with precision to two decimal points", :required => false
      param :delta_duration_s, Integer, :desc => "Delta duration, in second", :required => false
    end
  end
  
  api :POST, "/stages/:stage_id/steps", "Create a step"
  param_group :step
  param :prev_id, Integer, :desc => "prev step id or null if it is the first node", :required=>false
  description <<-EOS
    if step is created with no params, it will be the same as previous step;
    when step is created, default ramp with max rate (100) will be created
  EOS
  example "{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180,'pause':false,ramp':{'id':1,'rate':'100.0','max':true}}}"
  def create
    @step.prev_id = params[:prev_id]
    ret = @step.save
    respond_to do |format|
      format.json { render "fullshow", :status => (ret)? :ok :  :unprocessable_entity}
    end
  end
  
  api :PUT, "/steps/:id", "Update a step"
  param_group :step
  example "{'step':{'id':1,'name':'Step 1','temperature':'95.0','hold_time':180,'pause':false}}"
  def update
    ret  = @step.update_attributes(step_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :POST, "/steps/:id/move", "Move a step"
  param :prev_id, Integer, :desc => "prev step id or null if it is the first node", :required=>true
  param :stage_id, Integer, :desc => "stage id or null if it is the same stage", :required=>false
  def move
    if params[:stage_id] && @step.stage_id != params[:stage_id]
      new_stage = Stage.find_by_id(params[:stage_id])
      if new_stage == nil || @step.stage.protocol_id != new_stage.protocol_id
        render json: {errors: "invalid stage id"}, status: :unprocessable_entity
        return
      end
      @step.stage = new_stage
      @step.order_number = 0
    end
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
    ret = @step.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  protected
  
  def get_experiment
    if params[:action] == "create"
      @step = Step.new((!params[:step].blank?)? step_params : {})
      @step.stage_id = params[:stage_id]
    else
      @step = Step.find_by_id(params[:id])
    end
    @experiment = Experiment.where("experiment_definition_id=?", @step.stage.protocol.experiment_definition_id).first if !@step.nil?
  end
  
end
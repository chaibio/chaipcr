class StepsController < ApplicationController
  include ParamsHelper
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :step do
    param :step, Hash, :desc => "Step Info", :required => true do
      param :temperature, BigDecimal, :desc => "Temperature of the step, in degree C, with precision to one decimal point", :required => true
      param :hold_time, Integer, :desc => "Hold time of the step, in seconds, 0 means infinite", :required=>true
      param :name, String, :desc => "Name of the step, if not provided, default name is 'Step <order_number>'", :required => false
    end
  end
  
  api :POST, "/stages/:stage_id/steps", "Create a step"
  param_group :step
  param :next_id, Integer, :desc => "next step id or null if it is the last node", :required=>true
  description "when step is created, default ramp with max rate (100) will be created"
  def create
    @step = Step.new(step_params)
    @step.stage_id = params[:stage_id]
    @step.next_id = params[:next_id]
    if @step.save
      respond_to do |format|
        format.json { render :json => @step,:status => :ok }
      end
    else
      respond_to do |format|
        format.json { render :json => @step.errors,:status => :unprocessable_entity }
      end
    end
  end
  
  api :PUT, "/steps/:id", "Update a step"
  param_group :step
  def update
    @step = Step.find(params[:id])
    ret  = @step.update_attributes(step_params)
    respond_to do |format|
      format.json { render :json => @step,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :POST, "/steps/:id/move", "Move a step"
  param :next_id, Integer, :desc => "next step id or null if it is the last node", :required=>true
  def move
    @step = Step.find(params[:id])
    @step.stage_id = params[:stage_id]
    @step.next_id = params[:next_id]
    ret = @step.save
    respond_to do |format|
      format.json { render :json => @step,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :DELETE, "/steps/:id", "Destroy a step"
  def destroy
    @step = Step.find(params[:id])
    if @step.destroy
      respond_to do |format|
        format.json { render :json => @step,:status => (ret)? :ok : :unprocessable_entity}
      end
    else
      respond_to do |format|
        format.json { render :json => @step.errors, :status => :unprocessable_entity}
      end
    end
  end
end
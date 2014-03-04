class StagesController < ApplicationController
  include ParamsHelper

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
  param :next_id, Integer, :desc => "next stage id or null if it is the last node", :required=>true
  def create
    @stage = Stage.new(stage_params)
    @stage.protocol_id = params[:protocol_id]
    @stage.next_id = params[:next_id]
    @step = Step.new(step_params)
    @stage.steps << @step
    if @stage.save
      respond_to do |format|
        format.json { render :json => {:cycle => @stage, :step=>@step}, :status => :ok }
      end
    else
      respond_to do |format|
        format.json { render :json => @stage.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  api :PUT, "/stages/:id", "Update a stage"
  param_group :stage
  def update
    @stage = Stage.find(params[:id])
    ret  = @stage.update_attributes(stage_params)
    respond_to do |format|
      format.json { render :json => @stage, :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :POST, "/stages/:id/move", "Move a stage"
  param :next_id, Integer, :desc => "next stage id or null if it is the last node", :required=>true
  def move
    @stage = Stage.find(params[:id])
    @stage.next_id = params[:next_id]
    ret = @stage.save
    respond_to do |format|
      format.json { render :json => @stage,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :DELETE, "/stages/:id", "Destroy a stage"
  def destroy
    @stage = Stage.find(params[:id])
    if @stage.destroy
      respond_to do |format|
        format.json { render :json => @stage, :status => (ret)? :ok : :unprocessable_entity}
      end
    else
      respond_to do |format|
        format.json { render :json => @stage.errors, :status => :unprocessable_entity}
      end
    end
  end
  
end
class StagesController < ApplicationController
  include ParamsHelper
  
  def create
    @stage = Stage.new(stage_params)
    @stage.protocol_id = params[:protocol_id]
    @stage.next_id = params[:next_node]
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
  
  def update
    @stage = Stage.find(params[:id])
    ret  = @stage.update_attributes(stage_params)
    respond_to do |format|
      format.json { render :json => @stage, :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def move
    @stage = Stage.find(params[:id])
    @stage.next_id = params[:next_node]
    ret = @stage.save
    respond_to do |format|
      format.json { render :json => @stage,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
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
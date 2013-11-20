class StepsController < ApplicationController
  include ParamsHelper
  
  def create
    @step = Step.new(step_params)
    @step.parent_id = params[:cycle_id]
    @step.next_component_id = params[:next_component]
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
  
  def update
    @step = Step.find(params[:id])
    ret  = @step.update_attributes(step_params)
    respond_to do |format|
      format.json { render :json => @step,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def move
    @step = Step.find(params[:id])
    @step.parent_id = params[:parent_id]
    @step.next_component_id = params[:next_component]
    ret = @step.save
    respond_to do |format|
      format.json { render :json => @step,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def destroy
    @step = Step.find(params[:id])
    ret = @step.destroy
    respond_to do |format|
       format.json { render :json => @step,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
end
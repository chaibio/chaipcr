class CyclesController < ApplicationController
  include ParamsHelper
  
  def create
    @cycle = Cycle.new(cycle_params)
    @cycle.protocol_id = params[:protocol_id]
    @cycle.next_component_id = params[:next_component]
    @step = Step.new(step_params)
    @cycle.children << @step
    if @cycle.save
      respond_to do |format|
        format.json { render :json => {:cycle => @cycle, :step=>@step}, :status => :ok }
      end
    else
      respond_to do |format|
        format.json { render :json => @cycle.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @cycle = Cycle.find(params[:id])
    ret  = @cycle.update_attributes(cycle_params)
    respond_to do |format|
      format.json { render :json => @cycle,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def move
    @cycle = Cycle.find(params[:id])
    @cycle.next_component_id = params[:next_component]
    ret = @cycle.save
    respond_to do |format|
      format.json { render :json => @cycle,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def destroy
    @cycle = Cycle.find(params[:id])
    ret = @cycle.destroy
    respond_to do |format|
       format.json { render :json => @cycle,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
end
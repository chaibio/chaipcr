class ProtocolsController < ApplicationController
  include ParamsHelper
  
  before_filter :get_experiment

  def show
    @protocol = Protocol.find(params[:id])
  end
  
  private
  
  def get_experiment
    if !params[:experiment_id].blank?
      @experiment = Experiment.find(params[:experiment_id])
    end
  end
end
class RampsController < ApplicationController
  include ParamsHelper
  before_filter :ensure_authenticated_user
  before_filter :experiment_definition_editable_check
    
  respond_to :json
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :ramp do
    param :ramp, Hash, :desc => "Ramp Info", :required => true do
      param :rate, Float, :desc => "Rate of the ramp, in degrees C/s, set to 100 for max, precision to 8 decimal point", :required => true
      param :collect_data, :bool, :desc => "Collect data, if not provided, default is false", :required => false
    end
  end
  
  api :PUT, "/ramps/:id", "Update a ramp"
  param_group :ramp
  example "{'ramp':{'id':1,'rate':'100.0','max':true}}"
  def update
    ret  = @ramp.update_attributes(ramp_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  protected
  
  def get_experiment
    @ramp = Ramp.find_by_id(params[:id])
    @experiment = Experiment.where("experiment_definition_id=?", @ramp.step.stage.protocol.experiment_definition_id).first if !@ramp.nil?
  end
  
end
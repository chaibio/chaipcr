class RampsController < ApplicationController
  include ParamsHelper
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
    @ramp = Ramp.find_by_id(params[:id])
    ret  = @ramp.update_attributes(ramp_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
end
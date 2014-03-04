class RampsController < ApplicationController
  include ParamsHelper
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :ramp do
    param :ramp, Hash, :desc => "Ramp Info", :required => true do
      param :rate, BigDecimal, :desc => "Rate of the ramp, in degrees C/s, set to 100 for max, precision to 8 decimal point", :required => true
    end
  end
  
  api :PUT, "/ramps/:id", "Update a ramp"
  param_group :ramp
  def update
    @ramp = Ramp.find(params[:id])
    ret  = @ramp.update_attributes(ramp_params)
    respond_to do |format|
      format.json { render :json => @ramp,:status => (ret)? :ok : :unprocessable_entity}
    end
  end
end
class ProtocolsController < ApplicationController
  include ParamsHelper
  respond_to :json
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :protocol do
    param :protocol, Hash, :desc => "Protocol Info", :required => true do
      param :lid_temperature, BigDecimal, :desc => "lid temperature, in degree C, default is 110, with precision to one decimal point", :required => true
    end
  end
  
  api :PUT, "/protocols/:id", "Update a protocol"
  param_group :protocol
  def update
    @protocol = Protocol.find(params[:id])
    ret  = @protocol.update_attributes(protocol_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
end
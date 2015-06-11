class ProtocolsController < ApplicationController
  include ParamsHelper
  before_filter :experiment_definition_editable_check
    
  respond_to :json
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :protocol do
    param :protocol, Hash, :desc => "Protocol Info", :required => true do
      param :lid_temperature, Float, :desc => "lid temperature, in degree C, default is 110, with precision to one decimal point", :required => true
    end
  end
  
  api :PUT, "/protocols/:id", "Update a protocol"
  param_group :protocol
  def update
    ret  = @protocol.update_attributes(protocol_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  protected
  
  def get_experiment
    @protocol = Protocol.find_by_id(params[:id])
    @experiment = Experiment.where("experiment_definition_id=?", @protocol.experiment_definition_id).first if !@protocol.nil?
  end
  
end
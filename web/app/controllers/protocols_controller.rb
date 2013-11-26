class ProtocolsController < ApplicationController
  include ParamsHelper
  
  def index
    show
  end
  
  def new
    @protocol = Protocol.new
  end
  
  def create
    @protocol = Protocol.create(protocol_params)
    redirect_to edit_protocol_path(@protocol)
  end
  
  def edit
    @protocol = Protocol.find(params[:id])
  end
  
  def show
    @protocols = Protocol.all
    @protocol = (params[:id])? Protocol.find(params[:id]) : @protocols.first
    if @protocol == nil
      flash[:notice] = "You don't have any protocols defined.  Please create your first protocol here."
      redirect_to new_protocol_path
      return
    end
    render "protocols/show"
  end
  
end
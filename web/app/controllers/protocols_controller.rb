class ProtocolsController < ApplicationController
  def create
    
  end
  
  def edit
    show
  end
  
  def show
    @protocols = Protocol.all
    @protocol = (params[:id])? Protocol.find(params[:id]) : @protocols.first
    @editable  = (params[:action] == "edit")? true : false
    render "protocols/show"
  end
  
end
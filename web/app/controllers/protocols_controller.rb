class ProtocolsController < ApplicationController
  include ParamsHelper
  
  before_filter :get_run
  
  def index
    show
  end
  
  def new
    @protocol = Protocol.new
  end
  
  def create
    @protocol = Protocol.create(protocol_params)
    redirect_to (@run)? edit_run_protocol_path(@run, @protocol) : edit_protocol_path(@protocol)
  end
  
  def edit
    @protocol = Protocol.find(params[:id])
  end
  
  def show
    @protocols = Protocol.all
    @protocol = (params[:id])? Protocol.find(params[:id]) : @protocols.first
    if @protocol == nil
      flash[:notice] = "You don't have any protocols defined.  Please create your first protocol here."
      redirect_to (@run)? new_run_protocol_path(@run) : new_protocol_path
      return
    end
    render "protocols/show"
  end
  
  private
  
  def get_run
    if !params[:run_id].blank?
      @run = Run.find(params[:run_id])
    end
  end
end
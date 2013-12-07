class RunController < ApplicationController
  def index
    @run = Run.unfinished.first
    if !@run
      redirect_to new_run_path
      return
    else
      flash.now[:notice] = "You have unfinished run last modified at #{@run.updated_at}.&nbsp;&nbsp;Do you want to continue that run?"
    end
  end
  
  def new
    @run = Run.new
  end
  
  def create
    @run = Run.create(:qpcr => params[:run][:qpcr])
    redirect_to run_protocols_path(@run)
  end
  
  def update
    @run = Run.find(params[:id])
    if params[:run][:protocol_id]
      @run.protocol_id = params[:run][:protocol_id]
    end
    @run.save
    redirect_to run_path(@run)
  end
  
  def show
    @run = Run.find(params[:id])
  end
  
  def start
    @run = Run.find(params[:id])
    redirect_to status_run_path(@run)
  end
  
  def stop
  end
  
  def status
  end
  
end
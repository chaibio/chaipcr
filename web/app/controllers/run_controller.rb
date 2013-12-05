class RunController < ApplicationController
  def new
    @run = Run.new
  end
  
  def create
    @run = Run.create(:qpcr => params[:run][:qpcr])
    redirect_to run_protocols_path(@run)
  end
end
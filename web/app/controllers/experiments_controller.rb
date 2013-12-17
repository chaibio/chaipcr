class ExperimentsController < ApplicationController
  include ParamsHelper
  
  def index
    show
  end
  
  def new
    @experiment = Experiment.new
  end
  
  def create
    @experiment = Experiment.create(experiment_params)
    redirect_to experiment_path(@experiment)
  end
  
  def update
    @experiment = Experiment.find(params[:id])
    if @experiment.update_attributes(experiment_params)
      redirect_to protocol_experiment_path(@experiment)
      return
    else
      flash.now[:error] = "Please correct the following errors"
      render "experiments/show"
    end
  end
  
  def show
    @experiments = Experiment.all
    @experiment = (params[:id])? Experiment.find(params[:id]) : @experiments.first
    if @experiment == nil
      flash[:notice] = "You don't have any experiment defined.  Please create your first experiment here."
      redirect_to new_experiment_path
      return
    end
    render "experiments/show"
  end
  
  def protocol
    @experiment = Experiment.find(params[:id])
  end
  
  def platessetup
    @experiment = Experiment.find(params[:id])
  end
  
  def status
  end
  
  def start
    @experiment = Experiment.find(params[:id])
    redirect_to status_experiment_path(@experiment)
  end
  
  def stop
  end
end
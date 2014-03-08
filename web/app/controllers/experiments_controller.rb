class ExperimentsController < ApplicationController
  include ParamsHelper
  
  def_param_group :experiment do
    param :experiment, Hash, :desc => "Experiment Info", :required => true do
      param :name, String, :desc => "Name of the experiment", :required => true
      param :qpcr, :bool, :desc => "Define whether it is an pcr or qpcr experiment"
    end
  end
  
  api :GET, "/experiments", "List experiments and show the first one"
  def index
    show
  end
  
  api :GET, "/experiments/new", "New an experiment"
  def new
    @experiment = Experiment.new
  end
  
  api :POST, "/experiments", "Create an experiment"
  param_group :experiment
  description "when experiment is created, default protocol will be created"
  def create
    @experiment = Experiment.create(experiment_params)
    redirect_to experiment_path(@experiment)
  end
  
  api :PUT, "/experiment/:id", "Update an experiment"
  param_group :experiment
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
  
  api :POST, "/experiment/:id/copy", "Copy an experiment"
  def copy
    @experiment = Experiment.find(params[:id])
    if experiment = @experiment.copy!(params[:experiment])
      redirect_to experiment_path(experiment)
    else
      flash[:error] = "Cannot copy the current experiment"
      redirect_to experiment_path(@experiment)
    end
  end
  
  api :GET, "/experiment/:id", "Show an experiment"
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
  
  api :GET, "/experiment/:id/protocol", "Show the protocol of an experiment"
  formats ["html"]
  description "experiment object has one protocol, the protocol has many stages, each stage has many steps, each step has one ramp"
  def protocol
    @experiment = Experiment.find(params[:id])
  end
  
  api :GET, "/experiment/:id/platessetup", "Show the plate setup of an experiment"
  def platessetup
    @experiment = Experiment.find(params[:id])
  end
  
  api :GET, "/experiment/:id/status", "Show an experiment running status"
  def status
  end
  
  api :POST, "/experiment/:id/start", "Start an experiment"
  def start
    @experiment = Experiment.find(params[:id])
    redirect_to status_experiment_path(@experiment)
  end
  
  api :POST, "/experiment/:id/stop", "Stop an experiment"
  def stop
  end
  
  api :DELETE, "/experiment/:id", "Destroy an experiment"
  def destroy
    @experiment = Experiment.find(params[:id])
    @experiment.destroy
    flash[:notice] = "Experiment '#{@experiment.name}' is successfully deleted."
    redirect_to experiments_path
  end
end
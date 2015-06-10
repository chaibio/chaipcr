module ParamsHelper
  
private
  def experiment_params
     params.require(:experiment).permit(:name)
  end
  
  def protocol_params
    params.require(:protocol).permit(*Protocol::ACCESSIBLE_ATTRS)
  end
  
  def stage_params
    params.require(:stage).permit(*Stage::ACCESSIBLE_ATTRS)
  end
  
  def step_params
    params.require(:step).permit(*Step::ACCESSIBLE_ATTRS)
  end
  
  def ramp_params
    params.require(:ramp).permit(*Ramp::ACCESSIBLE_ATTRS)
  end
  
  def settings_params
    params.require(:settings).permit(:time_zone, :debug)
  end
end
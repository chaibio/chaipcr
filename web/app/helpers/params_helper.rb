module ParamsHelper
  
private
  def experiment_params
     params.require(:experiment).permit(:name, :qpcr)
  end
  
  def protocol_params
    params.require(:protocol).permit(:lid_temperature)
  end
  
  def stage_params
    params.require(:stage).permit(:name, :num_cycles, :stage_type)
  end
  
  def step_params
    params.require(:step).permit(:name, :temperature, :hold_time, :collect_data)
  end
  
  def ramp_params
    params.require(:ramp).permit(:rate, :collect_data)
  end
  
  def settings_params
    params.require(:settings).permit(:time_zone, :debug)
  end
end
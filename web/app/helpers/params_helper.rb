module ParamsHelper
  
private
  def experiment_params
     params.require(:experiment).permit(:name, :qpcr)
  end
  
  def cycle_params
    params.require(:cycle).permit(:name, :repeat)
  end
  
  def step_params
    params.require(:step).permit(:name, :temperature, :hold_time)
  end
  
end
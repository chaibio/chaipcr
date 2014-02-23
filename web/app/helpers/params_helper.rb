module ParamsHelper
  
private
  def experiment_params
     params.require(:experiment).permit(:name, :qpcr)
  end
  
  def stage_params
    params.require(:stage).permit(:name, :numcycles, :stage_type)
  end
  
  def step_params
    params.require(:step).permit(:name, :temperature, :hold_time)
  end
  
end
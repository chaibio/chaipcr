module ParamsHelper
  
private
  def cycle_params
    params.require(:cycle).permit(:name, :repeat)
  end
  
  def step_params
    params.require(:step).permit(:name, :temperature, :hold_time)
  end
  
end
class Protocol < ActiveRecord::Base
  belongs_to :experiment_definition
  has_many :stages, -> {order("order_number").includes(:steps, :ramps)}
  
  ACCESSIBLE_ATTRS = [:lid_temperature]
  
  #delete stages after protocol destroy, so that stage.protocol will be nil
  after_destroy do |protocol|
    for stage in protocol.stages
      stage.destroy
    end
  end
  
  def copy
    new_protocol = Protocol.new(:lid_temperature=>lid_temperature)
    stages.each do |stage|
      new_protocol.stages << stage.copy
    end
    new_protocol
  end
  
  def estimate_duration
    stage = stages.first
    duration = 0
    prev_target_temp = 20
    stages.each do |stage|
      for i in 1..stage.num_cycles 
        stage.steps.each do |step|
          temperature = step.temperature
          if stage.auto_delta && i > stage.auto_delta_start_cycle
            temperature += step.delta_temperature*(i-stage.auto_delta_start_cycle)
          end
          ramp_rate = (step.ramp.rate <= 0 || step.ramp.rate > step.ramp.max_rate)? step.ramp.max_rate : step.ramp.rate
          duration += (temperature-prev_target_temp).abs / ramp_rate
          prev_target_temp = temperature
          if !step.pause && !step.infinite_hold?
            hold_time = step.hold_time
            if stage.auto_delta && i > stage.auto_delta_start_cycle
              hold_time += step.delta_duration_s*(i-stage.auto_delta_start_cycle)
            end
            duration += hold_time
          end
        end
      end
    end
    duration.round
  end
end
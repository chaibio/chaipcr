class FluorescenceDatum < ActiveRecord::Base
  belongs_to :experiment
  
  def self.new_data_generated?(experiment_id, stage_id)
    data = joins("LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id 
                  LEFT JOIN amplification_data ON amplification_data.stage_id = steps.stage_id AND amplification_data.experiment_id = fluorescence_data.experiment_id AND 
                  amplification_data.well_num = fluorescence_data.well_num+1 AND amplification_data.cycle_num = fluorescence_data.cycle_num")
           .where(["fluorescence_data.experiment_id=? AND steps.stage_id=?", experiment_id, stage_id])
           .order("fluorescence_data.cycle_num DESC").select("fluorescence_data.*, background_subtracted_value").first
    return data && data.background_subtracted_value == nil 
  end

end
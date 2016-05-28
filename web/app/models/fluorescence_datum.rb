#
# Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
# For more information visit http://www.chaibio.com
#
# Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
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

  def self.data(experiment_id, stage_id)
    data = joins("LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id")
          .where(["fluorescence_data.experiment_id=? AND steps.stage_id=?", experiment_id, stage_id])
          .order("fluorescence_data.channel, fluorescence_data.well_num, fluorescence_data.cycle_num")
    return data
  end
      
end
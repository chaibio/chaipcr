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
  
  scope :for_experiment, lambda {|experiment_id| where(["fluorescence_data.experiment_id=?", experiment_id]).order("fluorescence_data.channel, fluorescence_data.well_num, fluorescence_data.cycle_num")}
  scope :for_stage, lambda {|stage_id| joins("LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id")
                                       .where(["steps.stage_id=?", stage_id])
                                       .order("steps.order_number")}
  
  FAKE_CALIBRATION_SINGLE_CHANNEL_WATER = [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], nil]
  FAKE_CALIBRATION_SINGLE_CHANNEL_SIGNAL = [[100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100], nil]
  FAKE_CALIBRATION_DUAL_CHANNEL_WATER = [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]
  FAKE_CALIBRATION_DUAL_CHANNEL_FAM = [[100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100], [50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50]]
  FAKE_CALIBRATION_DUAL_CHANNEL_HEX = [[50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50], [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100]]
  
  def self.new_data_generated?(experiment_id, stage_id)
    data = self.for_stage(stage_id).for_experiment(experiment_id).joins("LEFT JOIN amplification_data ON amplification_data.stage_id = steps.stage_id AND amplification_data.experiment_id = fluorescence_data.experiment_id AND amplification_data.well_num = fluorescence_data.well_num+1 AND amplification_data.cycle_num = fluorescence_data.cycle_num")
            .reorder("fluorescence_data.cycle_num DESC").select("fluorescence_data.*, background_subtracted_value").first
    return data != nil && data.background_subtracted_value == nil 
  end
  
  def self.last_cycle(experiment_id, stage_id)
    cycle_num = self.for_stage(stage_id).for_experiment(experiment_id).maximum(:cycle_num)
    (cycle_num.nil?)? 0 : cycle_num
  end
  
  def self.fluorescence_for_steps(experiment_id, step_ids)
    fluorescence_values = Array.new(step_ids.length)
    fluorescence_index = -1
    FluorescenceDatum.for_experiment(experiment_id).where(:step_id=>step_ids.compact).order("fluorescence_data.step_id, fluorescence_data.channel, fluorescence_data.well_num").each do |data|
      if fluorescence_index == -1 || data.step_id != step_ids[fluorescence_index]
        fluorescence_index = -1
        step_ids.each_with_index do |step_id, index|
          if step_id == data.step_id
            fluorescence_index = index
            break
          end
        end
      end
      
      if fluorescence_index != -1
        fluorescence_values[fluorescence_index] ||= [nil, nil]
        fluorescence_values[fluorescence_index][data.channel-1] ||= Array.new
        fluorescence_values[fluorescence_index][data.channel-1] << data.fluorescence_value
      end
    end
    
    fluorescence_values
  end
  
  def self.julia_hash(experiment_id, sub_type, sub_id)
    results = {}
    FluorescenceDatum.for_experiment(experiment_id).where("#{sub_type}_id=#{sub_id}").each do |data|
        results[:fluorescence_value] ||= Array.new
        results[:well_num] ||= Array.new
        results[:cycle_num] ||= Array.new
        results[:channel] ||= Array.new
        results[:fluorescence_value] << data.fluorescence_value
        results[:well_num] << data.well_num
        results[:cycle_num] << data.cycle_num
        results[:channel] << data.channel
    end
    results
  end
  
  def well_num
    read_attribute(:well_num)+1
  end
end

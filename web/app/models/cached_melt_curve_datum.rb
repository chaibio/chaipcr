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
class CachedMeltCurveDatum < ActiveRecord::Base
  belongs_to :experiment
  
  attr_accessor :fluorescence_data
  
  ["temperature", "normalized_data", "derivative_data", "tm", "area"].each do |variable|
    define_method("#{variable}") do
      value = instance_variable_get("@#{variable}")
      if value.nil?
        value = read_attribute("#{variable}_text".to_sym)
        value = value.split(",").map {|v| v.to_f}
        instance_variable_set("@#{variable}", value)
      end
      return value
    end
    
    define_method("#{variable}=") do |value|
      instance_variable_set("@#{variable}", value)
      write_attribute("#{variable}_text".to_sym, (value)? value.join(",") : "")
    end  
  end
  
  def self.retrieve(experiment, stage_id, filter_by_targets)
    clause = self.where(:experiment_id=>experiment.id, :stage_id=>stage_id).order(:ramp_id, :channel, :well_num)
    if filter_by_targets
      clause = clause.select("cached_melt_curve_data.*, targets_wells.target_id as target_id, targets.name as target_name").joins("inner join targets_wells on targets_wells.well_num = cached_melt_curve_data.well_num and targets_wells.well_layout_id = #{experiment.well_layout_id} inner join targets on targets.id=targets_wells.target_id and targets.channel = cached_melt_curve_data.channel").where(omit: false)
    else
      clause = clause.select("cached_melt_curve_data.*, channel as target_id,  #{Constants::FAKE_TARGET_NAME}")
    end
    clause
  end

end

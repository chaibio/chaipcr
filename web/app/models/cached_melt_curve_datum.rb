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
  include TargetsHelper
  
  belongs_to :experiment
  
  attr_accessor :fluorescence_data
  
  scope :with_samples, -> { joins("left join samples_wells on samples_wells.well_num = targets_wells.well_num AND samples_wells.well_layout_id = targets_wells.well_layout_id left join samples on samples.id = samples_wells.sample_id").select("samples.name as sample_name") }
  
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
  
  def self.retrieve(experiment, stage_id, fake_targets)
    filtered_by_targets(experiment.well_layout.id, fake_targets).where(:experiment_id=>experiment.id, :stage_id=>stage_id).order_by_target(fake_targets)
  end

  def self.retrieve_all(experiment, stage_id, fake_targets)
    filtered_by_targets(experiment.well_layout.id, fake_targets).unscope(:where).where(:experiment_id=>experiment.id, :stage_id=>stage_id).order_by_target(fake_targets)
  end
end

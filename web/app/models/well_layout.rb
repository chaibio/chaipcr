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
class WellNode #change to Well later
  attr_accessor :samples
  attr_accessor :targets
end

class WellLayout < ActiveRecord::Base
  has_many :samples, dependent: :destroy
  has_many :targets, dependent: :destroy
  
  scope :for_experiment, lambda {|experiment_id| where(:experiment_id=>experiment_id, :parent_type=>Experiment.name)}
  
  def editable?
    parent_type == Experiment.name
  end
  
  def layout
    wellsamples = Sample.joins(:samples_wells).where(["samples_wells.well_layout_id=?", id]).order("well_num").select("samples.*, well_num")
    welltargets = Target.joins(:targets_wells).where(["targets_wells.well_layout_id=?", id]).order("well_num, channel").select("targets.*, well_num, well_type, quantity_m, quantity_b")
    wells = (wellsamples.length > 0 || welltargets.length > 0)? Array.new(16) : []
    index = 0
    while index < wellsamples.length || index < welltargets.length do
      if index < wellsamples.length
        well_index = wellsamples[index].well_num-1
        wells[well_index] = WellNode.new if wells[well_index].nil?
        wells[well_index].samples ||= Array.new
        wells[well_index].samples << wellsamples[index]
      end
      if index < welltargets.length
        welltargets[index].imported = (welltargets[index].well_layout_id == id)? false : true
        well_index = welltargets[index].well_num-1
        wells[well_index] = WellNode.new if wells[well_index].nil?
        wells[well_index].targets ||= Array.new
        wells[well_index].targets << welltargets[index]
      end
      index += 1
    end
    wells
  end
  
  def copy
    new_layout = WellLayout.new(:parent_type=>Experiment.name)
    samples.each do |sample|
      new_layout.samples << sample.copy
    end
    targets.each do |target|
      new_layout.targets << target.copy
    end
    new_layout
  end
  
end

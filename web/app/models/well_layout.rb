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
  
  def as_json_standard_curve
    {
      :well=>(!targets.blank?)? targets.map {|target|
        (target)? {:target=>target.id, :cq=>target.ct.to_f, :quantity=>{:m=>target.quantity_m.to_f, :b=>target.quantity_b}} : {}
        } : nil
    }
  end  
end

class WellLayout < ActiveRecord::Base
  has_many :samples
  has_many :targets
  
  scope :for_experiment, lambda {|experiment_id| where(:experiment_id=>experiment_id, :parent_type=>Experiment.name)}
  
  before_destroy do |layout|
    layout.targets.each do |target|
      target.force_destroy = true
      if !target.destroy
        errors.add(:base, "target #{target.id} destroy fails: #{target.errors.full_messages.join(",")}")
        throw :abort
      end
    end
    layout.samples.each do |sample|
      sample.force_destroy = true
      if !sample.destroy
        errors.add(:base, "sample #{sample.id} destroy fails: #{sample.errors.full_messages.join(",")}")
        throw :abort
      end
    end
  end
  
  def self.experiment_id_for_well_layout_id(layout_id)
    (layout_id)? where(:id=>layout_id).pluck("experiment_id").first : nil
  end
  
  def editable?
    parent_type == Experiment.name
  end
  
  def layout
    wellsamples = Sample.joins(:samples_wells).where(["samples_wells.well_layout_id=?", id]).order("well_num").select("samples.*, well_num")
    welltargets = Target.joins(:targets_wells).where(["targets_wells.well_layout_id=?", id]).order("well_num, channel").select("targets.*, well_num, well_type, quantity_m, quantity_b")
    well_array(wellsamples, welltargets)
  end
  
  def standard_curve
    welltargets = Target.joins(:targets_wells).joins("inner join amplification_curves on amplification_curves.well_num = targets_wells.well_num and amplification_curves.channel = targets.channel")
                  .where(["targets_wells.well_layout_id=? and amplification_curves.experiment_id=? and ct is not NULL and targets_wells.quantity_m is not NULL and targets_wells.quantity_b is not NULL and targets_wells.omit = false", id, experiment_id])
                  .order("well_num, channel").select("targets.id, targets.channel, targets_wells.well_num, ct, quantity_m, quantity_b")  
    well_array([], welltargets)
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
  
  protected
  
  def well_array(wellsamples, welltargets)
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
        if welltargets[index].respond_to?(:well_layout_id) && !welltargets[index].well_layout_id.nil?
          welltargets[index].imported = (welltargets[index].well_layout_id == id)? false : true
        end
        well_index = welltargets[index].well_num-1
        wells[well_index] = WellNode.new if wells[well_index].nil?
        wells[well_index].targets ||= Array.new(2)
        wells[well_index].targets[welltargets[index].channel-1] = welltargets[index]
      end
      index += 1
    end
    wells
  end
end

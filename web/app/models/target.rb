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
class Target < ActiveRecord::Base
  include ProtocolLayoutHelper
    
  belongs_to :well_layout
  has_many :targets_wells, dependent: :destroy
  
  attr_accessor :imported, :force_destroy
  
  validates_presence_of :name, :channel
  validates :channel, :inclusion => {:in=>1..2, :message => "%{value} is not 1 and 2"}
  ACCESSIBLE_ATTRS = [:well_layout_id, :name, :channel]
  
  validate :validate
  
  before_create do |target|
    target.targets_wells.each do |target_well|
      target_well.well_layout_id = target.well_layout_id if target_well.well_layout_id.nil?
    end
  end
  
  def self.unknowns_for_experiment(experiment)
    targets_hash = Hash.new
    targets = self.joins(:targets_wells).joins("inner join amplification_curves on amplification_curves.well_num = targets_wells.well_num and amplification_curves.channel = targets.channel")
                                        .where(["targets_wells.well_type='unknown' and targets_wells.well_layout_id=? and amplification_curves.experiment_id=? and ct is not NULL", experiment.well_layout.id, experiment.id])
                                        .order("targets.id, targets_wells.well_num, targets.channel").select("targets.*, targets_wells.well_num, ct as cq")
    targets.each do |target|
      targets_hash[target.id] = Array.new if targets_hash[target.id].nil?
      targets_hash[target.id] << target
    end
    targets_hash
  end
  
  def belongs_to_experiment?(experiment)
    if well_layout_id == experiment.well_layout.id
      self.imported = false
    elsif well_layout_id == experiment.targets_well_layout_id
      self.imported = true
    end
    !imported.nil?
  end
  
  def copy
    new_target = copy_helper
    targets_wells.each do |target_well|
      new_target_well = target_well.copy_helper
      new_target_well.validate_targets_in_well = false
      new_target.targets_wells << new_target_well
    end
    new_target
  end
  
  def destroy
    if force_destroy != true
      if linked?
        errors.add(:base, "target is linked to well")
        return false
      end
    else
      if linked_externally?
        errors.add(:base, "target is imported to another experiment")
        return false
      end
    end
    super
  end
  
  protected
  
  def validate
    if channel_changed?
      if linked?
        errors.add(:channel, "cannot be changed because it is linked to a well")
      end
    end
  end
  
  def linked?
    targets_wells.exists?
  end
  
  def linked_externally?
    targets_wells.where(["targets_wells.well_layout_id != ?", well_layout_id]).exists?
  end
end

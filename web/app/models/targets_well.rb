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
class TargetsWell < ActiveRecord::Base
  include ProtocolLayoutHelper
  
  belongs_to :well_layout
  belongs_to :target
  
  attr_accessor :validate_targets_in_well
  
  validates_presence_of :well_num
  validates :well_num, :inclusion => {:in=>1..16, :message => "%{value} is not between 1 and 16"}
  validates :well_type, inclusion: { in: ["positive_control", "negative_control", "standard", "unknown", nil],
     message: "'%{value}' is not a valid type" }

  validate :validate
  
  before_update do |target_well|
    if target_well.well_type != "standard"
      target_well.quantity_m = nil
      target_well.quantity_b = nil
    end
  end
  
  def self.find_or_create(target, well_layout_id, well_num)
     target_well = joins(:target).where(["targets_wells.well_layout_id=? and targets_wells.well_num=? and targets.channel=?", well_layout_id, well_num, target.channel]).first
     if target_well
       target_well.target = target
     else
       target_well = self.new(:well_layout_id=>well_layout_id, :target=>target, :well_num=>well_num)
       target_well.validate_targets_in_well = false
     end
     target_well
  end
  
  protected

  def validate
    if !quantity_m.nil? && quantity_m < 0
      errors.add(:quantity, "has to be positive number")
    end
    if target.imported && well_type == "standard"
      errors.add(:well_type, "standard cannot be supported for imported target")
    end
    if new_record? && validate_targets_in_well != false
      if joins(:target).where(["targets_wells.well_layout_id=? and targets_wells.well_num=? and targets.channel=?", well_layout_id, well_num, target.channel]).exists?
        errors.add(:target_id, "#{target.channel} is already occupied in well #{well_num}")
      end
    end
  end
  
end

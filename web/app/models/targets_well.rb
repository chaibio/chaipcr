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
  
  belongs_to :target
  
  validates_presence_of :well_type, :well_num, :target_id
  ACCESSIBLE_ATTRS = [:well_type, :well_num, :concentration]
  
  validates :well_num, :inclusion => {:in=>1..16, :message => "%{value} is not between 1 and 16"}
  validates :well_type, inclusion: { in: ["positive_control", "no_template_control", "standard", "sample"],
     message: "'%{value}' is not a valid type" }

  validate :validate
  
  protected

  def validate
    if well_type == "standard" && concentration.nil?
      errors.add(:concentration, "cannot be blank if well_type is #{well_type}")
    end
      
    if new_record?
      Target.joins("inner join targets_wells ON targets_wells.target_id = targets.id")
            .where("well_layout_id=? AND well_num=?", target.well_layout_id, well_num).each do |existing_target|
        if  existing_target.channel == target.channel
          errors.add(:target_id, "channel #{target.channel} is already occupied in well #{well_num}")
        end 
      end
    end
  end
  
end

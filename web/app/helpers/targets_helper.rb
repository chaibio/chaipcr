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
module TargetsHelper
  FAKE_TARGET_1 = "Ch 1"
  FAKE_TARGET_2 = "Ch 2"
  
  def self.included(base)  
    base.extend(ClassMethods)  
  end  
  
  module ClassMethods
  
    def filtered_by_targets(well_layout_id, fake_targets)
      if fake_targets
        select("#{table_name}.*, channel as target_id,  IF(channel = 1, '#{FAKE_TARGET_1}', '#{FAKE_TARGET_2}') as target_name") 
      else
        select("#{table_name}.*, targets_wells.target_id as target_id, targets.name as target_name").joins("inner join targets_wells on targets_wells.well_num = #{table_name}.well_num#{"+1" if table_name == "fluorescence_data" || table_name == "melt_curve_data"} and targets_wells.well_layout_id = #{well_layout_id} inner join targets on targets.id=targets_wells.target_id and targets.channel = #{table_name}.channel").where(targets_wells: {omit: false})
      end
    end
    
    def order_by_target(fake_targets)
      if table_name == "amplification_data" || table_name == "fluorescence_data"
        order("#{table_name}.well_num, #{(fake_targets)? "#{table_name}.channel" : "targets.name"}, #{table_name}.cycle_num")
      else #melt_curve
        order("#{table_name}.ramp_id, #{table_name}.well_num, #{(fake_targets)? "#{table_name}.channel" : "targets.name"}")
      end
    end
  
  end
end
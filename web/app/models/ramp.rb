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
class Ramp < ActiveRecord::Base
  include ProtocolHelper
  
  include Swagger::Blocks
   
  swagger_schema :Ramp do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :rate do
      key :type, :number
      key :format, :float
      key :description, 'Rate of the ramp, in degrees C/s, between 0 and 5, precision to 8 decimal point'
      key :default, 0
    end
    property :collect_data do
      key :type, :boolean
      key :description, 'Collect data'
      key :default, false
    end
  end
  
  belongs_to :step, foreign_key: "next_step_id"
  
  scope :collect_data, lambda {|stage_id| joins(:step).where(["steps.stage_id=? AND ramps.collect_data=?", stage_id, true]).order("steps.order_number")}
  
  ACCESSIBLE_ATTRS = [:rate, :collect_data]
  
  MAX_RATE   = 5
  
  validate :validate
  
  def copy
    copy_helper
  end
  
  protected

  def validate
    if rate <= 0 || rate > MAX_RATE
      errors.add(:rate, "range is from 0 to #{MAX_RATE}")
    end
  end
  
end
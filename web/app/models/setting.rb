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
class Setting < ActiveRecord::Base
  include Swagger::Blocks

  #to verify the type of the property

  swagger_schema :Settings do
    #key :required, [:id, :name]
    property :time_zone do
      key :type, :string
    end
    property :debug do
      key :type, :boolean
    end
    property :time_zone_offset do
      key :type, :integer
    end
  end


  def self.instance
    self.first
  end

  def self.debug
    instance.debug
  end

  def self.calibration_id
    instance.calibration_id
  end

  def self.software_release_variant
    instance.software_release_variant
  end

  def self.time_valid
    instance.time_valid
  end

  def time_zone_offset
    (time_zone.nil?)? nil : ActiveSupport::TimeZone.new(time_zone).utc_offset
  end

end

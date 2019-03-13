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
class Protocol < ActiveRecord::Base
  include Swagger::Blocks

  swagger_schema :Protocol do
    property :id do
      key :type, :integer
      key :format, :int64
      key :readOnly, true
    end
    property :lid_temperature do
      key :type, :number
      key :format, :float
      key :description, 'Lid temperature, in degree C, default is 110, with precision to one decimal point'
      key :default, 110
    end
    property :estimate_duration do
      key :type, :integer
			key :description, 'Estimated duration in seconds'
      key :format, :int32
      key :readOnly, true
    end
  end
  
	swagger_schema :FullProtocol do
    allOf do
      schema do
        property :stages do
          key :type, :array
          items do
            key :'$ref', :FullStage
          end
        end
      end
      schema do
        key :'$ref', :Protocol
      end
    end
  end
  
  belongs_to :experiment_definition
  has_many :stages, -> {order("order_number").includes(:steps, :ramps)}

  validate :validate

  ACCESSIBLE_ATTRS = [:lid_temperature]

  #delete stages after protocol destroy, so that stage.protocol will be nil
  after_destroy do |protocol|
    for stage in protocol.stages
      stage.destroy
    end
  end

  def copy
    new_protocol = Protocol.new(:lid_temperature=>lid_temperature)
    stages.each do |stage|
      new_protocol.stages << stage.copy
    end
    new_protocol
  end

  def estimate_duration
    stage = stages.first
    duration = 0
    prev_target_temp = 20
    stages.each do |stage|
      for i in 1..stage.num_cycles
        stage.steps.each do |step|
          temperature = step.temperature
          if stage.auto_delta && i > stage.auto_delta_start_cycle
            temperature += step.delta_temperature*(i-stage.auto_delta_start_cycle)
          end
          ramp_rate = (step.ramp.rate <= 0 || step.ramp.rate > Ramp::MAX_RATE)? Ramp::MAX_RATE : step.ramp.rate
          duration += (temperature-prev_target_temp).abs / ramp_rate
          prev_target_temp = temperature
          if !step.pause && !step.infinite_hold?
            hold_time = step.hold_time
            if stage.auto_delta && i > stage.auto_delta_start_cycle
              hold_time += step.delta_duration_s*(i-stage.auto_delta_start_cycle)
            end
            duration += hold_time
          end
        end
      end
    end
    duration.round
  end
  
  protected

  def validate
    if !lid_temperature.nil?
      if DeviceConfiguration.valid?
        temperature_min = DeviceConfiguration.thermal["lid"]["min_temp_c"]
        temperature_max = DeviceConfiguration.thermal["lid"]["max_temp_c"]
      end
      temperature_min = 0 if temperature_min.nil?
      temperature_max = 120 if temperature_max.nil?
      if (lid_temperature < temperature_min || lid_temperature > temperature_max)
        errors.add(:lid_temperature, "between #{temperature_min} to #{temperature_max}")
      end
    end
  end
end

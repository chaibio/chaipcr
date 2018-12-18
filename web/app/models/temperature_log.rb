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
require "csv"

class TemperatureLog < ActiveRecord::Base
  belongs_to :experiment
	include Swagger::Blocks

	swagger_schema :TemperatureData do
		property :elapsed_time do
			key :type, :integer
			key :format, :int64
			key :description, 'in milliseconds'
		end
		property :lid_temp do
      key :type, :number
      key :format, :float
      key :description, 'temperature, in degree C, with precision to two decimal points'
		end
		property :heat_block_zone_1_temp do
      key :type, :number
      key :format, :float
      key :description, 'temperature, in degree C, with precision to two decimal points'
		end
		property :heat_block_zone_2_temp do
      key :type, :number
      key :format, :float
      key :description, 'temperature, in degree C, with precision to two decimal points'
		end
	end

  def self.as_csv(experiment_id)
    temperatures = TemperatureLog.order("temperature_logs.elapsed_time").where("temperature_logs.experiment_id=?", experiment_id)
    columns = ["temperature_logs.experiment_id", "temperature_logs.elapsed_time"] + column_names-["experiment_id", "elapsed_time"]
    if Setting.debug
      temperatures = temperatures.joins("LEFT JOIN temperature_debug_logs ON temperature_debug_logs.experiment_id = temperature_logs.experiment_id AND temperature_debug_logs.elapsed_time = temperature_logs.elapsed_time")
      columns = columns + TemperatureDebugLog.column_names-["experiment_id", "elapsed_time"]
    end
    CSV.generate do |csv|
      csv << columns
      temperatures.select(columns).each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end
  
  def self.julia_hash(experiment_id)
    results = {}
    temperatures = TemperatureLog.order("temperature_logs.elapsed_time").where("temperature_logs.experiment_id=?", experiment_id).each do |data|
      results[:lid_temp] ||= Array.new
      results[:heat_block_zone_1_temp] ||= Array.new
      results[:heat_block_zone_2_temp] ||= Array.new
      results[:elapsed_time] ||= Array.new
      results[:cycle_num] ||= Array.new
      results[:lid_temp] << data.lid_temp
      results[:heat_block_zone_1_temp] << data.heat_block_zone_1_temp
      results[:heat_block_zone_2_temp] << data.heat_block_zone_2_temp
      results[:elapsed_time] << data.elapsed_time
      results[:cycle_num] << data.cycle_num
    end
    results
  end

end

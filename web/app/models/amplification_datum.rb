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
class AmplificationDatum < ActiveRecord::Base
  belongs_to :experiment
	include Swagger::Blocks

	swagger_schema :AmplificationData do
		property :partial do
			key :type, :boolean
			key :description, 'Indicates if the returned data is complete or partial'
		end
		property :total_cycles do
			key :type, :integer
			key :description, 'No of cycles for the experiment'
		end
		property :steps do
			key :description, 'Contains the step id and and a 2d array amplification_data - every array object contains the channel, the well number, the cycle number and the background and baseline subtracted values for them.'
			key :type, :array
			items do
				property :step_id do
					key :type, :integer
				end
				property :amplification_data do
					key :type, :array
					items do
						property :channel do
							key :type, :integer
							key :description, '?'
						end
						property :well_num do
							key :type, :integer
							key :description, '?'
						end
						property :cycle_num do
							key :type, :integer
							key :description, '?'
						end
						property :background_subtracted_value do
							key :type, :integer
							key :description, '?'
						end
						property :baseline_subtracted_value do
							key :type, :integer
							key :description, '?'
						end
					end
				end
				property :cq do
					key :type, :array
					items do
						property :channel do
							key :type, :integer
							key :description, '?'
						end
						property :well_num do
							key :type, :integer
							key :description, '?'
						end
						property :cq do
							key :type, :integer
							key :description, '?'
						end
					end
				end
			end
		end
	end

  Constants::KEY_NAMES.each do |variable|
    define_method("#{variable}") do
      (!sub_type.nil? && "#{sub_type}_id" == variable)? sub_id : nil
    end
  end

  attr_accessor :fluorescence_value

  def self.retrieve(experiment_id, stage_id)
    self.where(:experiment_id=>experiment_id, :stage_id=>stage_id).order(:channel, :well_num, :cycle_num)
  end

  def self.maxid(experiment_id, stage_id)
    self.where(:experiment_id=>experiment_id, :stage_id=>stage_id).maximum(:id)
  end

  def attributes
    hash = super
    hash["fluorescence_value"] = self.fluorescence_value
    return hash
  end
end

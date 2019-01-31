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
				key :'$ref', :AmplificationDataSteps
			end
		end
	end

	swagger_schema :AmplificationDataSteps do
		property :step_id do
			key :type, :integer
			key :description, 'Step id'
		end
		property :amplification_data do
			key :description, 'Describe the properties'
			key :type, :array
			items do
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
					property :dr1_pred do
						key :type, :integer
						key :description, '?'
					end
					property :dr2_pred do
						key :type, :integer
						key :description, '?'
					end
				end
			end
		end
		property :cq do
			key :description, 'Describe the properties'
			key :type, :array
			items do
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
=begin
	swagger_schema :AmplificationDataProp do
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

	swagger_schema :AmplificationDataCq do
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
=end
  Constants::KEY_NAMES.each do |variable|
    define_method("#{variable}") do
      (!sub_type.nil? && "#{sub_type}_id" == variable)? sub_id : nil
    end
  end

  attr_accessor :fluorescence_value

  def self.retrieve(experiment, stage_id, filter_by_targets)
    clause = self.where(:experiment_id=>experiment.id, :stage_id=>stage_id).order(:channel, :well_num, :cycle_num)
    if filter_by_targets
      clause = clause.select("amplification_data.*, targets_wells.target_id as target_id, targets.name as target_name").joins("inner join targets_wells on targets_wells.well_num = amplification_data.well_num and targets_wells.well_layout_id = #{experiment.well_layout.id} inner join targets on targets.id=targets_wells.target_id and targets.channel = amplification_data.channel").where("targets_wells.omit=false")
    else
      clause = clause.select("amplification_data.*, channel as target_id, #{Constants::FAKE_TARGET_NAME}")
    end
    clause
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

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
  include TargetsHelper
  include Swagger::Blocks
  
  belongs_to :experiment
	
	swagger_schema :AmplificationData do
		property :partial do
			key :type, :boolean
			key :description, 'Keep polling the data until partial is false'
		end
		property :total_cycles do
			key :type, :integer
			key :description, 'Number of cycles for the experiment'
		end
		property :steps do
			key :description, 'Contains amplification data for each step'
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
			key :description, "Two dimensional array like [['target_id', 'well_num', 'cycle_num', 'background_subtracted_value', 'baseline_subtracted_value', 'dr1_pred', 'dr2_pred' 'fluorescence_value'], [1, 1, 1, 25488, -2003, 34543, 453344, 86], [1, 1, 2, 53984, -409, 56345, 848583, 85]]"
			key :type, :array
			items do
				key :type, :array
				items do
					property :target_id do
						key :type, :integer
						key :description, 'Target ID'
					end
					property :well_num do
						key :type, :integer
						key :description, 'Well number from 1 to 16'
					end
					property :cycle_num do
						key :type, :integer
						key :description, 'Cycle number'
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
					property :fluorescence_value do
						key :type, :integer
						key :description, '?'
					end
				end
			end
		end
		property :summary_data do
			key :description, "Two dimensional array like [['target_id','well_num','replic_group','cq','quantity_m','quantity_b','mean_cq','mean_quantity_m','mean_quantity_b'], [1,1,null,null,null,null,null,null,null], [2,12,1,7.314787,4.0,2,6.9858934999999995,4.0,2], [2,14,1,6.657,4.0,2,6.9858934999999995,4.0,2], [2,3,null,6.2,5.7952962,14,null,null,null]]"
			key :type, :array
			items do
				key :type, :array
				items do
					property :target_id do
						key :type, :integer
						key :description, 'Target ID'
					end
					property :well_num do
						key :type, :integer
						key :description, 'Well number from 1 to 16'
					end
					property :replic_group do
						key :type, :integer
						key :description, '?'
					end
					property :cq do
						key :type, :integer
						key :description, '?'
					end
					property :quantity_m do
						key :type, :float
						key :description, '?'
					end
					property :quantity_b do
						key :type, :integer
						key :description, '?'
					end
					property :mean_cq do
						key :type, :float
						key :description, '?'
					end
					property :mean_quantity_m do
						key :type, :float
						key :description, '?'
					end
					property :mean_quantity_b do
						key :type, :integer
						key :description, '?'
					end
				end
			end
		end
		property :targets do
			key :description, "Two dimensional array like [['id','name','equation'],[1,'target1',null],[2,'target2',{'slope':-0.064624,'offset':7.154049,'efficiency':2979647189313701.5,'r2':0.221279}]]"
			key :type, :array
			items do
				key :type, :array
				items do
					property :target_id do
						key :type, :integer
						key :description, 'Target ID'
					end
					property :name do
						key :type, :integer
						key :description, 'Target name'
            key :default, "Ch 1 or Ch 2"
					end
          property :equation do
            property :slope do
              key :type, :float
            end
            property :offset do
              key :type, :float
            end
            property :efficiency do
              key :type, :float
            end
            property :r2 do
              key :type, :float
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

  def self.retrieve(experiment, stage_id, fake_targets)
    filtered_by_targets(experiment.well_layout.id, fake_targets).where(:experiment_id=>experiment.id, :stage_id=>stage_id).order_by_target(fake_targets)
  end
  
  def self.retrieve_all(experiment, stage_id, fake_targets)
    filtered_by_targets(experiment.well_layout.id, fake_targets).unscope(:where).where(:experiment_id=>experiment.id, :stage_id=>stage_id).order_by_target(fake_targets)
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

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
class Experiment < ActiveRecord::Base
  include Swagger::Blocks

	swagger_schema :Experiments do
		property :experiment do
			property :id do
	      key :type, :integer
	      key :format, :int64
	    end
	    property :name do
				key :description, 'Name of the experiment'
	      key :type, :string
	    end
	    property :type do
				key :description, 'Josh to describe'
	      key :type, :string
				key :enum, ['user', 'diagnostic', 'calibration']
	    end
	    property :time_valid do
	      key :type, :boolean
	    end
	    property :created_at do
				key :description, 'Date at which the experiment was created'
	      key :type, :string
	      key :format, :date
	    end
	    property :started_at do
				key :description, 'Date at which the experiment was started'
	      key :type, :string
	      key :format, :date
	    end
	    property :completed_at do
				key :description, 'Date at which the experiment was completed'
	      key :type, :string
	      key :format, :date
	    end
	    property :completion_status do
				key :description, 'If the experiment was completed successfully or aborted'
	      key :type, :string
	    end
	    property :completion_message do
				key :description, '?'
	      key :type, :string
	    end
		end
	end

  swagger_schema :Experiment do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :type do
      key :type, :string
      key :enum, ['user', 'diagnostic', 'calibration']
    end
    property :time_valid do
      key :type, :boolean
    end
    property :created_at do
      key :type, :string
      key :format, :date
    end
    property :started_at do
      key :type, :string
      key :format, :date
    end
    property :completed_at do
      key :type, :string
      key :format, :date
    end
    property :completion_status do
      key :type, :string
    end
    property :completion_message do
      key :type, :string
    end
    property :protocol do
      key :type, :object
      key :'$ref', :Protocol
    end
    property :errors do
      key :type, :array
      items do
        key :type, :string
      end
    end
  end

  swagger_schema :ExperimentInput do
    key :required, [:name]
    property :name do
      key :type, :string
    end
    property :guid do
      key :type, :string
    end
  end

  validates :name, presence: true
  validate :validate

  belongs_to :experiment_definition
  
  has_one  :well_layout, ->{ where(:parent_type => Experiment.name) }, dependent: :destroy
  has_many :fluorescence_data
  has_many :temperature_logs, -> {order("elapsed_time")} do
    def with_range(starttime, endtime, resolution)
      results = where("elapsed_time >= ?", starttime)
      if !endtime.blank?
        results = results.where("elapsed_time <= ?", endtime)
      end
      outputs = []
      counter = 0
      gap = (resolution.blank?)? 1 : resolution.to_i/1000
      results.each do |row|
        if counter == 0
          outputs << row
        end
        counter += 1
        if counter == gap
          counter = 0
        end
      end
      outputs
    end
  end

#  validates :time_valid, inclusion: {in: [true, false]}

  before_create do |experiment|
    experiment.time_valid = (Setting.time_valid)? 1 : 0
    if experiment.well_layout == nil
      experiment.create_well_layout
    end
  end

  before_destroy do |experiment|
    if experiment.running?
      errors.add(:base, "cannot delete experiment in the middle of running")
      false
    end
  end

  after_destroy do |experiment|
    if experiment_definition.experiment_type ==  ExperimentDefinition::TYPE_USER_DEFINED
      experiment_definition.destroy
    end

    TemperatureLog.delete_all(:experiment_id => experiment.id)
    TemperatureDebugLog.delete_all(:experiment_id => experiment.id)
    FluorescenceDatum.delete_all(:experiment_id => experiment.id)
    FluorescenceDebugDatum.delete_all(:experiment_id => experiment.id)
    MeltCurveDatum.delete_all(:experiment_id => experiment.id)
    AmplificationCurve.delete_all(:experiment_id => experiment.id)
    AmplificationDatum.delete_all(:experiment_id => experiment.id)
    CachedMeltCurveDatum.delete_all(:experiment_id => experiment.id)
    Well.delete_all(:experiment_id => experiment.id)
  end

  def create_well_layout
    if experiment_definition.well_layout != nil
      self.well_layout = experiment_definition.well_layout.copy
    else
      self.well_layout = WellLayout.new(:experiment_id=>id, :parent_type=>Experiment.name)
    end
  end
  
  def protocol
    experiment_definition.protocol
  end

  def editable?
    return started_at.nil? && experiment_definition.editable?
  end

  def ran?
    return !started_at.nil?
  end

  def running?
    return !started_at.nil? && completed_at.nil?
  end

  def diagnostic?
    experiment_definition.experiment_type == ExperimentDefinition::TYPE_DIAGNOSTIC
  end

  def diagnostic_passed?
    diagnostic? && completion_status == "success" && analyze_status == "success"
  end

  def calibration_id
    if experiment_definition.guid == "thermal_consistency"
      return 1
    elsif experiment_definition.guid == "optical_cal" || experiment_definition.guid == "dual_channel_optical_cal_v2" ||
          experiment_definition.guid == "optical_test_dual_channel"
      return self.id
    else
      return read_attribute(:calibration_id)
    end
  end

  def as_json(options={})
      {:id=>id,
       :guid=>experiment_definition.guid,
       :stages=>experiment_definition.protocol.stages.map {|stage|
        { :id=>stage.id,
          :name=>stage.name,
          :stage_type=>stage.stage_type,
          :num_cycles=>stage.num_cycles,
          :steps=>stage.steps.map { |step|
            {:id=>step.id, :name=>step.name, :hold_time=>step.hold_time, :ramp_id=>(step.ramp)? step.ramp.id : nil}
          }
        }
       }
      }
  end
  
  protected
  
  def validate
    if targets_well_layout_id_changed? && !targets_well_layout_id_was.blank?
      if Target.joins("inner join targets_wells on targets_wells.target_id = targets.id").where(["targets.well_layout_id=? and targets_wells.well_layout_id=?", targets_well_layout_id_was, well_layout.id]).exists?
        errors.add(:targets_well_layout_id, "cannot be changed because targets are already linked")
      end
    end
  end
end

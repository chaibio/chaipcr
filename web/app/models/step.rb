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
class Step < ActiveRecord::Base
  include ProtocolLayoutHelper
  include ProtocolOrderHelper

  include Swagger::Blocks

  swagger_schema :Step do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :temperature do
      key :type, :number
      key :format, :float
      key :description, 'Temperature of the step, in degree C, with precision to one decimal point'
    end
    property :hold_time do
      key :type, :integer
      key :description, 'Hold time of the step, in seconds, 0 means infinite'
    end
    property :name do
      key :type, :string
      key :description, 'Name of the step'
      key :default, 'Step <order_number>'
    end
    property :pause do
      key :type, :boolean
      key :description, 'machine will be paused when the step is reached'
      key :default, false
    end
    property :collect_data do
      key :type, :boolean
      key :description, 'Collect data'
      key :default, false
    end
    property :delta_temperature do
      key :type, :number
      key :format, :float
      key :description, 'Delta temperature, in degree C, with precision to two decimal points'
    end
    property :delta_duration_s do
      key :type, :integer
      key :description, 'Delta duration, in second'
    end
    property :ramp do
      key :type, :object
      key :'$ref', :Ramp
    end
  end

	swagger_schema :StepProperties do
		key :required, [:step]
		property :step do
			property :temperature do
				key :type, :number
				key :format, :float
				key :description, 'Temperature of the step, in degree C, with precision to one decimal point'
			end
			property :hold_time do
				key :type, :integer
				key :description, 'Hold time of the step, in seconds, 0 means infinite'
			end
			property :name do
				key :type, :string
				key :description, 'Name of the step'
				key :default, 'Step <order_number>'
			end
			property :pause do
				key :type, :boolean
				key :description, 'machine will be paused when the step is reached'
				key :default, false
			end
			property :collect_data do
				key :type, :boolean
				key :description, 'Collect data'
				key :default, false
			end
			property :delta_temperature do
				key :type, :number
				key :format, :float
				key :description, 'Delta temperature, in degree C, with precision to two decimal points'
			end
			property :delta_duration_s do
				key :type, :integer
				key :description, 'Delta duration, in second'
			end
		end
	end

	swagger_schema :StepInput do
		property :prev_id do
			key :type, :integer
			key :format, :int64
			key :required, true
			key :description, 'prev step id or null if it is the first node'
		end
	end

  belongs_to :stage
  has_one :ramp, foreign_key: "next_step_id", dependent: :destroy

  scope :collect_data, lambda {|stage_id| where(:stage_id=>stage_id, :collect_data=>true).order("steps.order_number")}

  ACCESSIBLE_ATTRS = [:name, :temperature, :hold_time, :collect_data, :pause, :delta_temperature, :delta_duration_s, :excitation_intensity]

  attr_accessor :destroyed_stage_id

  validate :validate

  before_create do |step|
    if step.temperature.nil? || step.hold_time.nil?
      if !prev_id.nil?
        reference_step = Step.find_by_id(prev_id)
      end
      if reference_step.nil?
        reference_step = siblings.first
      end
      step.temperature = (reference_step)? reference_step.temperature : 95 if step.temperature.nil?
      step.hold_time = (reference_step)? reference_step.hold_time : 30 if step.hold_time.nil?
    end

    if step.ramp == nil
      step.ramp = Ramp.new(:rate=>Ramp::MAX_RATE)
    end
  end

  after_save do |step|
    if step.stage_id_changed? && !step.stage_id_was.nil?
      children_count = Step.where("stage_id=?", step.stage_id_was).count
      if children_count == 0
        Stage.find_by_id(step.stage_id_was).destroy
      else
        Step.where("stage_id = ? and order_number > ?", step.stage_id_was, step.order_number_was).order("order_number ASC").update_all("order_number = order_number-1")
      end
    end
  end

  after_destroy do |step|
    if step.siblings && step.siblings.length == 0
      if step.stage.destroy
        step.destroyed_stage_id = step.stage.id
      else
        stage.errors[:base].each {|e| step.errors[:base] << e }
        raise ActiveRecord::Rollback and return false
      end
    end
  end

#  def name
#    name_attr = read_attribute(:name)
#    if name_attr.nil?
#      return "Step #{order_number+1}"
#    else
#      return name_attr
#    end
#  end

  def name=(val)
    val = val.strip if !val.nil?
    val = nil if val.blank?
    write_attribute(:name, val)
  end

  def infinite_hold?
    hold_time == 0
  end

  def copy
    new_step = copy_helper
    new_step.ramp = ramp.copy
    new_step
  end

  def new_sibling?
    new_record? || stage_id_changed?
  end

  def siblings
    if stage.nil?
      nil
    elsif !id.nil?
      stage.steps.where("id != ?", id)
    else
      stage.steps
    end
  end

  def last_step?
    !self.class.where("stage_id = ? and order_number > ?", stage_id, order_number).exists?
  end

  protected

  def validate
    if new_record?
      if !prev_id.nil?
        step = Step.find(prev_id)
        if step && step.infinite_hold?
          errors.add(:base, "Cannot add step after infinite hold step")
        end
      end
    else
      if hold_time_changed? && infinite_hold? #make sure it is the last step
          if !last_step? || !stage.last_stage?
            errors.add(:base, "Cannot update step in the middle to infinite hold")
          end
      end
    end

    if !temperature.nil?
      if DeviceConfiguration.valid?
        temperature_min = DeviceConfiguration.thermal["block"]["min_temp_c"]
        temperature_max = DeviceConfiguration.thermal["block"]["max_temp_c"]
      end
      temperature_min = 4 if temperature_min.nil?
      temperature_max = 100 if temperature_max.nil?
      if (temperature < temperature_min || temperature > temperature_max)
        errors.add(:temperature, "between #{temperature_min} to #{temperature_max}")
      end
    end

    if !hold_time.nil? && hold_time < 0
      errors.add(:hold_time, "Cannot be negative")
    end

    if collect_data && (infinite_hold? || pause)
      errors.add(:collect_data, "Cannot collect data on #{(infinite_hold?)? "infinite hold" : "pause"} step")
    end
  end
end

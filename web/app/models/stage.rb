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
class Stage < ActiveRecord::Base
  include ProtocolHelper
  include ProtocolOrderHelper

  include Swagger::Blocks

  swagger_schema :Stage do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :stage_type do
      key :type, :string
      key :enum, ['holding', 'cycling', 'meltcurve']
    end
    property :name do
      key :type, :string
    end
    property :num_cycles do
      key :type, :integer
      key :format, :int32
      key :minimum, 1
    end
    property :auto_delta do
      key :type, :boolean
      key :default, false
    end
    property :auto_delta_start_cycle do
      key :type, :integer
    end
    property :steps do
      key :type, :array
      items do
        key :'$ref', :Step
      end
    end
  end

	swagger_schema :StageValue do
		property :stage do
			key :description, 'Give a description of all the parameters'
			property :id do
				key :type, :integer
				key :format, :int64
			end
			property :stage_type do
				key :type, :string
			end
			property :name do
				key :type, :string
			end
			property :num_cycles do
				key :type, :integer
				key :format, :int32
			end
			property :auto_delta do
				key :type, :boolean
				key :default, false
			end
			property :auto_delta_start_cycle do
				key :type, :integer
			end
		end
	end

	swagger_schema :StageInput do
		property :prev_id do
			key :type, :integer
			key :format, :int64
			key :required, true
			key :description, 'prev stage id or null if it is the first node'
		end
	end

  belongs_to :protocol
  has_many :steps, -> {order("order_number")}
  has_many :ramps, :through => :steps

  scope :collect_data, lambda {|experiment_definition_id| joins(:steps, :protocol).joins("LEFT OUTER JOIN ramps ON ramps.next_step_id = steps.id").where(["experiment_definition_id=? AND stage_type=? AND (steps.collect_data=true OR ramps.collect_data=true)", experiment_definition_id, TYPE_CYCLE]).order("stages.order_number")}
  scope :melt_curve, lambda {|experiment_definition_id| joins(:protocol).where(["experiment_definition_id=? and stage_type=?", experiment_definition_id, TYPE_MELTCURVE])}

  validate :validate

  TYPE_HOLD   = "holding"
  TYPE_CYCLE  = "cycling"
  TYPE_MELTCURVE = "meltcurve"

  ACCESSIBLE_ATTRS = [:name, :num_cycles, :stage_type, :auto_delta, :auto_delta_start_cycle]

  before_create do |stage|
    if num_cycles.nil? && cycle_stage?
      self.num_cycles = 40
    elsif hold_stage? || num_cycles.nil?
      self.num_cycles = 1
    end
  end

  after_create do |stage|
    if steps.count == 0
      if hold_stage?
        if !prev_id.nil?
          reference_stage = Stage.find_by_id(prev_id)
        end
        if reference_stage.nil?
          reference_stage = siblings.first
        end
        if reference_stage
          reference_step = reference_stage.steps.last
        end
        if reference_step
          stage.steps << Step.new(:temperature=>reference_step.temperature, :hold_time=>reference_step.hold_time, :order_number=>0)
        else
          stage.steps << Step.new(:temperature=>95, :hold_time=>30, :order_number=>0)
        end
      elsif cycle_stage?
        stage.steps << Step.new(:temperature=>95, :hold_time=>30, :order_number=>0)
        stage.steps << Step.new(:temperature=>60, :hold_time=>30, :order_number=>1)
      elsif meltcurve_stage?
        stage.steps << Step.new(:temperature=>90, :hold_time=>30, :order_number=>0)
        stage.steps << Step.new(:temperature=>60, :hold_time=>60, :order_number=>1)
        step = Step.new(:temperature=>95, :hold_time=>30, :order_number=>2)
        step.ramp = Ramp.new(:rate=>0.09, :collect_data=>true)
        stage.steps << step
      end
    end
  end

  before_destroy do |stage|
    if stage.destroyed?
      false
    elsif stage.protocol && stage.protocol.stages.count <= 1
      errors.add(:base, "At least one stage is required")
      false
    end
  end

  #delete steps after stage destroy, so that step.stage will be nil
  after_destroy do |stage|
    for step in stage.steps
      step.destroy
    end
  end

  def name
    name_attr = read_attribute(:name)
    if name_attr.nil?
      if hold_stage?
        return "Holding Stage"
      elsif cycle_stage?
        return "Cycling Stage"
      elsif meltcurve_stage?
        return "Melt Curve Stage"
      end
    else
      return name_attr
    end
  end

  def hold_stage?
    stage_type == TYPE_HOLD
  end

  def cycle_stage?
    stage_type == TYPE_CYCLE
  end

  def meltcurve_stage?
    stage_type == TYPE_MELTCURVE
  end

  def copy
    new_stage = copy_helper
    steps.each do |step|
      new_stage.steps << step.copy
    end
    new_stage
  end

  def new_sibling?
    new_record?
  end

  def siblings
    if protocol.nil?
      nil
    elsif !id.nil?
      protocol.stages.where("id != ?", id)
    else
      protocol.stages
    end
  end

  def last_stage?
    !self.class.where("protocol_id = ? and order_number > ?", protocol_id, order_number).exists?
  end

  protected

  def validate
    if auto_delta
      if !cycle_stage?
        errors.add(:auto_delta, "only allowed for cycling stage")
      elsif auto_delta_start_cycle == 0 || auto_delta_start_cycle > num_cycles
        errors.add(:auto_delta_start_cycle, "Cannot be greater than the total number of cycles")
      end
    end

    if new_record?
      if !prev_id.nil?
        step = Step.where(:stage_id=>prev_id).order(order_number: :desc).first
        if step && step.infinite_hold?
          errors.add(:base, "Cannot add stage after infinite hold step")
        end
      end
    end
  end
end

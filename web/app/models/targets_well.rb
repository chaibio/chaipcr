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
class TargetsWell < ActiveRecord::Base
  include ProtocolLayoutHelper
  
  TYPE_STANDARD = "standard"
  TYPE_UNKNOWN = "unknown"

  scope :for_experiment, lambda {|experiment| where(:well_layout_id=>experiment.well_layout.id)}

  scope :with_data, lambda {|experiment, stage|
    select("targets_wells.*, samples_wells.sample_id AS sample_id, amplification_curves.ct as cq, targets.name as target_name, targets.channel as channel, cached_standard_curve_data.equation as target_equation")
    .joins("inner join targets on targets.id = targets_wells.target_id left join amplification_curves on amplification_curves.well_num = targets_wells.well_num and amplification_curves.channel = targets.channel and amplification_curves.experiment_id=#{experiment.id} and amplification_curves.stage_id=#{stage.id} left join samples_wells on samples_wells.well_num = targets_wells.well_num AND samples_wells.well_layout_id = targets_wells.well_layout_id left join cached_standard_curve_data on cached_standard_curve_data.target_id=targets_wells.target_id and (cached_standard_curve_data.well_layout_id=targets_wells.well_layout_id or cached_standard_curve_data.well_layout_id=targets.well_layout_id)")
    .where(["targets_wells.well_layout_id=? and targets_wells.omit=false and targets_wells.well_type is NOT NULL", experiment.well_layout.id])
    .order("targets_wells.target_id, targets_wells.well_type, sample_id, quantity_m, quantity_b, targets_wells.well_num")
  }
  
  belongs_to :well_layout
  belongs_to :target
  
  attr_accessor :validate_targets_in_well
  attr_accessor :replic, :mean_cq, :mean_quantity
  
  validates_presence_of :well_num
  validates :well_num, :inclusion => {:in=>1..16, :message => "%{value} is not between 1 and 16"}
  validates :well_type, inclusion: { in: ["positive_control", "negative_control", TYPE_STANDARD, TYPE_UNKNOWN, nil],
     message: "'%{value}' is not a valid type" }

  validate :validate
  
  before_update do |target_well|
    if target_well.well_type != TYPE_STANDARD
      target_well.quantity_m = nil
      target_well.quantity_b = nil
    end
  end
  
  def self.find_or_create(target, well_layout_id, well_num)
     target_well = joins(:target).where(["targets_wells.well_layout_id=? and targets_wells.well_num=? and targets.channel=?", well_layout_id, well_num, target.channel]).first
     if target_well
       target_well.target = target
     else
       target_well = self.new(:well_layout_id=>well_layout_id, :target=>target, :well_num=>well_num)
       target_well.validate_targets_in_well = false
     end
     target_well
  end
  
  def self.process_data(targets_wells)
    lasttarget = nil
    replic_group = nil
    replic_group_num = 1
    cq_sum = 0
    quantity_sum = nil
    targets = []
    targets_wells << nil
    targets_wells.each do |target|
      if lasttarget != nil && target != nil && lasttarget.target_id == target.target_id && lasttarget.well_type == target.well_type && lasttarget.sample_id == target.sample_id
        replic = false
        if lasttarget.well_type == TYPE_STANDARD
          if lasttarget.quantity_m != nil && lasttarget.quantity_b != nil && lasttarget.quantity_m == target.quantity_m && lasttarget.quantity_b == target.quantity_b
            replic = true
          end
        elsif lasttarget.well_type == TYPE_UNKNOWN
          if lasttarget.sample_id != nil
            replic = true
          end
        else
          replic = true
        end
        if replic == true
          if replic_group.empty?
            lasttarget.replic = replic_group_num
            cq_sum += lasttarget.cq if !lasttarget.cq.nil?
            quantity_sum = BigDecimal.new("#{lasttarget.quantity[0]}e#{lasttarget.quantity[1]}") if !lasttarget.quantity_blank?
            replic_group << lasttarget
          end
          target.replic = replic_group_num
          cq_sum += target.cq if !target.cq.nil?
          quantity_sum += BigDecimal.new("#{target.quantity[0]}e#{target.quantity[1]}") if !target.quantity_blank?
          replic_group << target
        end
      else
        if !replic_group.blank?
          mean_cq = cq_sum/replic_group.length
          if !quantity_sum.nil?
            mean_quantity = quantity_sum/replic_group.length
            mean_quantity_nodes = decimal_to_scientific_notation(mean_quantity)
          else
            mean_quantity_nodes = [nil, nil]
          end
          replic_group.each do |replic_target|
            replic_target.mean_cq = mean_cq
            replic_target.mean_quantity = mean_quantity_nodes
          end
          replic_group_num += 1
        end
        replic_group = []
        cq_sum = 0
        quantity_sum = nil
      end
      #create targets list with unique target
      if target
        if targets.empty?
          targets << target
        elsif targets.last.target_id != target.target_id
          targets << target
        end
      end
      lasttarget = target
    end
    targets_wells.pop()
    targets
  end

  def self.fake_targets
    targets = []
    targets << OpenStruct.new(:target_id => 1, :target_name=>"Ch 1", :target_equation=>nil)
    targets << OpenStruct.new(:target_id => 2, :target_name=>"Ch 2", :target_equation=>nil)
    targets
  end

  def mean_quantity
    @mean_quantity || [nil, nil]
  end

  def cq
    cq_value = read_attribute(:cq)
    (cq_value.nil?)? nil : cq_value.to_f
  end

  def target_equation
    if @equation == nil
      equation = read_attribute(:target_equation)
      @equation = (equation.nil?)? nil : JSON.parse(equation)
    end
    @equation
  end

  def quantity
    if @quantity == nil
      if well_type == TYPE_STANDARD
        @quantity = [quantity_m.to_f, quantity_b.to_i]
      elsif well_type == TYPE_UNKNOWN
        if target_equation != nil && target_equation["offset"] != nil && target_equation["slope"] != nil && cq != nil
          quantity_log10 = (cq-target_equation["offset"])/target_equation["slope"]
          quantity_value = 10**quantity_log10
          quantity_nodes = self.class.decimal_to_scientific_notation(quantity_value)
          if quantity_nodes.length == 2
            @quantity = [quantity_nodes[0], quantity_nodes[1]]
          end
        end
      end
      @quantity ||= [nil, nil]
    end
    @quantity
  end

  def quantity_blank?
    self.quantity.blank? || self.quantity[0].nil?
  end

  protected

  def self.decimal_to_scientific_notation(decimal)
    nodes = ("%.8e" % decimal).split("e")
    nodes[0] = nodes[0].to_f
    nodes[1] = nodes[1].to_i
    nodes
  end

  def validate
    if !quantity_m.nil? && quantity_m < 0
      errors.add(:quantity, "has to be positive number")
    end
    if target.imported && well_type != nil && well_type != TYPE_UNKNOWN
      errors.add(:well_type, "#{well_type} cannot be supported for imported target")
    end
    if new_record? && validate_targets_in_well != false
      if joins(:target).where(["targets_wells.well_layout_id=? and targets_wells.well_num=? and targets.channel=?", well_layout_id, well_num, target.channel]).exists?
        errors.add(:target_id, "#{target.channel} is already occupied in well #{well_num}")
      end
    end
  end
  
end

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
class AmplificationOption < ActiveRecord::Base
  belongs_to :experiment_definition
    
  ACCESSIBLE_ATTRS = [:cq_method, :min_fluorescence, :min_reliable_cycle, :min_d1, :min_d2, :baseline_cycle_bounds]
  
  CQ_METHOD_CY0 = "Cy0"
  CQ_METHOD_cpD2 = "cpD2"
  
  validates_inclusion_of :cq_method, :in => [CQ_METHOD_CY0, CQ_METHOD_cpD2]
  
  [:min_fluorescence, :min_reliable_cycle, :min_d1, :min_d2, :baseline_cycle_min, :baseline_cycle_max].each do |column|
    validates column, numericality: {greater_than_or_equal_to: 1}, allow_nil: true
  end
  
  validate :validate
  
  def cq_method
    val = read_attribute(:cq_method)
    (val.blank?)? CQ_METHOD_CY0 : val
  end
  
  def min_fluorescence
    val = read_attribute(:min_fluorescence)
    (val.blank?)? 4356 : val
  end
  
  def min_reliable_cycle
    val = read_attribute(:min_reliable_cycle)
    (val.blank?)? 5 : val
  end
  
  def min_d1
    val = read_attribute(:min_d1)
    (val.blank?)? 472 : val
  end
  
  def min_d2
    val = read_attribute(:min_d2)
    (val.blank?)? 41 : val
  end
  
  def baseline_cycle_bounds
    if baseline_cycle_min.blank?
      nil
    else
      [baseline_cycle_min, baseline_cycle_max]
    end
  end
  
  def baseline_cycle_bounds=(bounds)
    if bounds && bounds.length == 2
      self.baseline_cycle_min = bounds[0]
      self.baseline_cycle_max = bounds[1]
    else
      self.baseline_cycle_min = nil
      self.baseline_cycle_max = nil
    end
  end
  
  protected
  
  def validate
    if (baseline_cycle_min.blank? && !baseline_cycle_max.blank?) ||
       (!baseline_cycle_min.blank? && baseline_cycle_max.blank?)
       errors.add(:baseline_cycle_bounds, "Both min and max cycles have to be defined")
    end
  end
end

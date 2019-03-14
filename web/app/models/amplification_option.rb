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
	include Swagger::Blocks


	swagger_schema :AmplificationOption do
		property :cq_method do
			key :description, 'Cy0:A Cq calling method based on the max first derivative of the curve (recommended). cpD2:A Cq calling method based on the max second derivative of the curve.'
			key :type, :string
			key :enum, ['Cy0', 'cpD2']
      key :default, 'Cy0'
		end
		property :baseline_method do
			key :description, 'baseline method'
			key :type, :string
			key :enum, ['sigmoid', 'linear', 'median']
      key :default, 'sigmoid'
		end
		property :min_fluorescence do
			key :description, 'The minimum fluorescence threshold for Cq calling. Cq values will not be called when the fluorescence is below this threshold.'
			key :type, :integer
      key :default, 4356
		end
		property :min_reliable_cycle do
			key :description, 'The earliest cycle to use in Cq calling & baseline subtraction. Data for earlier cycles will be ignored.'
			key :type, :integer
      key :default, 5
		end
		property :min_d1 do
			key :description, 'The threshold which the first derivative of the curve must exceed for a Cq to be called.'
			key :type, :integer
      key :default, 472
		end
		property :min_d2 do
			key :description, 'The threshold which the second derivative of the curve must exceed for a Cq to be called.'
			key :type, :integer
			key :default, 41
		end
		property :baseline_cycle_bounds do
			key :description, '[baseline_cycle_min, baseline_cycle_max]'
			key :type, :Array
      items do
        key :type, :integer
      end
		end
	end

  ACCESSIBLE_ATTRS = [:cq_method, :baseline_method, :min_fluorescence, :min_reliable_cycle, :min_d1, :min_d2, :baseline_cycle_bounds]

  CQ_METHOD_CY0 = "Cy0"
  CQ_METHOD_cpD2 = "cpD2"

  BASELINE_METHOD_SIGMOID = "sigmoid"
  BASELINE_METHOD_LINEAR = "linear"
  BASELINE_METHOD_MEDIAN = "median"
  
  validates_inclusion_of :cq_method, :in => [CQ_METHOD_CY0, CQ_METHOD_cpD2]
  validates_inclusion_of :baseline_method, :in => [BASELINE_METHOD_SIGMOID, BASELINE_METHOD_LINEAR, BASELINE_METHOD_MEDIAN]

  [:min_fluorescence, :min_reliable_cycle, :min_d1, :min_d2, :baseline_cycle_min, :baseline_cycle_max].each do |column|
    validates column, numericality: {greater_than_or_equal_to: 1}, allow_nil: true
  end

  validate :validate
  before_save :before_save

  def cq_method
    val = read_attribute(:cq_method)
    (val.blank?)? CQ_METHOD_CY0 : val
  end

  def baseline_method
    val = read_attribute(:baseline_method)
    (val.blank?)? BASELINE_METHOD_SIGMOID : val
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

  def to_rserve_params
    "cp='#{cq_method}',min_fluomax=#{min_fluorescence},min_D1max=#{min_d1},min_D2max=#{min_d2},min_reliable_cyc=#{min_reliable_cycle}#{",baseline_cyc_bounds=c("+baseline_cycle_min.to_s+","+baseline_cycle_max.to_s+")" if !baseline_cycle_min.nil?}"
  end

  def to_hash
    {:cq_method=>cq_method, :baseline_method=>baseline_method, :min_fluomax=>min_fluorescence, :min_D1max=>min_d1, :min_D2max=>min_d2, :min_reliable_cyc=>min_reliable_cycle, :baseline_cyc_bounds=>(baseline_cycle_min.nil?)? [] : [baseline_cycle_min, baseline_cycle_max]}
  end

  def changed?
    super || @save_changed
  end

  protected

  def validate
    if (baseline_cycle_min.blank? && !baseline_cycle_max.blank?) ||
       (!baseline_cycle_min.blank? && baseline_cycle_max.blank?)
       errors.add(:baseline_cycle_bounds, "Both min and max cycles have to be defined")
    end
  end

  def before_save
    @save_changed = self.new_record? || self.changed?
  end
end

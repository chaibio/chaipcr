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
class Sample < ActiveRecord::Base
  include ProtocolLayoutHelper
  include Swagger::Blocks
    
  swagger_schema :Sample do
    property :id do
      key :type, :integer
      key :format, :int64
      key :readOnly, true
    end
    property :name do
      key :type, :string
      key :description, 'Sample name'
    end
    property :notes do
      key :type, :string
      key :description, 'Sample notes'
    end
  end
  
	swagger_schema :FullSample do
    allOf do
      schema do
        property :samples_wells do
          key :type, :array
          items do
            key :'$ref', :SampleWell
          end
        end
      end
      schema do
        key :'$ref', :Sample
      end
    end
  end
  
  belongs_to :well_layout
  has_many :samples_wells, dependent: :destroy
  
  attr_accessor :force_destroy
  
  validates_presence_of :name
  ACCESSIBLE_ATTRS = [:well_layout_id, :name, :notes]
  
  before_create do |sample|
    sample.samples_wells.each do |sample_well|
      sample_well.well_layout_id = sample.well_layout_id if sample_well.well_layout_id.nil?
    end
  end

  def belongs_to_experiment?(experiment)
    well_layout_id == experiment.well_layout.id
  end
  
  def copy
    new_sample = copy_helper
    samples_wells.each do |sample_well|
      new_sample_well = sample_well.copy_helper
      new_sample_well.validate_samples_in_well = false
      new_sample.samples_wells << new_sample_well
    end
    new_sample
  end
  
   def destroy
    if force_destroy != true
      if linked?
        errors.add(:base, "sample is linked to well")
        return false
      end
    end
    super
  end
  
  protected
  
  def linked?
    samples_wells.exists?
  end
   
end

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
  
  belongs_to :well_layout
  has_many :samples_wells, dependent: :destroy
  
  validates_presence_of :name
  ACCESSIBLE_ATTRS = [:well_layout_id, :name]
  
  before_create do |sample|
    sample.samples_wells.each do |sample_well|
      sample_well.well_layout_id = sample.well_layout_id
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
end

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
class SamplesWell < ActiveRecord::Base
  include ProtocolLayoutHelper
  include Swagger::Blocks
    
  swagger_schema :SampleWell do
    extend SwaggerHelper::PropertyWellnum
  end
  
  belongs_to :well_layout, touch: true
  belongs_to :sample
    
  attr_accessor :validate_samples_in_well
  
  validates_presence_of :well_num
  validates :well_num, :inclusion => {:in=>1..16, :message => "%{value} is not between 1 and 16"}
  validate :validate
  
  def self.find_or_create(sample, well_layout_id, well_num)
     sample_well = where(:well_layout_id=>well_layout_id, :well_num=>well_num).first
     if sample_well
       sample_well.sample = sample
     else
       sample_well = self.new(:well_layout_id=>well_layout_id, :sample=>sample, :well_num=>well_num)
       sample_well.validate_samples_in_well = false
     end
     sample_well
  end
  
  protected

  def validate
    if new_record? && validate_samples_in_well != false
      if where(:well_layout_id=>well_layout_id, :well_num=>well_num).exists?
        errors.add(:sample_id, "is already occupied in well #{well_num}")
      end
    end
  end
  
end

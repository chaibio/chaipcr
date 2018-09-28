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
module ProtocolLayoutHelper  
  def copy_helper
    self.class.new(attribute_hash(["id", "protocol_id", "stage_id", "step_id", "well_layout_id", "sample_id", "target_id", "created_at", "updated_at"]))
  end
  
  private
  
  def attribute_hash (exclude_names)
    hash_values = {}
    attribute_names.each do |name|
      if !exclude_names.include?(name)
        hash_values[name]= read_attribute(name)
      end
    end
    hash_values
  end
  
end
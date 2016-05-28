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
class DeviceConfiguration
#  CONFIGURATION_FILE_PATH  = "/Users/xia/chaipcr/device/configuration.json"
  CONFIGURATION_FILE_PATH = "/root/configuration.json"

  @@configuration_hash = nil

  def self.exists?
    File.exists?(CONFIGURATION_FILE_PATH)
  end
  
  def self.valid?
    !configuration_hash.blank?
  end
  
  def self.software_version
    configuration_hash["software"]["version"]
  end
  
  def self.method_missing(mid, *args)
    result = configuration_hash[mid.to_s]
  end
  
  protected

  def self.configuration_hash
    if @@configuration_hash == nil
      begin
        configuration_file = File.read(CONFIGURATION_FILE_PATH)
        @@configuration_hash = JSON.parse(configuration_file) if configuration_file
      rescue  => e
        @@configuration_hash = {}
      end
    end
    return @@configuration_hash
  end
end
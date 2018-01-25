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
class Device
  include Swagger::Blocks
 # DEVICE_FILE_PATH  = "/Users/xia/chaipcr/device/device.json"
  DEVICE_FILE_PATH  = "/perm/device.json"


  swagger_schema :Device do
    property :serial_number do
      key :type, :string
      key :description, 'Serial number of the device'
    end
    property :model_number do
      key :type, :string
      key :description, 'Hardware model number of the device'
    end
    property :processor_architecture do
      key :type, :string
      key :description, 'Device processor architecture'
    end
    property :software do
      property :version do
        key :type, :string
        key :description, 'Current software version'
      end
      property :platform do
        key :type, :string
        key :description, 'Current software platform'
      end
    end
  end

  @@device_hash = nil

  def self.exists?
    File.exists?(DEVICE_FILE_PATH)
  end

  def self.valid?
    !device_hash.blank?
  end

  def self.serialized?
    !device_hash["serial_number"].blank?
  end

  def self.dual_channel?
    device_hash["capabilities"] && device_hash["capabilities"]["optics"] && device_hash["capabilities"]["optics"]["emission_channels"] && device_hash["capabilities"]["optics"]["emission_channels"].length == 2
  end

  def self.method_missing(mid, *args)
    return device_hash[mid.to_s]
  end

  def self.write(device_data)
    begin
      @@device_hash = JSON.parse(device_data)
    rescue  => e
      return "not valid json data"
    end

    begin
      File.open(DEVICE_FILE_PATH, 'w+') { |file| file.write(device_data) }
    rescue  => e
      return "Write to #{DEVICE_FILE_PATH} failed: #{e}"
    end

    return nil
  end

  def self.unserialized!
    device_hash.delete("serial_number")
    begin
      File.open(DEVICE_FILE_PATH, 'w+') { |file| file.write(JSON.pretty_generate(device_hash)) }
    rescue  => e
      return "Write to #{DEVICE_FILE_PATH} failed: #{e}"
    end
  end

  protected

  def self.device_hash
    if @@device_hash == nil
      begin
        device_file = File.read(DEVICE_FILE_PATH)
        @@device_hash = JSON.parse(device_file) if device_file
      rescue  => e
        @@device_hash = {}
      end
    end
    return @@device_hash
  end
end

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
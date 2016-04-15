class Device
 # DEVICE_FILE_PATH  = "/Users/xia/chaipcr/device/device.json"
  DEVICE_FILE_PATH  = "/perm/device.json"

  @@device_hash = nil

  def self.exists?
    File.exists?(DEVICE_FILE_PATH)
  end
  
  def self.valid?
    !device_hash.blank?
  end
  
  def self.dual_channel?
    device_hash["emission_channels"] && device_hash["emission_channels"].length == 2
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
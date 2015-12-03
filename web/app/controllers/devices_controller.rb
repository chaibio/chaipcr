class DevicesController < ApplicationController
  include ParamsHelper
  
  skip_before_action :verify_authenticity_token, :except=>[:root_password]
  before_filter :allow_cors, :except=>[:root_password]
  before_filter :ensure_authenticated_user, :only=>[:show, :capabilities]
  
  respond_to :json
  
  resource_description { 
    formats ['json']
  }

  DEVICE_FILE_PATH  = "/Users/xia/chaipcr/device/device.json"
  CONFIGURATION_FILE_PATH  = "/Users/xia/chaipcr/device/configuration.json"
  #DEVICE_FILE_PATH  = "/perm/device.json"
  #CONFIGURATION_FILE_PATH = "/root/configuration.json"
  
  def update
    if !File.exists?(DEVICE_FILE_PATH)
      File.open(DEVICE_FILE_PATH, 'w+') { |file| file.write(params[:data]) }
#      `passwd -d root`
      render json: {response: "Device is programmed successfully"}, status: :ok
    else
      render json: {errors: "Device is already serialized"}, status: 405
    end 
  end
  
  api :GET, "/device", "return device specific information"
  example "{'serial_number':'1234789127894212','model_number':'M2342JA','processor_architecture':'armv7l','software':{'version':'1.0.0','platform':'S0100'}}"
  description <<-EOS
    ==response json format
    ===serial_number
    serial number of the device
    ===model_numberloclalo
    hardware model number of the device 
    ===processor_architecture
    device processor architecture
    ===software version
    current software version
    ===software platform
    current software platform
  EOS
  def show
      device_file = File.read(DEVICE_FILE_PATH)
      device_hash = JSON.parse(device_file)
      configuration_file = File.read(CONFIGURATION_FILE_PATH)
      configuration_hash = JSON.parse(configuration_file)
      result_hash = Hash.new
      result_hash["serial_number"] = device_hash["serial_number"]
      result_hash["model_number"] = device_hash["model_number"]
      result_hash["processor_architecture"] = device_hash["processor_architecture"]
      result_hash["software"] = configuration_hash["software"]
      render json: result_hash.to_json, status: :ok
  end
  
  api :GET, "/capabilities", "return device capabilities"
  example "{'capabilities':{'plate':{'rows':2,'columns':8,'min_volume_ul':5,'max_volume_ul':100},'optics':{'excitation_channels':[{'begin_wavelength':462,'end_wavelength':490}],'emission_channels':[{'begin_wavelength':510,'end_wavelength':700}]},'storage':{'microsd_size_gb':8,'emmc_size_gb':4}},'thermal':{'lid':{'max_temp_c':120},'block':{'min_temp_c':4,'max_temp_c':100}}}"
  def capabilities
    device_file = File.read(DEVICE_FILE_PATH)
    device_hash = JSON.parse(device_file)
    configuration_file = File.read(CONFIGURATION_FILE_PATH)
    configuration_hash = JSON.parse(configuration_file)
    result_hash = Hash.new
    result_hash["capabilities"] = device_hash["capabilities"]
    result_hash["thermal"] = configuration_hash["thermal"]
    render json: result_hash.to_json, status: :ok
  end
  
  api :PUT, "/root_password", "Set root password"
  param :password, String, :desc => "password to set", :required=>true
  def root_password
  end
   
  def mac_address
    if !File.exists?(DEVICE_FILE_PATH)
      mac = retrieve_mac
      render json: {mac: mac}
    else
      render json: {errors: "Device is already serialized"}, status: 401
    end
  end
  
  private

  def retrieve_mac
    str = `ifconfig eth0 | grep HWaddr`
#    str = "eth0      Link encap:Ethernet  HWaddr 54:4a:16:c0:7e:28 "
    re = %r/([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}/
    return re.match(str).to_s.strip
  end
  
  def allow_cors
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "GET,PUT,POST,OPTIONS"
    headers["Access-Control-Allow-Headers"] = "*"
    headers["Access-Control-Max-Age"] = "1728000"
    head(:ok) if request.request_method == "OPTIONS"
  end
  
end
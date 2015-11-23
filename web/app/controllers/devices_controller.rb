class DevicesController < ApplicationController
  include ParamsHelper
  
  skip_before_action :verify_authenticity_token, :except=>[:root_password]
  before_filter :allow_cors, :except=>[:root_password]
  
  respond_to :json
  
  resource_description { 
    formats ['json']
  }

#  DEVICE_FILE_PATH  = "/Users/xia/device.json"
  DEVICE_FILE_PATH  = "/perm/device.json"
  
  def show
  end
  
  def update
    if !File.exists?(DEVICE_FILE_PATH)
      File.open(DEVICE_FILE_PATH, 'w+') { |file| file.write(params[:data]) }
#      `passwd -d root`
      render json: {response: "success"}, status: :ok
    else
      render json: {errors: "device is already serialized"}, status: 405
    end 
  end
  
  def capabilities
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
      render json: {errors: "Not authorized"}, status: 401
    end
  end
  
  private

  def retrieve_mac
    str = `ifconfig eth0 | grep HWaddr`
    #str = "eth0      Link encap:Ethernet  HWaddr 54:4a:16:c0:7e:28 "
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
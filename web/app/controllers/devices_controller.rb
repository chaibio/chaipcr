require "net/http"

class DevicesController < ApplicationController
  include ParamsHelper
  
  skip_before_action :verify_authenticity_token, :except=>[:root_password]
  before_filter :allow_cors, :except=>[:root_password]
  before_filter :ensure_authenticated_user, :only=>[:show, :capabilities, :enable_support_access]
  
  respond_to :json
  
  resource_description { 
    formats ['json']
  }

  #DEVICE_FILE_PATH  = "/Users/xia/chaipcr/device/device.json"
  #CONFIGURATION_FILE_PATH  = "/Users/xia/chaipcr/device/configuration.json"
  DEVICE_FILE_PATH  = "/perm/device.json"
  CONFIGURATION_FILE_PATH = "/root/configuration.json"
  
  def update
    if !File.exists?(DEVICE_FILE_PATH)
      File.open(DEVICE_FILE_PATH, 'w+') { |file| file.write(params[:data]) }
      `passwd -d root`
      User.delete_all
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
  
  api :GET, "/device/status", "status of the machine"
  def status
    url = URI.parse("http://localhost:8000/status?access_token=#{token}")
    begin
      response = Net::HTTP.get_response(url)
      json = JSON.parse(response)
      render :json=>json
    rescue  => e
      render json: {errors: "reatime server port 8000 cannot be reached: #{e}"}, status: 500
      return
    end
  end
  
  api :PUT, "/device/root_password", "Set root password"
  param :password, String, :desc => "password to set", :required=>true
  def root_password
    system("printf '#{params[:password]}\n#{params[:password]}\n' | passwd")
    render json: {response: "Root password is set properly"}, status: :ok
  end
   
  def mac_address
    if !File.exists?(DEVICE_FILE_PATH)
      mac = retrieve_mac
      if !mac.blank?
        render json: {mac: mac}
      else
        render json: {errors: "Device mac address not found"}, status: 500
      end
    else
      render json: {errors: "Device is already serialized"}, status: 401
    end
  end
  
  api :GET, "/device/software_update", "query the software update meta data"
  example "{'upgrade':{'version':'1.0.1','release_date':null,'brief_description':'this is the brief description','full_description':'this is the full description'}}"
  def software_update
    @upgrade = Upgrade.first
    if @upgrade
      configuration_file = File.read(CONFIGURATION_FILE_PATH)
      configuration_hash = JSON.parse(configuration_file)
      logger.info(configuration_hash)
      #no upgrade available if the upgrade version is the same as current software version
      @upgrade = nil if @upgrade.version == configuration_hash["software"]["version"]
    end
    respond_to do |format|
      format.json { render "software_update", :status => :ok}
    end
  end
  
  api :POST, "/device/enable_support_access", "enable remote support access"
  def enable_support_access
    device_file = File.read(DEVICE_FILE_PATH)
    device_hash = JSON.parse(device_file)
    configuration_file = File.read(CONFIGURATION_FILE_PATH)
    configuration_hash = JSON.parse(configuration_file)
    query_hash = Hash.new
    query_hash[:v] = 1
    query_hash[:model_number] = device_hash["model_number"]
    query_hash[:software_version] = configuration_hash["software"]["version"]
    query_hash[:software_platform] = configuration_hash["software"]["platform"]
    query_hash[:serial_number] = device_hash["serial_number"]
    #query_hash[:device_signature]
    
    #query cloud server for auth_token and ssh keys
    url = URI.parse("#{CLOUD_SERVER}/device/provision_support_access?#{query_hash.to_query}")
    begin
      response = Net::HTTP.get_response(url)
    rescue  => e
      render json: {errors: "chai cloud server #{CLOUD_SERVER} cannot be reached: #{e}"}, status: 500
      return
    end
    
    if response.code.to_i != 200 
      render json: {errors: "chai cloud server #{CLOUD_SERVER} provision_support_access fails (#{response.code}): #{response.body}"}, status: 500
      return
    end
    
    #setup ngrok
    json_response = JSON.parse(response.body)
    
    begin
      logger.info("replace /root/.ngrok2/ngrok.yml")
      File.open("/root/.ngrok2/ngrok.yml", 'w') {|f| f.write("authtoken: #{json_response["tunnel_authtoken"]}") }
    rescue  => e
      render json: {errors: "open ngrok.yml fails: #{e}"}, status: 500
      return
    end
    
    begin
      logger.info("replace /home/service/.ssh/authorized_keys")
      File.open("/home/service/.ssh/authorized_keys", 'w') {|f| f.write(json_response["ssh_access_key"]) }
    rescue  => e
      render json: {errors: "open .ssh/authorized_keys fails: #{e}"}, status: 500
      return
    end
        
    #kill ngrok
    kill_process("ngrok")
    
    #run ngrok
    system("/root/ngrok tcp -log=stdout 22 > /dev/null &")
    
    sleep(1.0)
    
    #get tunnel_url
    begin
      response = Net::HTTP.get_response(URI.parse("http://localhost:4040/api/tunnels"))
    rescue  => e
      render json: {errors: "ngrok is not running: #{e}"}, status: 500
      return
    end
    
    if response.code.to_i != 200 
      render json: {errors: "ngrok api/tunnels returns error ()#{response.code}): #{response.body}"}, status: 500
      return
    end
    
    json_response = JSON.parse(response.body)
    tunnel_url = json_response["tunnels"][0]["public_url"]
    logger.info("tunnel_url=#{tunnel_url}")
    
    if tunnel_url.blank?
      render json: {errors: "tunnel_url is not found"}, status: 500
      return
    end
    
    #post to cloud server
    begin
      uri = URI.parse("#{CLOUD_SERVER}/device/establish_support_tunnel")
      response = Net::HTTP.post_form(uri, 'serial' => device_hash["serial_number"], 'url' => tunnel_url)
    rescue => e
      render json: {errors: "chai cloud server #{CLOUD_SERVER} cannot be reached: #{e}"}, status: 500
      return
    end
    
    if response.code.to_i != 200 
      render json: {errors: "publish tunnel url #{tunnel_url} failed (#{response.code}): #{response.body}"}, status: 500
      return
    end
    
    render :nothing=>true, :status=>:ok
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
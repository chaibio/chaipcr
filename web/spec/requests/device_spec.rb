require 'spec_helper'

describe "Device API", type: :request do
  it 'show status' do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
    get "/device/status", { :format => 'json' }
#    expect(response).to be_fail
  end
  
  it 'clean failed due to signature mismatch' do
    signature = "DFSDFGDFGDDSFASF"
    post '/login', { email: "factory@factory.com", password: "factory" }
    expect(Device).to receive(:valid?) do
      true
    end
    expect(Device).to receive(:device_signature).twice do
      signature
    end
    params = { signature: "abc" }
    put "/device/clean", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    response.response_code.should == 400
  end
  
=begin
  it 'clean success' do
    signature = "DFSDFGDFGDDSFASF"
    post '/login', { email: "factory@factory.com", password: "factory" }
    expect(Device).to receive(:valid?) do
      true
    end
    expect(Device).to receive(:device_signature).twice do
      signature
    end
    params = { signature: signature }
    put "/device/clean", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success
    get "/"
    response.should redirect_to "/login"
  end
=end
  
end

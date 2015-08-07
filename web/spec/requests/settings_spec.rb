require 'spec_helper'

describe "Settings" do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
  end
  
  it 'show' do
    get "/settings", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["settings"]["debug"].should be_false
    json["settings"]["time_zone"].should == "Pacific Time (US & Canada)"
    json["settings"]["time_zone_offset"].should == -28800
  end
  
  it 'update' do
    params = { settings: {time_zone: "Hawaii"} }
    put "/settings", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["settings"]["time_zone"].should == "Hawaii"
    json["settings"]["time_zone_offset"].should == -36000
  end
end
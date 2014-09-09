require 'spec_helper'

describe "User API" do
  it 'create user' do
    params = { user: {email: "test@test.com", password: "secret", password_confirmation: "secret"} }
    post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["user"]["email"].should == "test@test.com"
    json["user"]["role"].should == 0
  end
  
  it 'create invalid user' do
    params = { user: {email: "test@test.com", password: "secret", password_confirmation: "secret1"} }
    post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    response.response_code.should == 422
    json = JSON.parse(response.body)
    json["user"]["errors"].should_not be_nil
  end
  
  it "login as admin" do
    post '/login', { email: "admin@pcr.com", password: "changeme" }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json["authentication_token"].should == response.cookies['authentication_token']
  end
  
  it "login with invalid info" do
    post '/login', { email: "admin@pcr.com", password: "changeme1" }
    response.response_code.should == 401
    json = JSON.parse(response.body)
    json["errors"].should_not be_nil
  end
  
  it "access with valid token" do
  end
end
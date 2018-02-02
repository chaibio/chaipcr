require 'spec_helper'

describe "User", type: :request do
  describe "#login" do
    it "as admin" do
      admin_user = create_admin_user
      post '/login', { email: admin_user.email, password: admin_user.password }
      expect(response).to be_success
      json = JSON.parse(response.body)
      json["user_id"].should == admin_user.id
      json["authentication_token"].should == response.cookies['authentication_token']
    end
  
    it "with invalid info" do
      admin_user = create_admin_user
      post '/login', { email: admin_user.email, password: "changeme1" }
      response.response_code.should == 401
      json = JSON.parse(response.body)
      json["errors"].should_not be_nil
    end
  end
  
  describe "#create first" do
    it "admin user is allowed" do
      params = { user: {name:"admin", email: "admin@admin.com", password: "secret", password_confirmation: "secret", role:"admin"} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
    end

    it "regular user not allowed" do
        params = { user: {name:"test", email: "test@test.com", password: "secret", password_confirmation: "secret"} }
        post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        response.response_code.should == 401
        json = JSON.parse(response.body)
        json["errors"].should == "login in"
    end
  end
  
  describe "#create user not allowed" do
    it "without login" do
       create_admin_user
       params = { user: {name:"admin", email: "admin@admin.com", password: "secret", password_confirmation: "secret", role:"admin"} }
       post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
       response.response_code.should == 401
       json = JSON.parse(response.body)
       json["errors"].should == "login in"
    end

    it "without login as admin" do
       create_admin_user
       test_user = create_test_user
       post '/login', { email: test_user.email, password: test_user.password }
       params = { user: {name:"test", email: "test@test.com", password: "secret", password_confirmation: "secret"} }
       post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
       response.response_code.should == 401
       json = JSON.parse(response.body)
       json["errors"].should == "unauthorized"
    end
  end
  
  describe "#create user" do
    before(:each) do
     admin_user = create_admin_user
     post '/login', { email: admin_user.email, password: admin_user.password }
    end
    
    it "successful" do
      params = { user: {name:"test", email: "test@test.com", password: "secret", password_confirmation: "secret"} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      json = JSON.parse(response.body)
      json["user"]["email"].should == "test@test.com"
      json["user"]["role"].should == User::ROLE_USER
    end
    
    it "with invalid email address" do
      params = { user: {name:"test", email: "test@test,com", password: "secret", password_confirmation: "secret"} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
      json = JSON.parse(response.body)
      json["user"]["errors"]["email"].should_not be_nil
    end
    
    it "with duplicate email address" do
      user = create_test_user
      params = { user: {name: user.name, email: user.email.upcase, password: "secret", password_confirmation: "secret"} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
      json = JSON.parse(response.body)
      json["user"]["errors"]["email"].should_not be_nil
    end
    
    it "with blank password" do
      params = { user: {name: "test", email: "test@test.com", password: "", password_confirmation: ""} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
      json = JSON.parse(response.body)
      json["user"]["errors"]["password"].should_not be_nil
    end
    
    it "with password doesn't match with its confirmation" do
      params = { user: {name: "test", email: "test@test.com", password: "secret", password_confirmation: "secret1"} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
      json = JSON.parse(response.body)
      json["user"]["errors"].should_not be_nil
    end
  end
    
  describe "#edit user" do
    before(:each) do
      admin_user = create_admin_user
      post '/login', { email: admin_user.email, password: admin_user.password }
    end
    
    it "successful" do
      params = { user: {name: "test", email: "test@test.com", password: "secret", password_confirmation: "secret"} }
      test_user = create_test_user
      put "/users/#{test_user.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      post '/login', { email: "test@test.com", password: "secret" }
      expect(response).to be_success
    end
    
    it "not admin successful" do
      test_user = create_test_user
      post '/login', { email: test_user.email, password: test_user.password }
      params = { user: {password: "secret", password_confirmation: "secret"} }
      put "/users/#{test_user.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      post '/login', { email: "test@test.com", password: "secret" }
      expect(response).to be_success
    end
    
    it "not admin not allowed to edit other users" do
      test_user = create_test_user
      post '/login', { email: test_user.email, password: test_user.password }
      test_user2 = create_test_user2
      params = { user: {password: "secret", password_confirmation: "secret"} }
      put "/users/#{test_user2.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 401
    end
    
  end
  
  describe "#authentication_token" do
    before(:each) do
      admin_user = create_admin_user
      post '/login', { email: admin_user.email, password: admin_user.password }
    end
    
    it "invalid" do
      params = { user: {name: "test", email: "test@test.com", password: "secret", password_confirmation: "secret"} }
      token = "#{response.cookies['authentication_token']}a"
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json', 'HTTP_COOKIE' => "authentication_token=#{token}" }
      response.response_code.should == 401
      json = JSON.parse(response.body)
      json["errors"].should == "login in"
    end
    
    it "expired" do
      token = UserToken.where(access_token: UserToken.digest(response.cookies['authentication_token'])).first
      token.expired_at = 1.minute.ago
      token.save
      params = { user: {name: "test", email: "test@test.com", password: "secret", password_confirmation: "secret"} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      response.response_code.should == 401
      json = JSON.parse(response.body)
      json["errors"].should == "login in"
    end
    
    it "extent expire date" do
      cookie = response.cookies['authentication_token']
      token = UserToken.where(access_token: UserToken.digest(cookie)).first
      token.expired_at = 4.hours.from_now
      token.save
      params = { user: {name: "test", email: "test@test.com", password: "secret", password_confirmation: "secret"} }
      post "/users", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      expect(response).to be_success
      token = UserToken.where(access_token: UserToken.digest(cookie)).first
      token.expired_at.should be > 23.hours.from_now
    end
  end
  
  describe "#destroy user" do
    before(:each) do
     @admin_user = create_admin_user
     post '/login', { email: @admin_user.email, password: @admin_user.password }
    end
    
    it "delete successfully" do
      test_user = create_test_user
      delete "/users/#{test_user.id}", {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
    end
    
    it "cannot delete himself/herself" do
      delete "/users/#{@admin_user.id}", {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
    end
  end
  
end
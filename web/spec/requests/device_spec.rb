require 'spec_helper'

describe "Device API" do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
  end
  
  it 'show status' do
    get "/device/status", { :format => 'json' }
#    expect(response).to be_fail
  end

end

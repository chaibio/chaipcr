require 'spec_helper'

describe "Wells API", type: :request do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
        
    @experiment = create_experiment_with_one_stage("test")
  end
  
  describe "#update" do
    it 'bulk' do
      params = {wells:[{well_num: 1, well_type:"positive_control", sample_name:"test1", notes:"test1notes", targets:["test1_1", "test1_2"]}, 
                       {well_num: 2, well_type:"standard", sample_name:"test2", notes:"test2notes", targets:["test2_1"]}]}
      
      put "/experiments/#{@experiment.id}/wells", params.to_json, http_headers
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json[0]["well"]["well_num"].should == 1
      json[1]["well"]["well_num"].should == 2
      
      #read all wells
      get "/experiments/#{@experiment.id}/wells", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      json[0]["well"]["well_num"].should == 1
      json[1]["well"]["well_num"].should == 2
    end
    
    it 'one well' do
      params = {well: {well_type:"positive_control", sample_name:"test1", notes:"test1notes", targets:["test1_1", "test1_2"]}} 
      put "/experiments/#{@experiment.id}/wells/1", params.to_json, http_headers
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["well"]["well_num"].should == 1
      json["well"]["sample_name"].should == "test1"
    end
    
    it 'one well that exists' do
      params = {well: {well_type:"positive_control", sample_name:"test1", notes:"test1notes", targets:["test1_1"]}} 
      put "/experiments/#{@experiment.id}/wells/2", params.to_json, http_headers
      expect(response).to be_success  
      params = {well: {sample_name:"test2", targets:["test1_1","test2_2"]}} 
      put "/experiments/#{@experiment.id}/wells/2", params.to_json, http_headers
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["well"]["well_num"].should == 2
      json["well"]["well_type"].should == "positive_control"
      json["well"]["sample_name"].should == "test2"
      json["well"]["targets"][0].should == "test1_1"
      json["well"]["targets"][1].should == "test2_2"
    end
  end
  
  describe "#destroy" do
    it 'one well' do
      params = {well: {well_type:"positive_control", sample_name:"test1", notes:"test1notes", targets:["test1_1", "test1_2"]}} 
      put "/experiments/#{@experiment.id}/wells/1", params.to_json, http_headers
      expect(response).to be_success            # test for the 200 status-code
      delete "/experiments/#{@experiment.id}/wells/1", { :format => 'json' }
      expect(response).to be_success 
    end
  end
end


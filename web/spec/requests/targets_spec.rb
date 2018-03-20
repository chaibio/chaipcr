require 'spec_helper'

describe "Targets API", type: :request do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
        
    @experiment = create_experiment_with_one_stage("test")
    
    post "/experiments/#{@experiment.id}/targets", {name: "target1", channel: 1}.to_json, http_headers
    expect(response).to be_success  
    json = JSON.parse(response.body)
    @target1 = Target.find_by_id(json["target"]["id"])
    
    post "/experiments/#{@experiment.id}/targets", {name: "target2", channel: 2}.to_json, http_headers
    expect(response).to be_success  
    json = JSON.parse(response.body)
    @target2 = Target.find_by_id(json["target"]["id"])
  end
  
  describe "#all" do
    it 'targets' do
      post "/targets/#{@target1.id}/links", {wells:[{well_num: 1, well_type: "sample"}]}.to_json, http_headers
      expect(response).to be_success
      post "/targets/#{@target2.id}/links", {wells:[{well_num: 1, well_type: "sample"}]}.to_json, http_headers
      expect(response).to be_success
      get "/experiments/#{@experiment.id}/targets", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json[0]["target"]["targets_wells"].length).to eq(1)
      expect(json[1]["target"]["targets_wells"].length).to eq(1)
    end
  end
  
  describe "#create" do    
    it 'target with no channel' do
      post "/experiments/#{@experiment.id}/targets", {name: "target3"}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
  end
  
  describe "#update" do
    it 'target name' do
      put "/targets/#{@target1.id}", {name: "target3"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["target"]["name"]).to eq("target3")
    end
    
    it 'target invalid channel' do
      put "/targets/#{@target1.id}", {channel: 3}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
    
    it 'invalid target id' do
      put "/targets/#{@target2.id+1}", {name: "target3"}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["errors"]).not_to be_nil
    end
  end
  
  describe "#destroy" do
    it 'target' do
      delete "/targets/#{@target1.id}", { :format => 'json' }
      expect(response).to be_success
    end
    
    it 'invalid target id' do
      delete "/targets/#{@target1.id}", { :format => 'json' }
      expect(response).to be_success
      delete "/targets/#{@target1.id}", { :format => 'json' }
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["errors"]).not_to be_nil
    end
  end
  
  describe "#link" do  
    it 'standard well requires concentration' do
      post "/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "standard"}]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
    
    it 'well type not exist' do
      post "/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "abc"}]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
    
    it 'add another target with the same channel in the well' do
      post "/targets/#{@target2.id}/links", {wells:[{well_num: 2, well_type: "sample"}]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets", {name: "target3", channel: 2}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/targets/#{json["target"]["id"]}/links", {wells:[{well_num: 2, well_type: "sample"}]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
      
    it 'one well twice' do
      post "/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "positive_control"}]}.to_json, http_headers
      expect(response).to be_success
      post "/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "sample"}]}.to_json, http_headers
      expect(response).to be_success #update the row
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"].length).to eq(1)
      expect(json["target"]["targets_wells"][0]["well_type"]).to eq("sample")
    end
    
    it 'multiple wells' do
      post "/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "positive_control"}, {well_num: 3, well_type: "sample"}]}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"].length).to eq(2)
    end
  end
  
  describe "#unlink" do
    it 'existed well' do
      post "/targets/#{@target1.id}/links", {wells:[{well_num: 1, well_type: "sample"}]}.to_json, http_headers
      expect(response).to be_success  
      post "/targets/#{@target1.id}/unlinks", {wells: [1]}.to_json, http_headers
      expect(response).to be_success  
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"].length).to eq(0)
    end
  end

end
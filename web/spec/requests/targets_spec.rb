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
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 1}]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets/#{@target2.id}/links", {wells:[{well_num: 1}]}.to_json, http_headers
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
      put "/targets/#{@target1.id}", {name: "target3", channel: 2}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["target"]["name"]).to eq("target3")
      expect(json["target"]["channel"]).to eq(2)
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
    
    it 'target channel disallowed if it links to a well' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2}]}.to_json, http_headers
      expect(response).to be_success
      put "/targets/#{@target1.id}", {channel: 2}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
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
    it 'well incrementally' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2}]}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"][0]["well_num"]).to eq(2)
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "standard"}]}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"][0]["well_num"]).to eq(2)
      expect(json["target"]["targets_wells"][0]["well_type"]).to eq("standard")
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2, concentration: 1}]}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"].length).to eq(1)
      expect(json["target"]["targets_wells"][0]["well_num"]).to eq(2)
      expect(json["target"]["targets_wells"][0]["well_type"]).to eq("standard")
      expect(json["target"]["targets_wells"][0]["concentration"]).not_to be_nil
    end
          
    it 'one well replace well_type' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "positive_control"}]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "unknown"}]}.to_json, http_headers
      expect(response).to be_success #update the row
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"].length).to eq(1)
      expect(json["target"]["targets_wells"][0]["well_type"]).to eq("unknown")
    end
    
    it 'multiple wells' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "positive_control"}, {well_num: 3, well_type: "unknown"}]}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"].length).to eq(2)
    end
    
    it 'another target with the same channel in the well' do
      post "/experiments/#{@experiment.id}/targets/#{@target2.id}/links", {wells:[2, 3]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets", {name: "target3", channel: 2}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/experiments/#{@experiment.id}/targets/#{json["target"]["id"]}/links", {wells:[{well_num: 2, well_type: "positive_control"}]}.to_json, http_headers
      expect(response).to be_success
      get "/experiments/#{@experiment.id}/targets", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[1]["target"]["targets_wells"].length).to eq(1) #for target2
      expect(json[1]["target"]["targets_wells"][0]["well_num"]).to eq(3)
      expect(json[2]["target"]["targets_wells"].length).to eq(1) #for target3
      expect(json[2]["target"]["targets_wells"][0]["well_num"]).to eq(2)
    end
    
    it 'well type not exist' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "abc"}]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
    
    it 'target doesnot belong disallowed' do
      @experiment = create_experiment_with_one_stage("test1")
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[1]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
  end
  
  describe "#unlink" do
    it 'existed well' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success  
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/unlinks", {wells: [1]}.to_json, http_headers
      expect(response).to be_success  
      json = JSON.parse(response.body)
      expect(json["target"]["targets_wells"].length).to eq(0)
    end
  end
  
  describe "#import" do
    before(:each) do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 16}]}.to_json, http_headers
      post "/experiments/#{@experiment.id}/targets/#{@target2.id}/links", {wells:[{well_num: 16}]}.to_json, http_headers
      @experiment_import = @experiment
      @experiment = create_experiment_with_one_stage("test1")
      @experiment.targets_well_layout_id = @experiment_import.well_layout.id
      @experiment.save
    end
    
    it 'targets' do
      get "/experiments/#{@experiment.id}/targets", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json[0]["target"]["imported"]).to eq(true)
      expect(json[0]["target"]["targets_wells"].length).to eq(0)
      expect(json[1]["target"]["imported"]).to eq(true)
      expect(json[1]["target"]["targets_wells"].length).to eq(0)
    end
    
    it 'targets with new target' do
      post "/experiments/#{@experiment.id}/targets", {name: "target3", channel: 2}.to_json, http_headers
      expect(response).to be_success
      get "/experiments/#{@experiment.id}/targets", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json[0]["target"]["imported"]).to eq(true)
      expect(json[1]["target"]["imported"]).to eq(true)
      expect(json[2]["target"]["imported"]).to eq(false)
    end
    
    it 'link imported targets' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[1, 2]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets/#{@target2.id}/links", {wells:[2, 3, 4]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets", {name: "target3", channel: 2}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/experiments/#{@experiment.id}/targets/#{json["target"]["id"]}/links", {wells:[4]}.to_json, http_headers
      expect(response).to be_success
      get "/experiments/#{@experiment.id}/targets", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json[0]["target"]["imported"]).to eq(true)
      expect(json[0]["target"]["targets_wells"].length).to eq(2)
      expect(json[1]["target"]["imported"]).to eq(true)
      expect(json[1]["target"]["targets_wells"].length).to eq(2)
      expect(json[2]["target"]["imported"]).to eq(false)
      expect(json[2]["target"]["targets_wells"].length).to eq(1)
      
      get "/experiments/#{@experiment.id}/well_layout", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]["targets"].length).to eq(1)
      expect(json[0]["targets"][0]["name"]).to eq("target1")
      expect(json[0]["targets"][0]["imported"]).to eq(true)
      expect(json[1]["targets"].length).to eq(2)
      expect(json[2]["targets"].length).to eq(1)
      expect(json[2]["targets"][0]["name"]).to eq("target2")
      expect(json[2]["targets"][0]["imported"]).to eq(true)
      expect(json[3]["targets"].length).to eq(1)
      expect(json[3]["targets"][0]["name"]).to eq("target3")
      expect(json[3]["targets"][0]["imported"]).to eq(false)
      expect(json[15]["targets"]).to be_nil
    end
    
    it 'link imported targets with well_type standard disallowed' do
      post "/experiments/#{@experiment.id}/targets/#{@target1.id}/links", {wells:[{well_num: 2, well_type: "standard"}]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["target"]["errors"]).not_to be_nil
    end
    
  end

end
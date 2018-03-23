require 'spec_helper'

describe "Experiments API", type: :request do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
    
    Setting.where(:id=>1).update_all(:time_valid=>true)
  end
  
  it 'create experiment' do
    params = { experiment: {name: "test"} }
    post "/experiments", params.to_json, http_headers
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["type"].should == "user"
    expect(json["experiment"]["protocol"]["stages"].size).to eq(2)
    json["experiment"]["run_at"].should be_nil
  end
  
  it 'create experiment with guid' do
    params = { experiment: {name: "Thermal Performance Diagnostic", guid: "thermal_performance_diagnostic"} }
    post "/experiments", params.to_json, http_headers
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "Thermal Performance Diagnostic"
    json["experiment"]["type"].should == "diagnostic"
    expect(json["experiment"]["protocol"]["stages"].size).to eq(1)
    json["experiment"]["run_at"].should be_nil
  end
  
  it 'create experiment with customized protocol' do
    params = { experiment: {name: "test", protocol: {lid_temperature:110, stages:[
                      {stage:{stage_type:"holding",steps:[{step:{temperature:95,hold_time:180}}]}}, 
                      {stage:{stage_type:"cycling"}},
                      {stage:{stage_type:"cycling"}},
                      {stage:{stage_type:"holding",steps:[{step:{temperature:4,hold_time:0}}]}}]}} }
    post "/experiments", params.to_json, http_headers
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["type"].should == "user"
    expect(json["experiment"]["protocol"]["stages"].size).to eq(4)
    json["experiment"]["run_at"].should be_nil
  end
  
  it 'show experiment' do
    experiment = create_experiment("test")
    get "/experiments/#{experiment.id}", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
  end
  
  it  'delete experiment' do
    experiment = create_experiment("test")
    delete "/experiments/#{experiment.id}", http_headers
    expect(response).to be_success
  end
  
  it "delete not allowed in the middle of running" do
    experiment = create_experiment("test")
    experiment.started_at = Time.now
    experiment.save
    delete "/experiments/#{experiment.id}", http_headers
    expect(response.response_code).to eq(422)
  end
  
  it "list experiments with no experiment" do
    get "/experiments", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json.should be_empty
  end
  
  it "list experiments with two experiments" do
    experiment = create_experiment("test1")
    experiment = create_experiment("test2")
    get "/experiments", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json.length.should eq(2)
  end
  
  it "set time_valid to false" do
    Setting.where(:id=>1).update_all(:time_valid=>false)
    params = { experiment: {name: "test"} }
    post "/experiments", params.to_json, http_headers
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["time_valid"].should == false
  end
  
  it "set calibration_id 1 for thermal consistency experiment" do
    params = { experiment: {name: "test", guid: "thermal_consistency"} }
    post "/experiments", params.to_json, http_headers
    expect(response).to be_success  
    json = JSON.parse(response.body)
    experiment = Experiment.find_by_id(json["experiment"]["id"])
    experiment.calibration_id.should == 1
  end
  
  it  'edit experiment name' do
    experiment = create_experiment("test")
    params = {experiment: {name: "test1"}}
    put "/experiments/#{experiment.id}", params.to_json, http_headers
    expect(response).to be_success 
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test1"
  end
  
  describe "check editable" do
    it "name editable if experiment has been run" do
      experiment = create_experiment("test1")
      experiment.started_at = Time.now
      experiment.save
      params = {experiment: {name: "test2"}}
      put "/experiments/#{experiment.id}", params.to_json, http_headers
      expect(response).to be_success
    end
  end
  
  describe "copy" do
    it 'experiment' do
      experiment = create_experiment("test")
      post "/experiments/#{experiment.id}/copy", { :format => 'json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["experiment"]["name"].should == "Copy of test"
    end
  
    it 'experiment with well_layout' do
      experiment = create_experiment("test")
      post "/experiments/#{experiment.id}/samples", {name: "sample1"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/experiments/#{experiment.id}/samples/#{json["sample"]["id"]}/links", {wells:[1]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{experiment.id}/targets", {name: "target1", channel: 1}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/experiments/#{experiment.id}/targets/#{json["target"]["id"]}/links", {wells:[2]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{experiment.id}/copy", { :format => 'json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["experiment"]["name"].should == "Copy of test"
      get "/experiments/#{json["experiment"]["id"]}/well_layout", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]["samples"]).not_to be_nil
      expect(json[0]["targets"]).to be_nil
      expect(json[1]["samples"]).to be_nil
      expect(json[1]["targets"]).not_to be_nil
    end
  end
    
  describe "well layout" do
    before(:each) do
      @experiment = create_experiment("test1")
      @experiment.started_at = Time.now
      @experiment.save
    end
    
    it "show empty layout" do
      get "/experiments/#{@experiment.id}/well_layout", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(0)
    end
    
    it "show empty layout with no well layout" do
      @experiment.well_layout.destroy
      get "/experiments/#{@experiment.id}/well_layout", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(0)
    end
    
    it "show" do
      post "/experiments/#{@experiment.id}/samples", {name: "sample1"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/experiments/#{@experiment.id}/samples/#{json["sample"]["id"]}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/samples", {name: "sample2"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/experiments/#{@experiment.id}/samples/#{json["sample"]["id"]}/links", {wells: [2]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets", {name: "target1", channel: 1}.to_json, http_headers
      expect(response).to be_success  
      json = JSON.parse(response.body)
      post "/experiments/#{@experiment.id}/targets/#{json["target"]["id"]}/links", {wells:[{well_num: 1, well_type: "unknown"}]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/targets", {name: "target2", channel: 2}.to_json, http_headers
      expect(response).to be_success  
      json = JSON.parse(response.body)
      post "/experiments/#{@experiment.id}/targets/#{json["target"]["id"]}/links", {wells:[{well_num: 3, well_type: "positive_control"}]}.to_json, http_headers
      expect(response).to be_success
      get "/experiments/#{@experiment.id}/well_layout", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]["samples"]).not_to be_nil
      expect(json[0]["targets"]).not_to be_nil
      expect(json[1]["samples"]).not_to be_nil
      expect(json[1]["targets"]).to be_nil
      expect(json[2]["samples"]).to be_nil
      expect(json[2]["targets"]).not_to be_nil
    end
    
    it "update standard after target is linked is disallowed" do
      @experiment_standard = @experiment
      @experiment = create_experiment_with_one_stage("test1")
      put "/experiments/#{@experiment.id}", {experiment: {standard_experiment_id: @experiment_standard.id}}.to_json, http_headers
      post "/experiments/#{@experiment_standard.id}/targets", {name: "target2", channel: 2}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      post "/experiments/#{@experiment.id}/targets/#{json["target"]["id"]}/links", {wells:[{well_num: 1}]}.to_json, http_headers
      expect(response).to be_success
      @new_experiment_standard = create_experiment_with_one_stage("test1")
      put "/experiments/#{@experiment.id}", {experiment: {standard_experiment_id: @new_experiment_standard.id}}.to_json, http_headers
      expect(response.response_code).to eq(422)
    end
    
  end
end

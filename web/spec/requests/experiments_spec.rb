require 'spec_helper'

describe "Experiments API", type: :request do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
    
    Setting.where(:id=>1).update_all(:time_valid=>true)
  end
  
  it 'create experiment' do
    params = { experiment: {name: "test"} }
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["type"].should == "user"
    expect(json["experiment"]["protocol"]["stages"].size).to eq(2)
    json["experiment"]["run_at"].should be_nil
  end
  
  it 'create experiment with guid' do
    params = { experiment: {name: "Thermal Performance Diagnostic", guid: "thermal_performance_diagnostic"} }
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
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
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["type"].should == "user"
    expect(json["experiment"]["protocol"]["stages"].size).to eq(4)
    json["experiment"]["run_at"].should be_nil
  end
  
  it 'create experiment with diagnostic protocol' do
  end
  
  it 'show experiment' do
    experiment = create_experiment("test")
    get "/experiments/#{experiment.id}", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
  end
  
  it 'copy experiment' do
    experiment = create_experiment("test")
    post "/experiments/#{experiment.id}/copy", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "Copy of test"
  end
  
  it  'edit experiment name' do
    experiment = create_experiment("test")
    params = {experiment: {name: "test1"}}
    put "/experiments/#{experiment.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success 
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test1"
  end
  
  it  'delete experiment' do
    experiment = create_experiment("test")
    delete "/experiments/#{experiment.id}", {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success
  end
  
  it "delete not allowed in the middle of running" do
    experiment = create_experiment("test")
    experiment.started_at = Time.now
    experiment.save
    delete "/experiments/#{experiment.id}", {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    response.response_code.should == 422
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
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["time_valid"].should == false
  end
  
  it "set calibration_id 1 for thermal consistency experiment" do
    params = { experiment: {name: "test", guid: "thermal_consistency"} }
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success  
    json = JSON.parse(response.body)
    experiment = Experiment.find_by_id(json["experiment"]["id"])
    experiment.calibration_id.should == 1
  end
  
  describe "check editable" do
    it "name editable if experiment has been run" do
      experiment = create_experiment("test1")
      experiment.started_at = Time.now
      experiment.save
      params = {experiment: {name: "test2"}}
      put "/experiments/#{experiment.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
    end
  end
end

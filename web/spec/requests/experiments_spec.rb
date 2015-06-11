require 'spec_helper'

describe "Experiments API" do
  it 'create experiment' do
    params = { experiment: {name: "test"} }
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["type"].should == "user"
    json["experiment"]["protocol"]["stages"].should have(3).items
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
    json["experiment"]["protocol"]["stages"].should have(4).items
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
  
  it  'edit experiment name' do
    experiment = create_experiment("test")
    params = {experiment: {name: "test1"}}
    put "/experiments/#{experiment.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success 
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test1"
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
  
  it "list all temperature data" do
    experiment = create_experiment("test1")
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=1000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq(totallength)
  end
  
  it "list temperature data every 2 second" do
    experiment = create_experiment("test1")
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=2000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+1)/2)
  end
  
  it "list temperature data every 3 second" do
    experiment = create_experiment("test1")
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=3000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+2)/3)
  end
  
  it "list fluorescence data" do    
    experiment = create_experiment("test1")
    create_fluorescence_data(experiment)
    get "/experiments/#{experiment.id}/fluorescence_data", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json[0]["fluorescence_datum"]["fluorescence_value"].should == 75
    json[1]["fluorescence_datum"]["fluorescence_value"].should == 50
    json[2]["fluorescence_datum"]["fluorescence_value"].should == 30
    json[3]["fluorescence_datum"]["fluorescence_value"].should == 15
  end
  
  it "export" do
    experiment = create_experiment("test1")
    create_fluorescence_data(experiment)
    get "/experiments/#{experiment.id}/export.zip", { :format => 'zip' }
    expect(response).to be_success
  end
  
  describe "check editable" do
    it "not editable if experiment definition is not editable" do
      experiment = Experiment.new
      experiment.experiment_definition = ExperimentDefinition.new(:name=>"diagnostic", :experiment_type=>ExperimentDefinition::TYPE_DIAGONOSTIC)
      experiment.save
      params = {experiment: {name: "test1"}}
      put "/experiments/#{experiment.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
    end
  end
end

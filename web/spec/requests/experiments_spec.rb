require 'spec_helper'

describe "Experiments API" do
  it 'create experiment' do
    params = { experiment: {name: "test"} }
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
    json["experiment"]["qpcr"].should be_true
    json["experiment"]["run_at"].should be_nil
  end
  
  it 'show experiment' do
    experiment = Experiment.create(:name=>"test")
    get "/experiments/#{experiment.id}", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json["experiment"]["name"].should == "test"
  end
  
  it "list experiments with no experiment" do
    get "/experiments", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json.should be_empty
  end
  
  it "list experiments with two experiments" do
    experiment = Experiment.create(:name=>"test1")
    experiment = Experiment.create(:name=>"test2")
    get "/experiments", { :format => 'json' }
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    json.length.should eq(2)
  end
  
  it "list all temperature data" do
    experiment = Experiment.create(:name=>"test1")
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=1000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq(totallength)
  end
  
  it "list temperature data every 2 second" do
    experiment = Experiment.create(:name=>"test1")
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=2000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+1)/2)
  end
  
  it "list temperature data every 3 second" do
    experiment = Experiment.create(:name=>"test1")
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=3000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+2)/3)
  end
  
  it "list fluorescence data" do    
    experiment = Experiment.create(:name=>"test1")
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
    experiment = Experiment.create(:name=>"test1")
    create_fluorescence_data(experiment)
    get "/experiments/#{experiment.id}/export.zip", { :format => 'zip' }
    expect(response).to be_success
  end
end

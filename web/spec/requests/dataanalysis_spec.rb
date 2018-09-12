require 'spec_helper'

describe "DataAnalysis API", type: :request do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
    @experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(@experiment)
  end
  
  def amplification_data_length(num_cycles)
    num_cycles*16*2+1
  end
  
  it "all temperature data" do
    totallength = @experiment.temperature_logs.length
    get "/experiments/#{@experiment.id}/temperature_data?starttime=0&resolution=1000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq(totallength)
  end
  
  it "temperature data every 2 second" do
    totallength = @experiment.temperature_logs.length
    get "/experiments/#{@experiment.id}/temperature_data?starttime=0&resolution=2000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+1)/2)
  end
  
  it "temperature data every 3 second" do
    totallength = @experiment.temperature_logs.length
    get "/experiments/#{@experiment.id}/temperature_data?starttime=0&resolution=3000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+2)/3)
  end
  
  it "amplification data with async calls" do
    create_fluorescence_data(@experiment, 10)
    expect_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |obj, experiment, stage_id, calibration_id|
      experiment.id.should == @experiment.id
      calibration_id.should == @experiment.calibration_id
      sleep(2)
      [[], []]
    end
    
    #data processing
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    print response.body
    response.response_code.should == 202
    sleep(2)

    #data available
    stage, step = create_amplification_and_cq_data(@experiment, 10)
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
    response.etag.should_not be_nil
    json = JSON.parse(response.body)
    json["partial"].should eq(true)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == 11 #include header
    json["steps"][0]["amplification_data"][0].join(",").should eq("channel,well_num,cycle_num,background_subtracted_value,baseline_subtracted_value,dr1_pred,dr2_pred")
    json["steps"][0]["cq"].should_not be_nil

    #data cached
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json'}, { "If-None-Match" => response.etag }
    response.response_code.should == 304
    #response.body should be_nil
  end
  
  it "amplification data with more data" do
    create_fluorescence_data(@experiment, 10)
    
    expect_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |obj, experiment, stage_id, calibration_id|
      experiment.id.should == @experiment.id
      calibration_id.should == @experiment.calibration_id
      sleep(1)
      [[], []]
    end
      
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    
    sleep(2)
    
    stage, step = create_amplification_and_cq_data(@experiment, 10)
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
    json = JSON.parse(response.body)
    json["partial"].should eq(true)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == 11 #include header
    
    #more data are added
    create_fluorescence_data(@experiment, 10, 10)
    stage, step = create_amplification_and_cq_data(@experiment, 10, 10)
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    #return data for the 20 rows
    response.response_code.should == 200
    json = JSON.parse(response.body)
    json["partial"].should eq(true)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == 21 #include header
  
    #add all the data for this stage
    create_fluorescence_data(@experiment, 0, 20)
    stage, step = create_amplification_and_cq_data(@experiment, 0, 20)  
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
    json = JSON.parse(response.body)
    json["partial"].should eq(false)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == amplification_data_length(stage.num_cycles)  
  end
  
  it "amplification data raw" do
    create_fluorescence_data(@experiment, 0)
    get "/experiments/#{@experiment.id}/amplification_data?raw=true", { :format => 'json' }
    expect(response).to be_success
    response.etag.should_not be_nil
    stage = Stage.collect_data(@experiment.experiment_definition_id).first
    step = Step.collect_data(stage.id).first
    json = JSON.parse(response.body)
    json["partial"].should eq(false)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == amplification_data_length(stage.num_cycles) 
    json["steps"][0]["amplification_data"][0].join(",").should eq("channel,well_num,cycle_num,fluorescence_value")
    json["steps"][0]["cq"].should be_nil
  
    #data cached  
    get "/experiments/#{@experiment.id}/amplification_data?raw=true", { :format => 'json'}, { "If-None-Match" => response.etag }
    response.response_code.should == 304
  end
  
  it "amplification data for error" do
    create_fluorescence_data(@experiment, 10)
    error = "test error"
    expect_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |obj, experiment, stage_id, calibration_id|
      raise ({errors: error}.to_json)
    end
    
    #request submitted
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    
    #error returns
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 500
    json = JSON.parse(response.body)
    json["errors"].should eq(error)
    
    #resubmit request
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
  end
  
  it "amplification data for aborted" do
    create_fluorescence_data(@experiment, 10)
    finish_experiment(@experiment)
    stage, step = create_amplification_and_cq_data(@experiment, 10)
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
    json = JSON.parse(response.body)
    json["partial"].should eq(false)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == 11 #include header
  end
  
  it "amplification data for two experiments" do
    create_fluorescence_data(@experiment, 10)
    expect_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |obj, experiment, stage_id, calibration_id|
      experiment.id.should == @experiment.id
      calibration_id.should == @experiment.calibration_id
      sleep(2)
      [[], []]
    end
    
    #data processing
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    
    #2nd experiment
    experiment2 = create_experiment_for_data_analysis("dataanalysis2")
    run_experiment(experiment2)
    create_fluorescence_data(experiment2, 10)
        
    get "/experiments/#{experiment2.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 503
    
    sleep(2)

    #data available
    stage, step = create_amplification_and_cq_data(@experiment, 10)
    get "/experiments/#{@experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
  end  
  
=begin    
  it "export" do
    experiment = create_experiment("test1")
    run_experiment(experiment)
    create_fluorescence_data(experiment, 0)
    get "/experiments/#{experiment.id}/export", { :format => 'zip' }
    expect(response).to be_success
  end
=end
end
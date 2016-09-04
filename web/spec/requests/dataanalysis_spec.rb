require 'spec_helper'

describe "DataAnalysis API" do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }    
  end
  
  def amplification_data_results
    sleep(10)
  end
  
  it "list all temperature data" do
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=1000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq(totallength)
  end
  
  it "list temperature data every 2 second" do
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=2000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+1)/2)
  end
  
  it "list temperature data every 3 second" do
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    totallength = experiment.temperature_logs.length
    get "/experiments/#{experiment.id}/temperature_data?starttime=0&resolution=3000", { :format => 'json' }
    expect(response).to be_success
    json = JSON.parse(response.body)
    json.length.should eq((totallength+2)/3)
  end
  
  it "list amplification data with async calls" do       
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    create_fluorescence_data(experiment, 10)
    allow_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |experiment_id, stage_id, calibration_id|
      experiment_id.should == experiment.id
      calibration_id.should == experiment.calibration_id
      sleep(1)
      [[], []]
    end
    
    #data processing
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    sleep(2)

    #data available
    stage, step = create_amplification_and_cq_data(experiment, 10)
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
    response.etag.should_not be_nil
    json = JSON.parse(response.body)
    json["partial"].should eq(true)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == 11 #include header
    json["steps"][0]["amplification_data"][0].join(",").should eq("channel,well_num,cycle_num,background_subtracted_value,baseline_subtracted_value")
    json["steps"][0]["cq"].should_not be_nil

    #data cached
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json'}, { "If-None-Match" => response.etag }
    response.response_code.should == 304
    #response.body should be_nil
  end

  it "list amplification data raw" do    
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    create_fluorescence_data(experiment, 0)
    get "/experiments/#{experiment.id}/amplification_data?raw=true&background=false&baseline=false&cq=false", { :format => 'json' }
    expect(response).to be_success
    response.etag.should_not be_nil
    stage = Stage.collect_data(experiment.experiment_definition_id).first
    step = Step.collect_data(stage.id).first
    json = JSON.parse(response.body)
    json["partial"].should eq(false)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == stage.num_cycles*16*2+1 #include header
    json["steps"][0]["amplification_data"][0].join(",").should eq("channel,well_num,cycle_num,fluorescence_value")
    json["steps"][0]["cq"].should be_nil
  
    #data cached  
    get "/experiments/#{experiment.id}/amplification_data?raw=true&background=false&baseline=false&cq=false", { :format => 'json'}, { "If-None-Match" => response.etag }
    response.response_code.should == 304
  end
  
  it "list amplification data for error" do       
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    create_fluorescence_data(experiment, 10)
    error = "test error"
    allow_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |experiment_id, stage_id, calibration_id|
      raise error
    end
    
    #request submitted
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    
    #error returns
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 500
    json = JSON.parse(response.body)
    json["errors"].should eq(error)
    
    #resubmit request
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
  end
  
  it "list amplification data for two experiments" do
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    create_fluorescence_data(experiment, 10)
    allow_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |experiment_id, stage_id, calibration_id|
      experiment_id.should == experiment.id
      calibration_id.should == experiment.calibration_id
      sleep(1)
      [[], []]
    end
    
    #data processing
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    
    #2nd experiment
    experiment2 = create_experiment_for_data_analysis("dataanalysis2")
    run_experiment(experiment2)
    create_fluorescence_data(experiment2, 10)
        
    get "/experiments/#{experiment2.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 503
    
    sleep(2)

    #data available
    stage, step = create_amplification_and_cq_data(experiment, 10)
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
  end  
     
  it "list melt curve data with async calls" do       
    experiment = create_experiment_for_data_analysis("dataanalysis")
    run_experiment(experiment)
    create_fluorescence_data(experiment, 10)
    allow_any_instance_of(ExperimentsController).to receive(:calculate_amplification_data) do |experiment_id, stage_id, calibration_id|
      experiment_id.should == experiment.id
      calibration_id.should == experiment.calibration_id
      sleep(1)
      [[], []]
    end
    
    #data processing
    get "/experiments/#{experiment.id}/melt_curve_data", { :format => 'json' }
    response.response_code.should == 202
=begin
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 202
    sleep(2)

    #data available
    stage, step = create_amplification_and_cq_data(experiment, 10)
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json' }
    response.response_code.should == 200
    response.etag.should_not be_nil
    json = JSON.parse(response.body)
    json["partial"].should eq(true)
    json["total_cycles"].should eq(stage.num_cycles)
    json["steps"][0]["step_id"].should eq(step.id)
    json["steps"][0]["amplification_data"].length.should == 11 #include header
    json["steps"][0]["amplification_data"][0].join(",").should eq("channel,well_num,cycle_num,background_subtracted_value,baseline_subtracted_value")
    json["steps"][0]["cq"].should_not be_nil

    #data cached
    get "/experiments/#{experiment.id}/amplification_data", { :format => 'json'}, { "If-None-Match" => response.etag }
    response.response_code.should == 304
    #response.body should be_nil
=end
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
require 'rspec/expectations'
require 'csv'

RSpec::Matchers.define :be_same_step_as do |expected|
  match do |actual|
    actual.temperature == expected.temperature && actual.hold_time == expected.hold_time
  end
end

RSpec::Matchers.define :exist_in_database do
  match do |actual|
    actual.class.exists?(actual.id)
  end
end

RSpec::Matchers.define :be_contiguous_order_numbers do
  match do |objs|
    result = true
    objs.each_index do |i|
      if objs[i].order_number != i
        result = false
        break
      end
    end
    result
  end
  failure_message_for_should do |objs|
    "expected #{(0...objs.count).to_a} got #{objs.map{|obj| obj.order_number}}"
  end
end

module FactoryHelper
  def http_headers
    {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
  end
  
  def hold_stage(protocol)
    Stage.create(:stage_type=>Stage::TYPE_HOLD, :protocol_id=>protocol.id)
  end
  
  def cycle_stage(protocol)
    Stage.create(:stage_type=>Stage::TYPE_CYCLE, :protocol_id=>protocol.id)
  end
  
  def meltcurve_stage(protocol)
    Stage.create(:stage_type=>Stage::TYPE_MELTCURVE, :protocol_id=>protocol.id)
  end
  
  def create_experiment(name)
    experiment = Experiment.new(:name=>name)
    experiment.experiment_definition = ExperimentDefinition.new(:experiment_type=>ExperimentDefinition::TYPE_USER_DEFINED)
    experiment.save
    experiment
  end
  
  def run_experiment(experiment)
    experiment.calibration_id = 1
    experiment.started_at = 10.seconds.ago
    experiment.save
  end
  
  def finish_experiment(experiment)
    experiment.completed_at = Time.new
    experiment.save
  end
  
  def create_experiment_with_one_stage(name)
    params = { experiment: {name: name, protocol: {lid_temperature:110, stages:[
                      {stage:{stage_type:"holding",steps:[{step:{temperature:95,hold_time:180}}]}}, 
                      ]}} }
    post "/experiments", params.to_json, http_headers
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    return Experiment.find_by_id(json["experiment"]["id"])
  end
  
  def create_admin_user
    User.create(:name=>"admin", :email=>"admin@pcr.com", :password=>"changeme", :password_confirmation=>"changeme", :role=>"admin")
  end
  
  def create_test_user
    User.create(:name=>"test", :email=>"test@test.com", :password=>"changeme", :password_confirmation=>"changeme")
  end
  
  def create_test_user2
    User.create(:name=>"test2", :email=>"test2@test.com", :password=>"changeme", :password_confirmation=>"changeme")
  end
  
  def create_experiment_for_data_analysis(name)
    params = { experiment: {name: name, protocol: {lid_temperature:110, stages:[
                      {stage:{stage_type:Stage::TYPE_HOLD,steps:[{step:{temperature:95,hold_time:120}}]}},
                      {stage:{stage_type:Stage::TYPE_CYCLE,num_cycles:45,steps:[{step:{temperature:95,hold_time:15}},{step:{temperature:60,hold_time:60,collect_data:1}}]}},
                      {stage:{stage_type:Stage::TYPE_MELTCURVE}}
                      ]}} }
    post "/experiments", params.to_json, http_headers
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    return Experiment.find_by_id(json["experiment"]["id"])
  end
  
  def create_fluorescence_data(experiment, num_rows=0, start_row=0)
    first_stage_collect_data = Stage.collect_data(experiment.experiment_definition_id).first
    step = Step.collect_data(first_stage_collect_data.id).first
    rows = 0
    CSV.foreach("spec/fixtures/amplification.csv") do |row|
      if rows > start_row
        FluorescenceDatum.create(:channel=>row[3], :well_num=>row[4].to_i-1, :cycle_num=>row[5], :fluorescence_value=>row[2], :experiment_id=>experiment.id, :step_id=>step.id)
      end
      rows += 1
      break if (num_rows > 0 && rows > num_rows+start_row)
    end
  end
  
  def create_amplification_and_cq_data(experiment, num_rows=0, start_row=0)
    first_stage_collect_data = Stage.collect_data(experiment.experiment_definition_id).first
    step = Step.collect_data(first_stage_collect_data.id).first
    rows = 0
    CSV.foreach("spec/fixtures/amplification.csv") do |row|
      if rows > start_row
        AmplificationDatum.create(:channel=>row[3], :well_num=>row[4], :cycle_num=>row[5], :baseline_subtracted_value=>row[0], :background_subtracted_value=>row[1], :experiment_id=>experiment.id, :sub_id=>step.id, :sub_type=>"step", :stage_id=>first_stage_collect_data.id)
      end
      rows += 1
      break if (num_rows > 0 && rows > num_rows+start_row)
    end
    
    if start_row == 0
      rows = 0
      CSV.foreach("spec/fixtures/cq.csv") do |row|
        if rows > 0
          AmplificationCurve.create(:channel=>row[0], :well_num=>row[1], :ct=>row[2], :experiment_id=>experiment.id, :stage_id=>first_stage_collect_data.id)
        end
        rows += 1
      end
    end
    
    [first_stage_collect_data, step]
  end
  
end
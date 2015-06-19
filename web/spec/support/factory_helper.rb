require 'rspec/expectations'

RSpec::Matchers.define :be_same_step_as do |expected|
  match do |actual|
    actual.temperature == expected.temperature
    actual.hold_time == expected.hold_time
  end
end

RSpec::Matchers.define :exist_in_database do
  match do |actual|
    actual.class.exists?(actual.id)
  end
end

module FactoryHelper
  def hold_stage(protocol)
    Stage.create(:stage_type=>Stage::TYPE_HOLD, :protocol_id=>protocol.id)
  end
  
  def cycle_stage(protocol)
    Stage.create(:stage_type=>Stage::TYPE_CYCLE, :protocol_id=>protocol.id)
  end
  
  def create_experiment(name)
    experiment = Experiment.new
    experiment.experiment_definition = ExperimentDefinition.new(:name=>name, :experiment_type=>ExperimentDefinition::TYPE_USER_DEFINED)
    experiment.save
    experiment
  end
  
  def create_experiment_with_one_stage(name)
    params = { experiment: {name: name, protocol: {lid_temperature:110, stages:[
                      {stage:{stage_type:"holding",steps:[{step:{temperature:95,hold_time:180}}]}}, 
                      ]}} }
    post "/experiments", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
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
  
  def create_fluorescence_data(experiment)
    FluorescenceDatum.create(:step_id=>1, :well_num=>0, :cycle_num=>1, :experiment_id=>experiment.id, :fluorescence_value=>50)
    FluorescenceDatum.create(:step_id=>2, :well_num=>0, :cycle_num=>1, :experiment_id=>experiment.id, :fluorescence_value=>100)
    FluorescenceDatum.create(:step_id=>1, :well_num=>1, :cycle_num=>2, :experiment_id=>experiment.id, :fluorescence_value=>10)
    FluorescenceDatum.create(:step_id=>2, :well_num=>1, :cycle_num=>2, :experiment_id=>experiment.id, :fluorescence_value=>20)
    FluorescenceDatum.create(:step_id=>1, :well_num=>1, :cycle_num=>1, :experiment_id=>experiment.id, :fluorescence_value=>30)
    FluorescenceDatum.create(:step_id=>1, :well_num=>0, :cycle_num=>2, :experiment_id=>experiment.id, :fluorescence_value=>20)
    FluorescenceDatum.create(:step_id=>2, :well_num=>0, :cycle_num=>2, :experiment_id=>experiment.id, :fluorescence_value=>40)
    FluorescenceDatum.create(:step_id=>2, :well_num=>1, :cycle_num=>1, :experiment_id=>experiment.id, :fluorescence_value=>70)
  end
  
end
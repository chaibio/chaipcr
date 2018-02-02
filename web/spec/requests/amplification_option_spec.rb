require 'spec_helper'

describe "Amplification Option API", type: :request do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
        
    @experiment = create_experiment_with_one_stage("test")
  end
  
  describe "#show" do
    it 'default' do
      get "/experiments/#{@experiment.id}/amplification_option"
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["amplification_option"]["cq_method"].should == AmplificationOption::CQ_METHOD_CY0
      json["amplification_option"]["baseline_cycle_bounds"].should be_nil
    end
    
    it 'updated option' do
      params = {amplification_option: {min_fluorescence: 123, min_reliable_cycle: 3, min_d1: 21, min_d2: 45, baseline_cycle_bounds: [1,5]}} 
    
      put "/experiments/#{@experiment.id}/amplification_option", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      get "/experiments/#{@experiment.id}/amplification_option"
      expect(response).to be_success 
      json = JSON.parse(response.body)
      json["amplification_option"]["cq_method"].should == AmplificationOption::CQ_METHOD_CY0
      json["amplification_option"]["min_fluorescence"].should == 123
      json["amplification_option"]["min_reliable_cycle"].should == 3
      json["amplification_option"]["min_d1"].should == 21
      json["amplification_option"]["min_d2"].should == 45
      json["amplification_option"]["baseline_cycle_bounds"].should == [1,5]
    end
  end
  
  describe "#update" do
    it 'multiple times' do
      params = {amplification_option: {min_fluorescence: 123, baseline_cycle_bounds: [1,5]}} 
    
      put "/experiments/#{@experiment.id}/amplification_option", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["amplification_option"]["cq_method"].should == AmplificationOption::CQ_METHOD_CY0
      json["amplification_option"]["min_fluorescence"].should == 123
      json["amplification_option"]["baseline_cycle_bounds"].should == [1,5]
      
      params = {amplification_option: {min_fluorescence: nil}}
      put "/experiments/#{@experiment.id}/amplification_option", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["amplification_option"]["min_fluorescence"].should == AmplificationOption.new.min_fluorescence
      json["amplification_option"]["baseline_cycle_bounds"].should == [1,5]
      
      params = {amplification_option: {baseline_cycle_bounds: nil}} 
    
      put "/experiments/#{@experiment.id}/amplification_option", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["amplification_option"]["min_fluorescence"].should == AmplificationOption.new.min_fluorescence
      json["amplification_option"]["baseline_cycle_bounds"].should be_nil
    end
    
    it 'fails because of params check' do
      params = {amplification_option: {cq_method: "abc", min_fluorescence: -123}} 
      put "/experiments/#{@experiment.id}/amplification_option", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response.status).to eq(422)
      json = JSON.parse(response.body)
      json["amplification_option"]["errors"].length.should == 2      
    end
  end
  
end
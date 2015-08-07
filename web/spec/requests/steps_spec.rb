require 'spec_helper'

describe "Steps API" do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
        
    @experiment = create_experiment_with_one_stage("test")
    @stage = @experiment.experiment_definition.protocol.stages.first
  end
  
  describe "#create" do
    it 'first step' do
      post "/stages/#{@stage.id}/steps", {}, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["step"]["name"].should == "Step 1"
    end
    
    it 'last step' do
      params = { prev_id: @stage.steps.first.id }
      post "/stages/#{@stage.id}/steps", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["step"]["name"].should == "Step 2"
    end
  end
  
  describe "#destroy" do
    it 'last step in last stage' do
      delete "/steps/#{@stage.steps.first.id}", { :format => 'json' }
      response.response_code.should == 422
      json = JSON.parse(response.body)
      json["step"]["errors"].should_not be_nil
    end
  
    it "last step not in last stage" do
      new_stage = hold_stage(@stage.protocol)
      delete "/steps/#{@stage.steps.first.id}", { :format => 'json' }
      expect(response).to be_success
      json = JSON.parse(response.body)
      json["step"]["destroyed_stage_id"].should eq(@stage.id)
    end
  
    it "not last step" do
      new_step = Step.new
      @stage.steps << new_step
      delete "/steps/#{new_step.id}", { :format => 'json' }
      expect(response).to be_success
      json = JSON.parse(response.body)
      json["step"]["destroyed_stage_id"].should be_nil
    end
  end
  
  describe "#move" do
    it "step from one stage to another stage" do
      new_stage = cycle_stage(@stage.protocol)
      steps_count = new_stage.steps.count
      params = { stage_id: new_stage.id }
      post "/steps/#{@stage.steps.first.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      @experiment.experiment_definition.protocol.stages.count.should == 1
      @experiment.experiment_definition.protocol.stages.first.id.should == new_stage.id
      new_stage.steps.count.should == steps_count + 1
    end
    
    it "step to non-existent stage not allowed" do
      params = { stage_id: 212 }
      post "/steps/#{@stage.steps.first.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
    end
  end

  describe "check editable" do
    it "- not editable if experiment definition is not editable" do
      @experiment.experiment_definition = ExperimentDefinition.new(:name=>"diagnostic", :experiment_type=>ExperimentDefinition::TYPE_DIAGONOSTIC)
      @experiment.save
      post "/stages/#{@stage.id}/steps", {}, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
    end
    
    it "not editable if experiment is runned" do
      @experiment.update_attributes(:started_at=>Time.now)
      @experiment.save
      post "/stages/#{@stage.id}/steps", {}, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
    end
  end
  
end
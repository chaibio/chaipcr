require 'spec_helper'

describe "Steps API", type: :request do
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
      json["step"]["name"].should be_nil
      json["step"]["order_number"].should == 0
    end
    
    it 'last step' do
      params = { prev_id: @stage.steps.first.id }
      post "/stages/#{@stage.id}/steps", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success            # test for the 200 status-code
      json = JSON.parse(response.body)
      json["step"]["order_number"].should == 1
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
      @stage.steps.reload
      @stage.steps[0].id.should == new_step.id
      delete "/steps/#{new_step.id}", { :format => 'json' }
      expect(response).to be_success
      json = JSON.parse(response.body)
      json["step"]["destroyed_stage_id"].should be_nil
      @stage.steps.reload
      @stage.steps.should be_contiguous_order_numbers
    end
  end
  
  describe "#update" do
    it "step name" do
      params = { step: {name: "test"} }
      put "/steps/#{@stage.steps.first.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      json = JSON.parse(response.body)
      json["step"]["name"].should eq("test")
    end
    
    it "step name null" do
      params = { step: {name: ""} }
      put "/steps/#{@stage.steps.first.id}", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      json = JSON.parse(response.body)
      json["step"]["name"].should be_nil
    end
  end
  
  describe "#move" do
    it "step from back to front" do
      @stage = meltcurve_stage(@stage.protocol) #3 steps
      #add another step at the end
      movestep = @stage.steps.last
      @stage.steps << Step.new(:order_number=>movestep.order_number+1) #4 steps now
      params = { prev_id: @stage.steps.first.id}
      #move step 3 after step 1
      post "/steps/#{movestep.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      @stage.steps.reload
      @stage.steps.should be_contiguous_order_numbers
      @stage.steps[1].id.should == movestep.id
    end
    
    it "step from front to back" do
      @stage = meltcurve_stage(@stage.protocol) #3 steps
      #add another step at the end
      movestep = @stage.steps.first
      params = { prev_id: @stage.steps[1].id}
      #move step 1 after step 2
      post "/steps/#{movestep.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      @stage.steps.reload
      @stage.steps.should be_contiguous_order_numbers
      @stage.steps[1].id.should == movestep.id
    end
    
    it "step to the same position (not moved)" do
      @stage = meltcurve_stage(@stage.protocol) #3 steps
      movestep = @stage.steps[2]
      params = { prev_id: @stage.steps[1].id}
      post "/steps/#{movestep.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      @stage.steps.reload
      @stage.steps.should be_contiguous_order_numbers
      @stage.steps[2].id.should == movestep.id
    end
    
    it "step to non-existent prev_id" do
      @stage = meltcurve_stage(@stage.protocol) #3 steps
      #add another step at the end
      movestep = @stage.steps[2]
      params = { prev_id: 123}
      #move step 3 after step 1
      post "/steps/#{movestep.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      @stage.steps.reload
      @stage.steps.should be_contiguous_order_numbers
      @stage.steps[0].id.should == movestep.id
    end
    
    it "step from hold stage to cycle stage" do
      new_stage = cycle_stage(@stage.protocol)
      steps_count = new_stage.steps.count
      movestep = @stage.steps.first
      params = { stage_id: new_stage.id }
      post "/steps/#{movestep.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      @experiment.experiment_definition.protocol.stages.reload
      @experiment.experiment_definition.protocol.stages.count.should == 1 #hold stage should be deleted because the only step is moved
      @experiment.experiment_definition.protocol.stages.first.id.should == new_stage.id
      new_stage.steps.reload
      new_stage.steps.count.should == steps_count + 1
      new_stage.steps.should be_contiguous_order_numbers
      new_stage.steps[0].id.should == movestep.id
    end
    
    it "step from meltcurve stage to cycle stage" do
      @stage = meltcurve_stage(@stage.protocol)
      new_stage = cycle_stage(@stage.protocol)
      steps_count = new_stage.steps.count
      movestep = @stage.steps[1]
      params = { stage_id: new_stage.id }
      post "/steps/#{movestep.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
      @stage.steps.reload
      @stage.steps.count.should == 2
      @stage.steps.should be_contiguous_order_numbers
      new_stage.steps.reload
      new_stage.steps.count.should == 3
      new_stage.steps.should be_contiguous_order_numbers
    end
        
    it "step to non-existent stage not allowed" do
      params = { stage_id: 212 }
      post "/steps/#{@stage.steps.first.id}/move", params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      response.response_code.should == 422
    end
  end

  describe "check editable" do
    it "- not editable if experiment definition is not editable" do
      @experiment.experiment_definition = ExperimentDefinition.new(:experiment_type=>ExperimentDefinition::TYPE_DIAGNOSTIC)
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
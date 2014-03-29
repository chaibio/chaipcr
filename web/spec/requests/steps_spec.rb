require 'spec_helper'

describe "Steps API" do
  before(:each) do
    @stage = hold_stage(Protocol.create).reload
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
end
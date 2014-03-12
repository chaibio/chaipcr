require 'spec_helper'

describe Step do
    before(:each) do
      @stage = hold_stage(Protocol.create).reload
    end

    describe "#create" do
      it "step with default params match to previous step" do
        last_step = @stage.steps.last
        step = Step.new(:stage_id=>@stage.id)
        step.prev_id = last_step.id
        step.save
        step.reload.should be_same_step_as(last_step)
      end

      it "default name based on order_number+1" do
        last_step = @stage.steps.last
        step = Step.new(:stage_id=>@stage.id)
        step.prev_id = nil
        step.save
        step.reload.name.should eq("Step 1")
        last_step.reload.name.should eq("Step 2")
      end
    end

    describe "#destroy" do
      it "last step in last stage" do
        step = @stage.steps.first
        step.destroy
        step.destroyed_stage_id.should be_nil
        step.should exist_in_database
        @stage.should exist_in_database
      end
      
      it "last step not in last stage" do
        new_stage = hold_stage(@stage.protocol)
        step = @stage.steps.first
        step.destroy
        step.destroyed_stage_id.should eq(@stage.id)
        @stage.should_not exist_in_database
      end
    end
end
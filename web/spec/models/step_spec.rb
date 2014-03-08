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
      it "last step" do
        step = @stage.steps.first
        step.destroy
        @stage = Stage.find(@stage.id)
        @stage.should be_nil
      end
    end
end
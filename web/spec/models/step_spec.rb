require 'spec_helper'

describe Step do
    before(:each) do
      @stage = hold_stage(Protocol.create).reload
    end

    describe "#validate" do
      it "temperature" do
        step = @stage.steps.first
        step.temperature = 110
        step.save.should be_falsey
        expect(step.errors.size).to eq(1)
      end
    end
    
    describe "#create" do
      it "step with default params match to previous step" do
        last_step = @stage.steps.last
        step = Step.new(:stage_id=>@stage.id)
        step.prev_id = last_step.id
        step.save
        step.reload.should be_same_step_as(last_step)
      end

      it "check order number" do
        last_step = @stage.steps.last
        step = Step.new(:stage_id=>@stage.id)
        step.prev_id = nil
        step.save
        step.reload.order_number.should == 0
        last_step.reload.order_number.should == 1
      end
      
      it "not allowed after infinite hold step" do
        last_step = @stage.steps.last
        last_step.hold_time = 0
        last_step.save
        step = Step.new(:stage_id=>@stage.id)
        step.prev_id = last_step.id
        step.save.should be_falsey
        expect(step.errors.size).to eq(1)
      end
    end

    describe "#update" do
      it "not allowed to update to infinite hold if it is not the last step in the same stage" do
        @stage.steps << Step.new(:temperature=>95, :hold_time=>30, :order_number=>1)
        step = @stage.steps.first
        step.hold_time = 0
        step.save.should be_falsey
        expect(step.errors.size).to eq(1)
      end
      
      it "not allowed to update to infinite hold if it is not the last stage" do
        new_stage = hold_stage(@stage.protocol).reload
        step = new_stage.steps.last
        step.hold_time = 0
        step.save.should be_falsey
        expect(step.errors.size).to eq(1)
      end
      
      it "allowed to update to infinite hold if it is the last step in the last stage" do
        new_stage = hold_stage(@stage.protocol).reload
        step = @stage.steps.last
        step.hold_time = 0
        step.save.should be_truthy
      end
      
      it "not allow to collect data on infinite hold step" do
        step = Step.new(:stage_id=>@stage.id)
        step.hold_time = 0
        step.collect_data = true
        step.save.should be_falsey
      end
      
      it "not allow to collect data on pause step" do
        step = Step.new(:stage_id=>@stage.id)
        step.pause = true
        step.collect_data = true
        step.save.should be_falsey
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
require 'spec_helper'

describe Stage do
  before(:each) do
    @protocol = Protocol.create
  end
  
  describe "#create" do
    it "cycling stage with default name and default steps" do
      stage = cycle_stage(@protocol).reload
      stage.name.should eq("Cycling Stage")
      stage.steps.should have(2).items
    end
  
    it "hold stage with default name" do
      stage = hold_stage(@protocol).reload
      stage.name.should eq("Holding Stage")
    end
    
    it "first stage" do
      stage = cycle_stage(@protocol)
      new_stage = Stage.new(:stage_type=>Stage::TYPE_HOLD, :protocol_id=>@protocol.id)
      new_stage.prev_id = nil
      new_stage.save
      @protocol = Protocol.find(@protocol.id)
      @protocol.reload.stages[0].should eq(new_stage)
    end
    
    it "last stage" do
      stage = cycle_stage(@protocol)
      new_stage = Stage.new(:stage_type=>Stage::TYPE_HOLD, :protocol_id=>@protocol.id)
      new_stage.prev_id = stage.id
      new_stage.save
      @protocol.reload.stages.last.should eq(new_stage)
    end
    
    it "hold stage with default step match to previous stage" do
      stage = cycle_stage(@protocol)
      new_stage = Stage.new(:stage_type=>Stage::TYPE_HOLD, :protocol_id=>@protocol.id)
      new_stage.prev_id = stage.id
      new_stage.save
      new_stage = new_stage.reload
      new_stage.steps.should have(1).items
      new_stage.steps.first.should be_same_step_as(stage.steps.last)
    end
    
    it "not allowed after a stage with infinite step" do
      stage = hold_stage(@protocol).reload
      step = stage.steps.last
      step.hold_time = 0
      step.save
      new_stage = Stage.new(:stage_type=>Stage::TYPE_HOLD, :protocol_id=>@protocol.id)
      new_stage.prev_id = stage.id
      new_stage.save.should be_false
      new_stage.errors.should have(1).item
    end
  end
  
  describe "#destroy" do
    it "order number update" do
      stage2 = cycle_stage(@protocol)
      stage1 = cycle_stage(@protocol)
      stage0 = hold_stage(@protocol)
      stage1.reload.destroy
      stage0.reload.order_number.should eq(0)
      stage2.reload.order_number.should eq(1)
    end
    
    it "last stage cannot be destroyed" do
      stage = hold_stage(@protocol)
      stage.destroy
      @protocol.reload.stages.should have(1).items
      stage.errors.should have(1).item
    end
  end
end
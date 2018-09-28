require 'spec_helper'

describe Stage do
  before(:each) do
    @protocol = Protocol.create
  end
  
  describe "#create" do
    it "cycling stage with default name and default steps" do
      stage = cycle_stage(@protocol).reload
      stage.name.should eq("Cycling Stage")
      expect(stage.steps.size).to eq(2)
    end
    
    it "meltcurve stage with default name and default steps" do
      stage = meltcurve_stage(@protocol).reload
      stage.name.should eq("Melt Curve Stage")
      expect(stage.steps.size).to eq(3)
      stage.steps.last.ramp.should_not be_nil
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
      expect(new_stage.steps.size).to eq(1)
      new_stage.steps.first.should be_same_step_as(stage.steps.last)
    end
    
    it "not allowed after a stage with infinite step" do
      stage = hold_stage(@protocol).reload
      step = stage.steps.last
      step.hold_time = 0
      step.save
      new_stage = Stage.new(:stage_type=>Stage::TYPE_HOLD, :protocol_id=>@protocol.id)
      new_stage.prev_id = stage.id
      new_stage.save.should be_falsey
      expect(new_stage.errors.size).to eq(1)
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
      expect(@protocol.reload.stages.size).to eq(1)
      expect(stage.errors.size).to eq(1)
    end
  end
  
  describe "#autodelta" do
    it "not allowed for hold stage" do
     stage = hold_stage(@protocol)
     stage.auto_delta = 1
     stage.save
     expect(stage.errors.size).to eq(1)
    end
    
    it "start cycle cannot be greater than number of cycle" do
     stage = cycle_stage(@protocol)
     stage.auto_delta = 1
     stage.auto_delta_start_cycle = stage.num_cycles + 1
     stage.save
     expect(stage.errors.size).to eq(1)
    end
  end
end
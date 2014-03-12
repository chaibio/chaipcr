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
end
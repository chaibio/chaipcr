require 'spec_helper'

describe Protocol do
  before(:each) do
    @protocol = Protocol.create
  end
  
  describe "#validate" do
    it "lid temperature" do
      @protocol.lid_temperature = -2
      @protocol.save.should be_falsey
      expect(@protocol.errors.size).to eq(1)
    end
  end
end
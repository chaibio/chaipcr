class Ramp < ActiveRecord::Base
  include ProtocolHelper
  
  belongs_to :step, foreign_key: "next_step_id"
  
  MAX_RATE   = 100
  
  def max?
    rate >= MAX_RATE
  end
  
end
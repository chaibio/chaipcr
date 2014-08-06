class Ramp < ActiveRecord::Base
  include ProtocolHelper
  
  belongs_to :step, foreign_key: "next_step_id"
  
  MAX_RATE   = 0
  
  def max?
    rate == 0
  end
  
end
class Ramp < ActiveRecord::Base
  include ProtocolHelper
  
  belongs_to :step, foreign_key: "next_step_id"
  
  def max?
    rate >= 100
  end
  
end
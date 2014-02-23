class Ramp < ActiveRecord::Base
  include ProtocolHelper
  
  belongs_to :step
  
end
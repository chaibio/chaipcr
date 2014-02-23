class Protocol < ActiveRecord::Base
  belongs_to :experiment
  has_many :stages, -> {order("order_number")}, dependent: :destroy
  
  def copy
    new_protocol = Protocol.new(:lid_temperature=>lid_temperature)
    stages.each do |stage|
      new_protocol.stages << Stage.copy
    end
    new_protocol
  end
  
end
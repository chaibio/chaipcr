class Protocol < ActiveRecord::Base
  belongs_to :experiment_definition
  has_many :stages, -> {order("order_number")}, dependent: :destroy
  
  ACCESSIBLE_ATTRS = [:lid_temperature]
  
  def copy
    new_protocol = Protocol.new(:lid_temperature=>lid_temperature)
    stages.each do |stage|
      new_protocol.stages << stage.copy
    end
    new_protocol
  end
  
end
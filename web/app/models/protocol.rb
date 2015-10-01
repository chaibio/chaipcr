class Protocol < ActiveRecord::Base
  belongs_to :experiment_definition
  has_many :stages, -> {order("order_number").includes(:steps, :ramps)}
  
  ACCESSIBLE_ATTRS = [:lid_temperature]
  
  #delete stages after protocol destroy, so that stage.protocol will be nil
  after_destroy do |protocol|
    for stage in protocol.stages
      stage.destroy
    end
  end
  
  def copy
    new_protocol = Protocol.new(:lid_temperature=>lid_temperature)
    stages.each do |stage|
      new_protocol.stages << stage.copy
    end
    new_protocol
  end
  
end
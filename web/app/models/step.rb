class Step < Component
  validates_presence_of :name, :temperature, :hold_time
  validates_associated :parent
  
  before_create do |step|
    step.protocol_id = step.parent.protocol_id
  end
end
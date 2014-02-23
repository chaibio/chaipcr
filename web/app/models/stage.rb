class Stage < ActiveRecord::Base
  include ProtocolHelper
  
  belongs_to :protocol
  has_many :steps, -> {order("order_number")}, dependent: :destroy
  
  TYPE_HOLD   = 0
  TYPE_CYCLE  = 1
  
  before_create do |stage|
    if hold_stage? || numcycles.nil?
      self.numcycles = 1
    end
    if name.nil?
      if hold_stage?
        self.name = "Holding Stage"
      elsif cycle_stage?
        self.name = "Cycling Stage"
      else
        self.name = "Stage"
      end
    end
  end
  
  before_destroy do |stage|
    if stage.protocol.stages.count <= 1
      errors.add(:base, "At least one stage is required")
      return false
    end
  end
  
  def hold_stage?
    stage_type == TYPE_HOLD
  end
  
  def cycle_stage?
    stage_type == TYPE_CYCLE
  end
  
  def copy
    new_stage = ProtocolHelper::copy
    steps.each do |step|
      new_stage.steps << step.copy
    end
    new_stage
  end
  
  def siblings
    protocol.stages.where("id != ?", id)
  end
end


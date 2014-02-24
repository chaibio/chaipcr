class Stage < ActiveRecord::Base
  include ProtocolHelper
  
  belongs_to :protocol
  has_many :steps, -> {order("order_number")}, dependent: :destroy
  
  TYPE_HOLD   = "holding"
  TYPE_CYCLE  = "cycling"
  TYPE_MELTCURVE = "meltcurve"
  
  before_create do |stage|
    if hold_stage? || num_cycles.nil?
      self.num_cycles = 1
    end
  end
  
  before_destroy do |stage|
    if stage.protocol.stages.count <= 1
      errors.add(:base, "At least one stage is required")
      return false
    end
  end
  
  def name
    name_attr = read_attribute(:name)
    if name_attr.nil?
      if hold_stage?
        return "Holding Stage"
      elsif cycle_stage?
        return "Cycling Stage"
      elsif meltcurve_stage?
        return "Melt Curve Stage"
      end
    else
      return name_attr
    end
  end
  
  def hold_stage?
    stage_type == TYPE_HOLD
  end
  
  def cycle_stage?
    stage_type == TYPE_CYCLE
  end
  
  def meltcurve_stage?
    stage_type == TYPE_MELTCURVE
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


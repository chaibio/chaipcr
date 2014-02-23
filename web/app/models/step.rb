class Step < ActiveRecord::Base
  include ProtocolHelper
  
  belongs_to :stage
  has_one :ramp, dependent: :destroy
  
  before_create do |step|
    step.ramp = Ramp.new
  end
  
  after_save do |step|
    if step.stage_id_changed?
      children_count = Step.where("stage_id=?", step.stage_id_was).count
      if children_count == 0
        Stage.find(step.stage_id_was).destroy
      end
    end
  end
  
  after_destroy do |step|
    if step.stage.steps.length == 0
      step.stage.destroy
    end
  end
  
  def infinite_hold?
    hold_time == 0
  end
  
  def copy
    new_step = ProtocolHelper::copy
    new_step.ramp = ramp.copy
    new_step
  end
  
  def siblings
    stage.steps.where("id != ?", id)
  end
end
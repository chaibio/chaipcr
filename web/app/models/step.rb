class Step < ActiveRecord::Base
  include ProtocolHelper
  include ProtocolOrderHelper
  
  belongs_to :stage
  has_one :ramp, foreign_key: "next_step_id", dependent: :destroy
  
  ACCESSIBLE_ATTRS = [:name, :temperature, :hold_time, :collect_data, :delta_temperature, :delta_duration_s]
  
  attr_accessor :destroyed_stage_id
  
  validate :validate
  
  before_create do |step|
    if step.temperature.nil? || step.hold_time.nil?
      if !prev_id.nil?
        reference_step = Step.find_by_id(prev_id)
      end
      if reference_step.nil?
        reference_step = siblings.first
      end
      step.temperature = (reference_step)? reference_step.temperature : 95 if step.temperature.nil?
      step.hold_time = (reference_step)? reference_step.hold_time : 30 if step.hold_time.nil?
    end
    
    step.ramp = Ramp.new(:rate=>Ramp::MAX_RATE)
  end
  
  after_save do |step|
    if step.stage_id_changed? && !step.stage_id_was.nil?
      children_count = Step.where("stage_id=?", step.stage_id_was).count
      if children_count == 0
        Stage.find_by_id(step.stage_id_was).destroy
      end
    end
  end
  
  after_destroy do |step|
    if step.siblings.length == 0
      if step.stage.destroy
        step.destroyed_stage_id = step.stage.id
      else
        stage.errors[:base].each {|e| step.errors[:base] << e }
        raise ActiveRecord::Rollback and return false
      end
    end
  end
  
  def name
    name_attr = read_attribute(:name)
    if name_attr.nil?
      return "Step #{order_number+1}"
    else
      return name_attr
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
    if stage.nil?
      nil
    elsif !id.nil?
      stage.steps.where("id != ?", id)
    else
      stage.steps
    end
  end
  
  def last_step?
    !self.class.where("stage_id = ? and order_number > ?", stage_id, order_number).exists?
  end
  
  protected

  def validate
    if new_record?
      if !prev_id.nil?
        step = Step.find(prev_id)
        if step && step.infinite_hold?
          errors.add(:base, "Cannot add step after infinite hold step")
        end
      end
    else
      if hold_time_changed? && infinite_hold? #make sure it is the last step
          if !last_step? || !stage.last_stage?
            errors.add(:base, "Cannot update step in the middle to infinite hold")
          end
      end
    end
  end
end
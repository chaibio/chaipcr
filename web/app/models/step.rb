class Step < Component
  validates_presence_of :name, :temperature, :hold_time
  validates_associated :parent
  
  before_create do |step|
    step.experiment_id = step.parent.experiment_id
  end
  
  after_save do |component|
    if component.parent_id_changed? and component.parent_id_was
      children_count = Component.where("parent_id=?", component.parent_id_was).count
      if children_count == 0
        Component.find(component.parent_id_was).destroy
      end
    end
  end
  
  after_destroy do |step|
    if step.parent and !step.parent.master_cycle? and step.parent.children.length == 0
      step.parent.destroy
    end
  end
end
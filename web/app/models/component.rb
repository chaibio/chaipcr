class Component < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :parent, foreign_key: :parent_id, class_name: "Cycle"
  has_many :children, -> {order("order_number")}, foreign_key: :parent_id, class_name: "Component", dependent: :destroy do
    def from(child)
      where("order_number >= ?", child.order_number)
    end
    
    def exclude(child)
      if child and child.id
        where("id != ?", child.id)
      else
        where("")
      end
    end
  end

  attr_accessor :to_save
  
  before_save do |component|
    component.to_save = true
    if component.parent_id == nil
      component.parent_id = component.experiment.master_cycle_id
    end
    if component.update_order_required
      component.parent.update_children_order!(component, component.next_component_id)
    end
    component.to_save = nil
  end
  
  after_create do |component|
    if component.experiment.protocol_defined == false
      Experiment.where(:id=>component.experiment_id).update_all(:protocol_defined => true)
    end
  end
  
  before_destroy do |component|
    if component.parent && component.parent.children.count <= 1
      errors.add(:base, "At least one node is required")
      return false
    end
  end
  
  def copy!(experiment_id, parent_id)
    self.class.create(attribute_hash(["id", "parent_id", "experiment_id", "created_at", "updated_at"]).merge({:experiment_id=>experiment_id, :parent_id=>parent_id}))
  end
  
  def update_order!(order_number)
    if to_save == true
      self.order_number = order_number
    else
      self.class.where(:id => id).update_all(:order_number => order_number) if order_number != self.order_number
    end
  end
  
  def next_component_id=(id)
    @next_component_id = (!id.blank?)? id.to_i : nil
    @update_order_required = true
  end
  
  def next_component_id
    @next_component_id
  end
  
  def update_order_required
    @update_order_required 
  end
  
  private
  
  def attribute_hash (exclude_names)
    hash_values = {}
    attribute_names.each do |name|
      if !exclude_names.include?(name)
        hash_values[name]= read_attribute(name)
      end
    end
    hash_values
  end
end

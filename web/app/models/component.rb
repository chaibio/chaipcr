class Component < ActiveRecord::Base
  belongs_to :protocol
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
      component.parent_id = component.protocol.master_cycle_id
    end
    if component.update_order_required
      component.parent.update_children_order!(component, component.next_component_id)
    end
    component.to_save = nil
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
  
end

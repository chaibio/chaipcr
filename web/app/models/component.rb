class Component < ActiveRecord::Base
  belongs_to :protocol
  belongs_to :parent, foreign_key: :parent_id, class_name: "Cycle"
  has_many :children, -> {order("order_number")}, foreign_key: :parent_id, class_name: "Component", dependent: :destroy do
    def from(child)
      where("order_number >= ?", child.order_number)
    end
    
    def exclude(child)
      where("id != ?", child.id) if child
    end
  end

  after_save do |component|
    if component.update_order_required
      component.parent.update_children_order!(component, component.next_component)
    end
  end
  
  def update_order!(order_number)
    self.class.where(:id => id).update_all(:order_number => order_number)
  end
  
  def next_component=(id)
    if !id.blank?
      @next_component = Component.find(id)
    end
    @update_order_required = true
  end
  
  def next_component
    @next_component
  end
  
  def update_order_required
    @update_order_required 
  end
end

class Cycle < Component  
  validates_presence_of :name, :repeat
  validates_associated :protocol
  
  before_create do |cycle|
    if cycle.parent_id == nil
      cycle.parent_id = protocol.master_cycle_id
    end
  end
  
  def update_children_order!(cur_child, next_child)
    if next_child.blank?
      last_child = children.exclude(cur_child).last
      cur_child.update_order!(last_child.order_number+1) if last_child
    else
      cur_child.update_order!(next_child.order_number)
      children.exclude(cur_child).from(next_child).each do |child|
        child.update_order!(child.order_number+1)
      end
    end
  end
end
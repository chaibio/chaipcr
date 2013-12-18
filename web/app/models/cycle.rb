class Cycle < Component  
  validates_presence_of :name, :repeat
  
  def master_cycle?
    parent_id == nil
  end
    
  def update_children_order!(cur_child, next_child_id)
    if next_child_id.blank?
      last_child = children.exclude(cur_child).last
      cur_child.update_order!(last_child.order_number+1) if last_child
    else
      components = children.exclude(cur_child)
      next_child_index = components.index { |component| next_child_id == component.id }
      if next_child_index != nil
        next_child_order_number = components[next_child_index].order_number
        if (next_child_index == 0 && next_child_order_number >= 1)
          cur_child.update_order!(next_child_order_number-1)
        else
          prev_child_order_number = components[next_child_index-1].order_number if next_child_index > 0
          if !prev_child_order_number.nil? and prev_child_order_number < next_child_order_number-1
              cur_child.update_order!(next_child_order_number-1)
          else
              cur_child.update_order!(next_child_order_number)
              Component.where("id in (?)", (next_child_index..components.length-1).collect { |i| components[i].id }).update_all("order_number=order_number+1")
          end
        end
      end
    end
  end

end
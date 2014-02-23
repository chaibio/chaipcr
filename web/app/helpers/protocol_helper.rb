module ProtocolHelper
  def self.included(k)
    k.before_save :before_save if k.respond_to?(:before_save)
  end
  
  attr_accessor :to_save #???
  
  def before_save
    self.to_save = true
    if self.update_order_required
      self.update_siblings_order!
    end
    self.to_save = nil
  end
  
  def copy
    self.class.new(attribute_hash(["id", "protocol_id", "stage_id", "step_id", "created_at", "updated_at"]))
  end
  
  def next_id=(id)
    @next_id = (!id.blank?)? id.to_i : nil
    @update_order_required = true
  end
  
  def next_id
    @next_id
  end
  
  def update_order_required
    @update_order_required 
  end
  
  def update_order!(order_number)
    if to_save == true
      self.order_number = order_number
    else
      self.class.where(:id => id).update_all(:order_number => order_number) if order_number != self.order_number
    end
  end  
  
  def update_siblings_order!
    if !next_id.blank?
      @siblings = siblings.all
      next_sibling_index = @siblings.index { |sibling| next_id == sibling.id }
    end
    if next_sibling_index == nil
      last_sibling = (@siblings)? @siblings.last : siblings.last
      update_order!(last_sibling.order_number+1) if last_sibling
    else
      next_sibling_order_number = @siblings[next_sibling_index].order_number
      if (next_sibling_index == 0 && next_sibling_order_number >= 1)
          update_order!(next_sibling_order_number-1)
      else
          prev_sibling_order_number = @siblings[next_sibling_index-1].order_number if next_sibling_index > 0
          if !prev_sibling_order_number.nil? and prev_sibling_order_number < next_sibling_order_number-1
              update_order!(next_sibling_order_number-1)
          else
              update_order!(next_sibling_order_number)
              self.class.where("id in (?)", (next_sibling_index..@siblings.length-1).collect { |i| @siblings[i].id }).update_all("order_number=order_number+1")
          end
      end
    end
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
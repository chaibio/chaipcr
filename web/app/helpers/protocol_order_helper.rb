module ProtocolOrderHelper
  def self.included(k)
    k.before_save :before_save if k.respond_to?(:before_save)
    k.after_destroy :after_destroy if k.respond_to?(:after_destroy)
  end
  
  attr_accessor :to_save
  
  def before_save
    self.to_save = true
    if self.update_order_required
      self.update_siblings_order!
    end
    self.to_save = nil
  end
  
  def after_destroy
    next_siblings = siblings.where("order_number > ?", order_number).load
    self.class.where("id in (?)", next_siblings.map{|sibling| sibling.id}).update_all("order_number=order_number-1") if next_siblings.length > 0
  end
  
  def prev_id=(id)
    @prev_id = (!id.blank?)? id.to_i : nil
    @update_order_required = true
  end
  
  def prev_id
    @prev_id
  end
  
  def update_order_required
    new_record? || @update_order_required
  end
  
  def update_order!(order_number)
    if to_save == true
      self.order_number = order_number
    else
      self.class.where(:id => id).update_all(:order_number => order_number) if order_number != self.order_number
    end
  end  
  
  def update_siblings_order!
    @siblings = siblings.load
    if !prev_id.blank?
      prev_sibling_index = @siblings.index { |sibling| prev_id == sibling.id }
    end
    if prev_sibling_index == nil #first element
      self.class.where("id in (?)", @siblings.map{|sibling| sibling.id}).update_all("order_number=order_number+1") if @siblings.length > 0
    else
      prev_sibling_order_number = @siblings[prev_sibling_index].order_number
      update_order!(prev_sibling_order_number+1)
      self.class.where("id in (?)", (prev_sibling_index+1..@siblings.length-1).collect { |i| @siblings[i].id }).update_all("order_number=order_number+1") if prev_sibling_index+1 < @siblings.length
    end
  end
  
end
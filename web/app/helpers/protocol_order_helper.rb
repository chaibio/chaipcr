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
    if siblings != nil
      next_siblings = siblings.where("order_number > ?", order_number)
      next_siblings.order("order_number ASC").update_all("order_number=order_number-1")
    end
  end
  
  def prev_id=(id)
    @prev_id = (!id.blank?)? id.to_i : nil
    @update_order_required = true
  end
  
  def prev_id
    @prev_id
  end
  
  def order_number=(order_number)
    write_attribute("order_number", order_number)
    @update_order_required = false
  end
  
  def update_order_required
    (new_record? && @update_order_required != false) || @update_order_required
  end
  
  def update_order!(order_number)
    if to_save == true
      self.order_number = order_number
    else
      self.class.where(:id => id).update_all(:order_number => order_number) if order_number != self.order_number
    end
  end  
  
  def update_siblings_order!
    if siblings != nil
      @siblings = siblings.load
      if !prev_id.blank?
        prev_sibling_index = @siblings.index { |sibling| prev_id == sibling.id }
      end
      if prev_sibling_index == nil
        prev_sibling_index = -1
        new_order_number = 0
      else
        new_order_number = @siblings[prev_sibling_index].order_number+1
      end
      start_index = prev_sibling_index+1
      if @siblings[start_index]
        if new_sibling?
           ids = (start_index...@siblings.length).collect { |i| @siblings[i].id }
           self.class.where("id in (?)", ids).order("order_number DESC").update_all("order_number=order_number+1") if ids.length > 0
        elsif @siblings[start_index].order_number < self.order_number 
          #back to front, increment order_number from prev_sibling_index+1 to the element before the current one
          ids = []
          (start_index...@siblings.length).each { |i|
            if @siblings[i].order_number < self.order_number
              ids << @siblings[i].id
            else
              break
            end
          }
          if ids.length > 0
            ids << self.id
            self.class.where("id in (?)", ids).order("order_number DESC").update_all("order_number = CASE id WHEN #{self.id} THEN -1 ELSE order_number+1 END")
          end
        else
          #front to back, decrement order_number from the element after the current one to the prev_sibling_index
          ids = []
          (0...start_index).each { |i|
            if @siblings[i].order_number > self.order_number
              ids << @siblings[i].id
            end
          }
          if ids.length > 0
            new_order_number = @siblings[prev_sibling_index].order_number
            ids << self.id
            self.class.where("id in (?)", ids).order("order_number ASC").update_all("order_number = CASE id WHEN #{self.id} THEN -1 ELSE order_number-1 END")
          end
        end
      end
      update_order!(new_order_number)
    end
  end
  
end
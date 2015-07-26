module ProtocolHelper  
  def copy_helper
    self.class.new(attribute_hash(["id", "protocol_id", "stage_id", "step_id", "created_at", "updated_at"]))
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
class Experiment < ActiveRecord::Base
  belongs_to :protocol

  after_create do |experiment|
    if experiment.protocol_id == nil
      #create protocol
      protocol = Protocol.create
      self.class.where(:id=>experiment.id).update_all(:protocol_id=>protocol.id)
    end
  end
  
  def editable?
    return !running?
  end
end

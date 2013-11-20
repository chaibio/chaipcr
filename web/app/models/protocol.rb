class Protocol < ActiveRecord::Base
  has_many :all_components, class_name: "Component", dependent: :destroy
  has_one :master_cycle, -> {where parent_id: nil}, class_name: "Cycle"
  has_many :components, ->(protocol) {where(parent_id: protocol.master_cycle_id).includes(:children).order("order_number")}, class_name: "Component"
  
  scope :all_sorted, -> { order('run_at DESC') }
  
  after_create do |protocol|
    #create master cycle
    cycle = Cycle.create(:name=>"Master Cycle", :protocol_id=>protocol.id, :repeat=>1)
    self.class.where(:id=>protocol.id).update_all(:master_cycle_id=>cycle.id)
  end

end

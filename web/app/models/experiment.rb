class Experiment < ActiveRecord::Base
  has_many :all_components, class_name: "Component", dependent: :destroy
  has_one :master_cycle, -> {where parent_id: nil}, class_name: "Cycle"
  has_many :components, ->(experiment) {where(parent_id: experiment.master_cycle_id).includes(:children).order("order_number")}, class_name: "Component"
  has_many :steps, class_name: "Step"
  
  after_create do |experiment|
    if experiment.master_cycle_id == nil
      #create master cycle
      cycle = Cycle.create(:name=>"Master Cycle", :experiment_id=>experiment.id, :repeat=>1)
      self.class.where(:id=>experiment.id).update_all(:master_cycle_id=>cycle.id)
    end
  end
  
  def editable?
    return run_at.nil?
  end
  
  def runnable?
    !running && protocol_defined && (!qpcr || platessetup_defined)
  end
  
end

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
  
  def copy!(params)
    new_experiment = nil
    transaction do
      new_experiment = Experiment.create({:name=>(!params.blank?)? params[:name] : "Copy of #{name}", :qpcr=>qpcr, :protocol_defined=>protocol_defined, :platessetup_defined=>platessetup_defined})
      component_children_copy(new_experiment.id, new_experiment.master_cycle_id, components)
    end
    return new_experiment
  end
  
  def editable?
    return run_at.nil?
  end
  
  def runnable?
    !running && protocol_defined && (!qpcr || platessetup_defined)
  end
  
  private
  
  def component_children_copy(experiment_id, component_id, children)
    children.each do |child|
      new_child = child.copy!(experiment_id, component_id)
      component_children_copy(experiment_id, new_child.id, child.children)
    end
  end
end

class Experiment < ActiveRecord::Base
  has_one :protocol, dependent: :destroy
  
  after_create do |experiment|
    #create default protocol
    protocol = Protocol.new(:lid_temperature=>110, :experiment_id=>experiment.id)
    stage = Stage.new(:stage_type=>Stage::TYPE_HOLD, :order_number=>0)
    stage.steps << Step.new(:temperature=>95, :hold_time=>180)
    protocol.stages << stage
    stage = Stage.new(:stage_type=>Stage::TYPE_CYCLE, :order_number=>1, :num_cycles=>40)
    stage.steps << Step.new(:temperature=>95, :hold_time=>30, :order_number=>0)
    stage.steps << Step.new(:temperature=>60, :hold_time=>30, :order_number=>1)
    protocol.stages << stage
    stage = Stage.new(:stage_type=>Stage::TYPE_HOLD, :order_number=>2)
    stage.steps << Step.new(:temperature=>4, :hold_time=>0)
    protocol.stages << stage
    protocol.save
  end
  
  def copy(params)
    new_experiment = Experiment.new({:name=>(!params.blank?)? params[:name] : "Copy of #{name}", :qpcr=>qpcr})
    new_experiment.protocol = protocol.copy
    return new_experiment
  end
  
  def editable?
    return run_at.nil?
  end

  def ran?
    return !run_at.nil?
  end

end

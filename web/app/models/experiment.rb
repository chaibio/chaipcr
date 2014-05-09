class Experiment < ActiveRecord::Base
  has_one :protocol, dependent: :destroy
  has_many :temperature_logs, -> {order("elapsed_time")}, dependent: :destroy do
    def with_range(starttime, endtime, resolution)
      results = where("elapsed_time >= ?", starttime)
      if !endtime.blank?
        results = results.where("elapsed_time <= ?", endtime)
      end
      outputs = []
      counter = 0
      gap = (resolution.blank?)? 1 : resolution.to_i/1000
      results.each do |row|
        if counter == 0
          outputs << row
        end
        counter += 1
        if counter == gap
          counter = 0
        end
      end
      outputs
    end
  end

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
    
    #testdata
    TemperatureLog.testdata(experiment.id)
  end
  
  def copy(params)
    new_experiment = Experiment.new({:name=>(!params.blank?)? params[:name] : "Copy of #{name}", :qpcr=>qpcr})
    new_experiment.protocol = protocol.copy
    return new_experiment
  end
  
  def editable?
    return started_at.nil?
  end

  def ran?
    return !started_at.nil?
  end

end

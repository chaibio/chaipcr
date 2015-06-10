class Experiment < ActiveRecord::Base
  belongs_to :experiment_definition
  has_one :protocol, through: :experiment_definition
  
  has_many :fluorescence_data
  has_many :temperature_logs, -> {order("elapsed_time")} do
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
  
  before_create do |experiment|
    if experiment.calibration_id == nil
      experiment.calibration_id = Setting.calibration_id
    end
  end
  
  after_destroy do |experiment|
    if experiment_definition.experiment_type ==  ExperimentDefinition.TYPE_USER_DEFINED
      experiment_definition.destroy
    end
    
    TemperatureLog.delete_all(:experiment_id => experiment.id)
    TemperatureDebugLog.delete_all(:experiment_id => experiment.id)
    FluorescenceDatum.delete_all(:experiment_id => experiment.id)
    MeltCurveDatum.delete_all(:experiment_id => experiment.id)
  end
  
  def editable?
    return started_at.nil? && experiment_definition.editable?
  end

  def ran?
    return !started_at.nil?
  end
  
  def name
    experiment_definition.name
  end

end

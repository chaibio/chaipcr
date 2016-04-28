class Experiment < ActiveRecord::Base
  belongs_to :experiment_definition
  
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
  
#  validates :time_valid, inclusion: {in: [true, false]}
  
  before_create do |experiment|
#    experiment.time_valid = Setting.time_valid
  end
  
  before_destroy do |experiment|
    if experiment.running?
      errors.add(:base, "cannot delete experiment in the middle of running")
      return false;
    end
  end
  
  after_destroy do |experiment|
    if experiment_definition.experiment_type ==  ExperimentDefinition::TYPE_USER_DEFINED
      experiment_definition.destroy
    end
    
    TemperatureLog.delete_all(:experiment_id => experiment.id)
    TemperatureDebugLog.delete_all(:experiment_id => experiment.id)
    FluorescenceDatum.delete_all(:experiment_id => experiment.id)
    MeltCurveDatum.delete_all(:experiment_id => experiment.id)
  end
  
  def protocol
    experiment_definition.protocol
  end
  
  def editable?
    return started_at.nil? && experiment_definition.editable?
  end

  def ran?
    return !started_at.nil?
  end
  
  def running?
    return !started_at.nil? && completed_at.nil?
  end
  
  def name
    experiment_definition.name
  end

  def calibration_id
    if experiment_definition.guid == "thermal_consistency"
      return 1
    elsif experiment_definition.guid == "optical_cal" || experiment_definition.guid == "dual_channel_optical_cal"
      return self.id 
    else
      return read_attribute(:calibration_id)
    end
  end
  
end

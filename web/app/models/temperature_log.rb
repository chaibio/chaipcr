require "csv"

class TemperatureLog < ActiveRecord::Base
  belongs_to :experiment
  
  def self.as_csv(experiment_id)
    temperatures = TemperatureLog.order("temperature_logs.elapsed_time").where("temperature_logs.experiment_id=?", experiment_id)
    columns = ["temperature_logs.experiment_id", "temperature_logs.elapsed_time"] + column_names-["experiment_id, elapsed_time"]
    if Setting.debug
      temperatures = temperatures.joins("LEFT JOIN 'temperature_debug_logs' ON temperature_debug_logs.experiment_id = temperature_logs.experiment_id AND temperature_debug_logs.elapsed_time = temperature_logs.elapsed_time")
      columns = columns + TemperatureDebugLog.column_names-["experiment_id", "elapsed_time"]
    end
    CSV.generate do |csv|
      csv << columns
      temperatures.select(columns).all.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end
  
end
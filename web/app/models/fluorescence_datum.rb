class FluorescenceDatum < ActiveRecord::Base
  belongs_to :experiment
  
  def self.as_csv(experiment_id)
    query = self.where("fluorescence_data.experiment_id=?", experiment_id).joins("LEFT JOIN ramps ON ramps.id = fluorescence_data.ramp_id INNER JOIN steps ON steps.id = ramps.next_step_id or steps.id = fluorescence_data.step_id INNER JOIN stages ON stages.id = steps.stage_id")
    columns = column_names-["id", "experiment_id", "step_id", "ramp_id"]
    CSV.generate do |csv|
      csv << ["name", "stage_name"]+columns
      query.select("fluorescence_data.*, steps.name AS step_name, steps.order_number AS step_order_number, stages.name AS stage_name, stages.stage_type AS stage_type").each do |item|
        step = Step.new(:name=>item.step_name, :order_number=>item.step_order_number)
        stage = Stage.new(:name=>item.stage_name, :stage_type=>item.stage_type)
        csv << [(item.step_id.nil?)? "Ramp to #{step.name}" : step.name, stage.name] + item.attributes.values_at(*columns)
      end
    end
  end
  
end
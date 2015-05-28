class MeltCurveDatum < ActiveRecord::Base
  belongs_to :stage
  
  def self.as_csv(experiment_id)
    query = self.where("protocols.experiment_id=?", experiment_id).joins("INNER JOIN stages ON stages.id = melt_curve_data.stage_id INNER JOIN protocols ON protocols.id = stages.protocol_id")
    columns = column_names-["id", "stage_id"]
    CSV.generate do |csv|
      csv << ["stage_name"]+columns
      query.select("melt_curve_data.*, stages.name AS stage_name, stages.stage_type AS stage_type").each do |item|
        stage = Stage.new(:name=>item.stage_name, :stage_type=>item.stage_type)
        csv << [stage.name] + item.attributes.values_at(*columns)
      end
    end
  end
  
end
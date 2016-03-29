class SetLatestCalibrationExperimentId < ActiveRecord::Migration
  def change
    calibration_experiment = Experiment.where("experiment_definition_id=1 and completed_at is not NULL").order("id DESC").first
    if calibration_experiment && calibration_experiment.id != 1
      Setting.update_all(calibration_id: calibration_experiment.id)
    end
  end
end

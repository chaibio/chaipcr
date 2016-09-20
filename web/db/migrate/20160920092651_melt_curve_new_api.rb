class MeltCurveNewApi < ActiveRecord::Migration
  def change
    rename_column :cached_melt_curve_data, :fluorescence_data_text, :normalized_data_text
    rename_column :cached_melt_curve_data, :derivative_text, :derivative_data_text

    melt_curve_data = MeltCurveDatum.select("DISTINCT stage_id")
    melt_curve_data.each do |data|
      ramp = Ramp.collect_data(data.stage_id).first
      MeltCurveDatum.where(:stage_id=>data.stage_id).update_all(["ramp_id=?", ramp.id]) if ramp
    end
  end
end

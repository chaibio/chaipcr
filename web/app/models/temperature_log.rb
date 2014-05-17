class TemperatureLog < ActiveRecord::Base
  belongs_to :experiment
  
  def self.testdata(experiment_id)
    create(:experiment_id=>experiment_id, :elapsed_time=>0, :lid_temp => 50, :heat_block_zone_1_temp => 60, :heat_block_zone_2_temp=>60)
    create(:experiment_id=>experiment_id, :elapsed_time=>1000, :lid_temp => 60, :heat_block_zone_1_temp => 70, :heat_block_zone_2_temp=>70)
    create(:experiment_id=>experiment_id, :elapsed_time=>2000, :lid_temp => 40, :heat_block_zone_1_temp => 30, :heat_block_zone_2_temp=>30)
  end
end
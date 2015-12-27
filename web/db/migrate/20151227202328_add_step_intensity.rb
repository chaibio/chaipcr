class AddStepIntensity < ActiveRecord::Migration
  def change
    add_column :steps, :excitation_intensity, :integer, :limit=>3
    add_column :ramps, :excitation_intensity, :integer, :limit=>3
  end
end

class AddStepIntensity < ActiveRecord::Migration
  def change
    add_column :steps, :intensity, :integer, :limit=>3
  end
end

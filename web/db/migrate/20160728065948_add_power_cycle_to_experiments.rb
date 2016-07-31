class AddPowerCycleToExperiments < ActiveRecord::Migration
  def change
    remove_column :settings, :cached_version
    add_column :experiments, :power_cycles, :integer
  end
end

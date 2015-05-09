class AddAutoDelta < ActiveRecord::Migration
  def change
    add_column :stages, :auto_delta, :boolean, :default=>false
    add_column :stages, :auto_delta_start_cycle, :integer, :default=>1
    add_column :steps, :delta_temperature, :decimal, :precision=>4, :scale=>2, :default=>0
    add_column :steps, :delta_duration_s, :integer, :default=>0
  end
end

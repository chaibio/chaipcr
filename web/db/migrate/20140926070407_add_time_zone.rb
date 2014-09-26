class AddTimeZone < ActiveRecord::Migration
  def change
    add_column :settings, :id, :primary_key
    add_column :settings, :time_zone, :string
    add_column :steps, :collect_data, :boolean, :default=>false
    add_column :ramps, :collect_data, :boolean, :default=>false
  end
end

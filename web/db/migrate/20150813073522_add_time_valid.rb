class AddTimeValid < ActiveRecord::Migration
  def change
    add_column :experiments, :time_valid, :boolean, :null=>false, :default=>true
    remove_column :protocols, :created_at
    remove_column :protocols, :updated_at
    add_column :settings, :time_valid, :boolean, :default=>true
  end
end

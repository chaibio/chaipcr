class AnalyzeCache < ActiveRecord::Migration
  def change
    create_table :cached_analyze_data do |t| 
      t.integer :experiment_id
      t.text :analyze_result, :limit => 16777215
    end
    add_index "cached_analyze_data", "experiment_id", unique: true
    
    add_column :settings, :power_cycles, :integer, :default=>0
    add_column :settings, :cached_version, :string
  end
end

class AddExperimentDefinitions < ActiveRecord::Migration
  def change
    create_table :experiment_definitions do |t|
      t.string :name, :null=>false
      t.string :guid
      t.string :experiment_type, :null=>false
    end
    
    add_index :experiment_definitions, :guid
        
    remove_column :experiments, :name
    remove_column :experiments, :qpcr
    add_column :experiments, :experiment_definition_id, :integer
    add_column :experiments, :calibration_id, :integer

    rename_column :protocols, :experiment_id, :experiment_definition_id
    
    add_column :melt_curve_data, :experiment_id, :integer
    remove_index :melt_curve_data, [:stage_id, :well_num, :temperature]
    add_index :melt_curve_data, [:experiment_id, :stage_id, :well_num, :temperature], :name => 'melt_curve_data_index'
    
    add_column :settings, :calibration_id, :integer
  end
end

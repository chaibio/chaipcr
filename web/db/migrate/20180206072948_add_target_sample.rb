class AddTargetSample < ActiveRecord::Migration
  def change
    create_table :well_layouts do |t|
      t.integer :experiment_id
      t.integer :experiment_definition_id
      t.string :parent_type, :null=>false
      t.timestamps
    end
    
    create_table :targets do |t|
      t.integer :well_layout_id, :null=>false
      t.integer :channel, :null=>false
      t.string :name, :null=>false
    end
    
    create_table :samples do |t|
      t.integer :well_layout_id, :null=>false
      t.string :name, :null=>false
    end
    
    create_table :samples_wells do |t|
      t.integer :well_num, :null=>false
      t.integer :sample_id, :null=>false
    end
    
    create_table :targets_wells do |t|
      t.integer :well_num, :null=>false
      t.integer :target_id, :null=>false
      t.string  :well_type, :null=>false, :comment => "positive_control, no_template_control, standard, sample"
      t.decimal :concentration, :precision=>10, :scale=>2
    end
    
    add_index :samples_wells, :well_num
    add_index :targets_wells, :well_num
  end
end

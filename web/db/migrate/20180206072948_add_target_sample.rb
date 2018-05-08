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
      t.integer :well_layout_id, :null=>false
      t.integer :well_num, :null=>false
      t.integer :sample_id, :null=>false
    end
    
    create_table :targets_wells do |t|
      t.integer :well_layout_id, :null=>false
      t.integer :well_num, :null=>false
      t.integer :target_id, :null=>false
      t.string  :well_type, :comment => "positive_control, negative_control, standard, unknown"
      t.decimal :quantity_m, :precision=>9, :scale=>8
      t.integer :quantity_b
      t.boolean :omit, :default=>false
    end
    
    create_table :targets_curves do |t|
      t.integer :well_layout_id, :null=>false
      t.integer :target_id, :null=>false
      t.decimal :slope, :precision=>10, :scale=>2
      t.decimal :offset, :precision=>10, :scale=>2
      t.decimal :efficiency, :precision=>10, :scale=>2
      t.decimal :r2, :precision=>10, :scale=>2
    end
    
    add_index :samples_wells, [:well_layout_id, :well_num], name: "well_layout_sample"
    add_index :targets_wells, [:well_layout_id, :well_num], name: "well_layout_target"
    
  end
end

class AddWells < ActiveRecord::Migration
  def change
    create_table :wells do |t|
      t.integer :experiment_id, :null=>false
      t.integer :well_num, :null=>false
      t.string :well_type, :null=>false, :comment => "positive_control, no_template_control, standard, sample"
      t.string :sample_name
      t.text   :notes, limit: 16777215
      t.string :target1
      t.string :target2
    end
  end
end

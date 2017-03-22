class AddAmplificationOptions < ActiveRecord::Migration
  def change
    create_table :amplification_options do |t|
      t.integer :experiment_definition_id
      t.string  :cq_method
      t.integer :min_fluorescence
      t.integer :min_reliable_cycle
      t.integer :min_d1
      t.integer :min_d2
      t.integer :baseline_cycle_min
      t.integer :baseline_cycle_max
    end
  end
end

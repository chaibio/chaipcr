class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name
      t.boolean :qpcr, :default=>true
      t.integer :master_cycle_id
      t.datetime :run_at
      t.boolean :running, :default=>false
      t.boolean :protocol_defined, :default=>false
      t.boolean :platessetup_defined, :default=>false
      
      t.timestamps
    end
  end
end

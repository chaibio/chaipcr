class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name
      t.boolean :qpcr
      t.integer :protocol_id
      t.datetime :run_at
      t.boolean :running, :default=>false

      t.timestamps
    end
  end
end

class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :name
      t.datetime :run_at
      t.integer :master_cycle_id
      t.boolean :running, :default=>false
      t.timestamps
    end
  end
end

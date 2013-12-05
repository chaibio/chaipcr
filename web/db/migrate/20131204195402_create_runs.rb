class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.boolean :qpcr
      t.integer :protocol_id
      t.datetime :run_at
      t.boolean :running

      t.timestamps
    end
  end
end

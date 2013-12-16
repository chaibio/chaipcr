class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.integer :master_cycle_id
      t.timestamps
    end
  end
end

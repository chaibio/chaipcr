class AddSettings < ActiveRecord::Migration
  def change
    create_table :settings, id: false do |t|
      t.boolean :debug, :default => false
    end
  end
end

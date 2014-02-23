class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name
      t.boolean :qpcr, :default=>true
      t.datetime :run_at
      
      t.timestamps
    end
  end
end

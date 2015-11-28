class AddUpgradeTable < ActiveRecord::Migration
  def change
    create_table :upgrades do |t| 
      t.string :version, :null => false
      t.string :checksum, :null => false
      t.datetime :release_date, :null => false
      t.string :brief_description
      t.text :full_description
    end
    
  end
end

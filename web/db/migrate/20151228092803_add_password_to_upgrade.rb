class AddPasswordToUpgrade < ActiveRecord::Migration
  def change
    add_column :upgrades, :password, :string
  end
end

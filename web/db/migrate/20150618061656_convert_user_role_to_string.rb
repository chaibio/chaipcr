class ConvertUserRoleToString < ActiveRecord::Migration
  def change
#    change_column :users, :role, :string, :null=>false
    change_column_default(:users, :role, nil)
#    add_column :users, :name, :string, :null=>false
  end
end

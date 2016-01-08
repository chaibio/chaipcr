class AddDownloadedStatus < ActiveRecord::Migration
  def change
    add_column :upgrades, :downloaded, :boolean, :default => false
  end
end

class AddSoftwareReleaseVariant < ActiveRecord::Migration
  def change
     add_column :settings, :software_release_variant, :string, :default => "stable", :null=>false
  end
end

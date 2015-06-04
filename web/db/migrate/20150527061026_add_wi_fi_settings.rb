class AddWiFiSettings < ActiveRecord::Migration
  def change
    add_column :settings, :wifi_ssid, :string
    add_column :settings, :wifi_password, :string
    add_column :settings, :wifi_enabled, :boolean, :default=>true
  end
end

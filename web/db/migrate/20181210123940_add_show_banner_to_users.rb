class AddShowBannerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_banner, :boolean, :default=>true
  end
end

class AddChannels < ActiveRecord::Migration
  def change
    add_column :fluorescence_data, :channel, :integer, :null=>false, :default=>1, :limit=>1
    add_column :melt_curve_data, :channel, :integer, :null=>false, :default=>1, :limit=>1    
  end
end

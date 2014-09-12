class RemoveIdFromFluorescenceData < ActiveRecord::Migration
  def change
    remove_column :fluorescence_data, :id
  end
end

class AddStepInAmplificationData < ActiveRecord::Migration
  def change
    add_column :amplification_data, :sub_id, :integer
    add_column :amplification_data, :sub_type, :string
  end
end

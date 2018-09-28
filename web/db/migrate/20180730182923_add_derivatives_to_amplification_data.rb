class AddDerivativesToAmplificationData < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE amplification_data")
    add_column :amplification_data, :dr1_pred, :integer
    add_column :amplification_data, :dr2_pred, :integer
  end
end

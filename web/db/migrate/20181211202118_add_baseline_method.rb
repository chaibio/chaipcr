class AddBaselineMethod < ActiveRecord::Migration
  def change
    add_column :amplification_options, :baseline_method, :string
  end
end

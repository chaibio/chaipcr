class AddImportWellLayoutId < ActiveRecord::Migration
  def change
    add_column :experiments, :targets_well_layout_id, :integer
  end
end

class AddAnalyzeStatus < ActiveRecord::Migration
  def change
    add_column :experiments, :analyze_status, :string
  end
end

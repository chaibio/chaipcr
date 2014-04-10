class UpdateExperimentforrun < ActiveRecord::Migration
  def change
    rename_column :experiments, :run_at, :started_at
    add_column :experiments, :completed_at, :datetime
    add_column :experiments, :completion_status, :string
  end
end

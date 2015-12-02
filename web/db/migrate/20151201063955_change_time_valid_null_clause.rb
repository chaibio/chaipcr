class ChangeTimeValidNullClause < ActiveRecord::Migration
  def change
    change_column_null(:experiments, :time_valid, true)
  end
end

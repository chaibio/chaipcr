class AddPauseToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :pause, :boolean, :default=>false
  end
end

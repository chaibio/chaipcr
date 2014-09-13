class AddCompletionMessage < ActiveRecord::Migration
  def change
    add_column :experiments, :completion_message, :string
  end
end

class ChangeBriefDescriptionToText < ActiveRecord::Migration
  def change
    change_column :upgrades, :brief_description, :text
  end
end

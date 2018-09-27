class CreateWellLayout < ActiveRecord::Migration
  def change
    Experiment.all.each do |experiment|
      experiment.create_well_layout!
    end
  end
end

class AmplificationCurveCqPrecision < ActiveRecord::Migration
  def change
    change_column :amplification_curves, :ct, :decimal, :precision => 9, :scale => 6
    update "UPDATE ramps SET rate = 5 where rate = 0"
  end
end

class MigrateExistingPikaKits < ActiveRecord::Migration
  def change
    results = ActiveRecord::Base.connection.exec_query("select * from wells")
    results.each do |row|
      well_layout = WellLayout.for_experiment(row['experiment_id']).first
      if well_layout
        if !row['sample_name'].blank?
          sample = Sample.new(:name=>row['sample_name'])
          sample.well_layout_id = well_layout.id
          sample.save
          sample_well = SamplesWell.find_or_create(sample, well_layout.id, row['well_num'], row['notes'])
          sample_well.save
        end
        if !row['target1'].blank?
          target = Target.new(:name=>row['target1'], :channel=>1)
          target.well_layout_id = well_layout.id
          target.save
          target_well = TargetsWell.find_or_create(target, well_layout.id, row['well_num'])
          target_well.well_type = map_well_type(row['well_type'])
          target_well.save
        end
        if !row['target2'].blank?
          target = Target.new(:name=>row['target2'], :channel=>2)
          target.well_layout_id = well_layout.id
          target.save
          target_well = TargetsWell.find_or_create(target, well_layout.id, row['well_num'])
          target_well.well_type = map_well_type(row['well_type'])
          target_well.save
        end
      end
    end
    drop_table :wells
  end
  
  private
  
  def map_well_type(well_type)
    if well_type == "positive_control"
      return "positive_control"
    elsif well_type == "no_template_control"
      return "negative_control"
    else
      return "unknown"
    end
  end
end

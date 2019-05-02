class MigrateExistingPikaKits < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'wells'
    results = ActiveRecord::Base.connection.exec_query("select * from wells inner join experiments on experiments.id=wells.experiment_id inner join experiment_definitions on experiment_definitions.id=experiments.experiment_definition_id where experiment_definitions.guid='pika_4e_kit'")
    results.each do |row|
      well_layout = WellLayout.for_experiment(row['experiment_id']).first
      if well_layout
        if !row['sample_name'].blank?
          sample = Sample.where(:name=>row['sample_name'], :well_layout_id=>well_layout.id).first
          if sample == nil
            sample = Sample.new(:name=>row['sample_name'])
            sample.well_layout_id = well_layout.id
            sample.save
          end
          sample_well = SamplesWell.find_or_create(sample, well_layout.id, row['well_num'])
          sample_well.save
        
          if !row['target1'].blank?
            target = Target.where(:name=>row['target1'], :channel=>1, :well_layout_id=>well_layout.id).first
            if target == nil
              target = Target.new(:name=>row['target1'], :channel=>1)
              target.well_layout_id = well_layout.id
              target.save
            end
            target_well = TargetsWell.find_or_create(target, well_layout.id, row['well_num'])
            target_well.well_type = map_well_type(row['well_type'])
            target_well.save
          end
          
          target2_name = (row['target2'].blank?)? "IPC" : row['target2']
          target = Target.where(:name=>target2_name, :channel=>2, :well_layout_id=>well_layout.id).first
          if target == nil
            target = Target.new(:name=>target2_name, :channel=>2)
            target.well_layout_id = well_layout.id
            target.save
          end
          target_well = TargetsWell.find_or_create(target, well_layout.id, row['well_num'])
          target_well.well_type = map_well_type(row['well_type'])
          target_well.save
        end
      end
    end
    
    results = ActiveRecord::Base.connection.exec_query("select * from wells inner join experiments on experiments.id=wells.experiment_id inner join experiment_definitions on experiment_definitions.id=experiments.experiment_definition_id where experiment_definitions.guid is NULL or experiment_definitions.guid <> 'pika_4e_kit'")
    results.each do |row|
      well_layout = WellLayout.for_experiment(row['experiment_id']).first
      if well_layout
        if !row['sample_name'].blank?
          sample = Sample.where(:name=>row['sample_name'], :well_layout_id=>well_layout.id).first
          if sample == nil
            sample = Sample.new(:name=>row['sample_name'])
            sample.well_layout_id = well_layout.id
            sample.save
          end
          sample_well = SamplesWell.find_or_create(sample, well_layout.id, row['well_num'])
          sample_well.save
        end
      end
    end
    
    end
    
    #drop_table :wells
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

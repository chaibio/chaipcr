class ExperimentDefinition < ActiveRecord::Base
  has_one :protocol, dependent: :destroy

  TYPE_USER_DEFINED = "user"
  TYPE_DIAGONOSTIC  = "diagnostic"
  TYPE_CALIBRATION  = "calibration"
  
  DEFAULT_PROTOCOL = {lid_temperature:110, stages:[
                      {stage:{stage_type:"holding",steps:[{step:{name:"Initial Denaturing",temperature:95,hold_time:180}}]}},
                      {stage:{stage_type:"cycling",steps:[{step:{name:"Denature",temperature:95,hold_time:30}},{step:{name:"Anneal",temperature:60,hold_time:30,collect_data:true}}]}}]}
                      
  validates :name, presence: true
  
  before_create do |experiment_def|
    if experiment_def.protocol == nil
      experiment_def.protocol = create_protocol(DEFAULT_PROTOCOL)
    end
  end
  
  def copy(params)
    new_experiment_definition = ExperimentDefinition.new({:name=>(!params.blank?)? params[:name] : "Copy of #{name}", :experiment_type=>experiment_type})
    new_experiment_definition.protocol = protocol.copy
    return new_experiment_definition
  end
  
  def editable?
    experiment_type == TYPE_USER_DEFINED
  end

  def protocol_params=(params)
    self.protocol = create_protocol(params)
  end
  
  protected
  
  def create_protocol(params)
    return nil if params.blank?
    params = params.deep_dup.symbolize_keys
    protocol = Protocol.new(params.extract!(*Protocol::ACCESSIBLE_ATTRS))
    protocol.experiment_definition_id = self.id
    if !params[:stages].blank?
      params[:stages].each_with_index do |stage_params, stage_index|
        stage_params = stage_params.with_indifferent_access[:stage].symbolize_keys
        stage = Stage.new(stage_params.extract!(*Stage::ACCESSIBLE_ATTRS))
        stage.order_number = stage_index
        if !stage_params[:steps].blank?
          stage_params[:steps].each_with_index do |step_params, step_index|
            step_params = step_params.with_indifferent_access[:step].symbolize_keys
            step = Step.new(step_params.extract!(*Step::ACCESSIBLE_ATTRS))
            step.order_number = step_index
            step.ramp = Ramp.new(step_params[:ramp].symbolize_keys.extract!(*Ramp::ACCESSIBLE_ATTRS)) if !step_params[:ramp].nil?
            stage.steps << step
          end
        end
        protocol.stages << stage
      end
    end
    protocol
  end
end

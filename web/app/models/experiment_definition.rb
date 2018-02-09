#
# Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
# For more information visit http://www.chaibio.com
#
# Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class ExperimentDefinition < ActiveRecord::Base
  has_one :protocol, dependent: :destroy
  has_one :well_layout, ->{ where(:parent_type => ExperimentDefinition.name) }, dependent: :destroy
  has_one :amplification_option, dependent: :destroy
  
  TYPE_USER_DEFINED = "user"
  TYPE_DIAGNOSTIC  = "diagnostic"
  TYPE_CALIBRATION  = "calibration"
  TYPE_TESTKIT = "test_kit"
  
  DIAGNOSTICS_SINGLE_CHANNEL = ["thermal_performance_diagnostic", "thermal_consistency", "optical_test_single_channel"]
  DIAGNOSTICS_DUAL_CHANNEL = ["thermal_performance_diagnostic", "thermal_consistency", "optical_test_dual_channel"]
  
  DEFAULT_PROTOCOL = {lid_temperature:110, stages:[
                      {stage:{stage_type:"holding",steps:[{step:{name:"Initial Denaturing",temperature:95,hold_time:180}}]}},
                      {stage:{stage_type:"cycling",steps:[{step:{name:"Denature",temperature:95,hold_time:30}},{step:{name:"Anneal",temperature:60,hold_time:30,collect_data:true}}]}}]}
  
  before_create do |experiment_def|
    if experiment_def.protocol == nil
      experiment_def.protocol = create_protocol(DEFAULT_PROTOCOL)
    end
  end
  
  def self.diagnostic_guids
    (Device.dual_channel?)? DIAGNOSTICS_DUAL_CHANNEL : DIAGNOSTICS_SINGLE_CHANNEL
  end
      
  def copy
    new_experiment_definition = ExperimentDefinition.new({:experiment_type=>experiment_type})
    new_experiment_definition.protocol = protocol.copy
    return new_experiment_definition
  end
  
  def editable?
    experiment_type == TYPE_USER_DEFINED
  end

  def protocol_params=(params)
    self.protocol = create_protocol(params) if new_record?
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
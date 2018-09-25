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
module ParamsHelper
  
private
  def experiment_params
     params.require(:experiment).permit(:name, :notes)
  end
  
  def amplification_option_params
    params.require(:amplification_option).permit(*AmplificationOption::ACCESSIBLE_ATTRS)
  end
  
  def protocol_params
    params.require(:protocol).permit(*Protocol::ACCESSIBLE_ATTRS)
  end
  
  def stage_params
    params.require(:stage).permit(*Stage::ACCESSIBLE_ATTRS)
  end
  
  def step_params
    params.require(:step).permit(*Step::ACCESSIBLE_ATTRS)
  end
  
  def ramp_params
    params.require(:ramp).permit(*Ramp::ACCESSIBLE_ATTRS)
  end
  
  def sample_params
    params.require(:sample).permit(*Sample::ACCESSIBLE_ATTRS)
  end
  
  def target_params
    params.require(:target).permit(*Target::ACCESSIBLE_ATTRS)
  end
  
  def settings_params
    params.require(:settings).permit(:calibration_id, :time_zone, :debug)
  end
end
//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "experimentcontroller.h"
#include "lid.h"

#include "db/protocol.h"
#include "db/step.h"

Lid::Lid(Settings settings, const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold, double completionTurnOffTemp)
    :TemperatureController(settings), PWMControl(pwmPath, pwmPeriod)
{
    _startTempThreshold = startTempThreshold;
    _completionTurnOffTemp = completionTurnOffTemp;

    resetOutput();
}

Lid::~Lid()
{
    resetOutput();
}

Lid::Direction Lid::outputDirection() const
{
    return EHeat;
}

void Lid::setOutput(double value)
{
    setPWMDutyCycle(value);
}

void Lid::resetOutput()
{
    setOutput(0);
}

void Lid::processOutput()
{
    if (ExperimentController::getInstance()->machineState() == ExperimentController::LidHeatingMachineState)
    {
        if (currentTemperature() >= (targetTemperature() - _startTempThreshold))
            startThresholdReached();
    }
    else if (ExperimentController::getInstance()->machineState() == ExperimentController::CompleteMachineState)
    {
        Experiment experiment = ExperimentController::getInstance()->experiment();

        if (experiment.protocol() && experiment.protocol()->currentStep() && experiment.protocol()->currentStep()->temperature() <= _completionTurnOffTemp)
            setEnableMode(false);
    }
}

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
#include "controlhandler.h"

ControlHandler::ControlHandler(OperationType operation)
{
    _operation = operation;
}

void ControlHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt)
{
    switch (_operation)
    {
    case StartExperiment:
    {
        int experimentId = requestPt.get<int>("experiment_id");

        switch (ExperimentController::getInstance()->start(experimentId))
        {
        case ExperimentController::Started:
            break;

        case ExperimentController::ExperimentNotFound:
            setErrorString("Experiment not found");
            setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
            break;

        case ExperimentController::ExperimentUsed:
            setErrorString("Experiment have been used before");
            setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
            break;

        case ExperimentController::LidIsOpen:
            setErrorString("Lid is currently open");
            setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
            break;

        case ExperimentController::MachineRunning:
            setErrorString("Some experiment is running");
            setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
            break;

        case ExperimentController::OutOfStorageSpace:
            setErrorString("Storage limit reached - please delete some experiments");
            setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
            break;

        default:
            setErrorString("Unknown error");
            setStatus(Poco::Net::HTTPResponse::HTTP_INTERNAL_SERVER_ERROR);
            break;
        }

        break;
    }

    case ResumeExperiment:
    {
        if (ExperimentController::getInstance()->machineState() == ExperimentController::PausedMachineState)
            ExperimentController::getInstance()->resume();
        else
        {
            setErrorString("Machine is not paused");
            setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
        }

        break;
    }

    case StopExperiment:
        ExperimentController::getInstance()->stop();
        break;

    default:
        setErrorString("Unknown operation");
        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);

        break;
    }

    JsonHandler::processData(requestPt, responsePt);
}

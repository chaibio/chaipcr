#include "changeexperimenthandler.h"
#include "experimentcontroller.h"
#include "experiment.h"
#include "protocol.h"
#include "stage.h"

ChangeExperimentHandler::ChangeExperimentHandler(ChangeType type, int objectId)
{
    _type = type;
    _objectId = objectId;
}

void ChangeExperimentHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt)
{
    if (ExperimentController::getInstance()->machineState() == ExperimentController::IdleMachineState)
    {
        setErrorString("No experiment is running");
        setStatus(Poco::Net::HTTPResponse::HTTP_PRECONDITION_FAILED);

        JsonHandler::processData(requestPt, responsePt);

        return;
    }

    switch (_type)
    {
    case StageChange:
        changeStage(requestPt);
        break;

    default:
        setErrorString("Unknown operation");
        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);

        break;
    }

    JsonHandler::processData(requestPt, responsePt);
}

void ChangeExperimentHandler::changeStage(const boost::property_tree::ptree &requestPt)
{
    unsigned numCycles = requestPt.get<unsigned>("stage.num_cycles");

    if (ExperimentController::LockedExperiment experiment = ExperimentController::getInstance()->lockedExperiment())
    {
        for (Stage &stage: experiment->protocol()->stages())
        {
            if (stage.id() == _objectId)
            {
                stage.setNumCycles(numCycles);
                return;
            }
        }
    }

    setErrorString("Stage not found");
    setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
}

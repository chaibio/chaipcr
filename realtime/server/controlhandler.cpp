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
        int experimentId = requestPt.get<int>("experimentId");

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

        default:
            setErrorString("Unknown error");
            setStatus(Poco::Net::HTTPResponse::HTTP_INTERNAL_SERVER_ERROR);
            break;
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

    JSONHandler::processData(requestPt, responsePt);
}

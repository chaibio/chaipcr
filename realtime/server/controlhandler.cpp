#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"
#include "qpcrapplication.h"

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
        if (qpcrApp->machineState() == QPCRApplication::Idle)
        {
            int experimentId = requestPt.get<int>("experimentId");

            if (!qpcrApp->startExperiment(experimentId))
            {
                setErrorString("Experiment not found or have been used before");
                setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
            }
        }
        else
        {
            setErrorString("Machine not idle");
            setStatus(Poco::Net::HTTPResponse::HTTP_FORBIDDEN);
        }

        break;

    case StopExperiment:
        qpcrApp->stopExperiment();

        break;

    default:
        setErrorString("Unknown operation");
        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);

        break;
    }

    JSONHandler::processData(requestPt, responsePt);
}

#include "adcdebugreaderhandler.h"
#include "maincontrollers.h"

void ADCDebugReaderHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt) {
    ADCControllerInstance::getInstance()->startDebugReading(requestPt.get<std::size_t>("num_samples"));

    JsonHandler::processData(requestPt, responsePt);
}

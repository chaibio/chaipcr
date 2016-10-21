#ifndef ADCDEBUGREADERHANDLER_H
#define ADCDEBUGREADERHANDLER_H

#include "jsonhandler.h"

class ADCDebugReaderHandler : public JsonHandler
{
protected:
    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);
};

#endif // ADCDEBUGREADERHANDLER_H

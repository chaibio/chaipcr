#ifndef SETTINGSHANDLER_H
#define SETTINGSHANDLER_H

#include "jsonhandler.h"

class SettingsHandler : public JSONHandler
{
protected:
    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);
};

#endif // SETTINGSHANDLER_H

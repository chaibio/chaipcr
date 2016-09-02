#ifndef CHANGEEXPERIMENTHANDLER_H
#define CHANGEEXPERIMENTHANDLER_H

#include "jsonhandler.h"

class ChangeExperimentHandler : public JsonHandler
{
public:
    enum ChangeType
    {
        StageChange
    };

    ChangeExperimentHandler(ChangeType type, int objectId);

protected:
    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    void changeStage(const boost::property_tree::ptree &requestPt);

private:
    ChangeType _type;
    int _objectId;
};

#endif // CHANGEEXPERIMENTHANDLER_H

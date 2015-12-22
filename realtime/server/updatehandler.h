#ifndef UPDATEHANDLER_H
#define UPDATEHANDLER_H

#include "jsonhandler.h"

class UpdateHandler : public JsonHandler
{
public:
    enum OperationType
    {
        CheckUpdate,
        Update
    };

    UpdateHandler(OperationType type);

    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    OperationType _type;
};

#endif // UPDATEHANDLER_H

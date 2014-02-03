#ifndef TESTCONTROLHANDLER_H
#define TESTCONTROLHANDLER_H

#include "jsonhandler.h"

class TestControlHandler : public JSONHandler
{
protected:
    void createData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);
};

#endif // TESTCONTROLHANDLER_H

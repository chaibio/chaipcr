#ifndef TESTCONTROLHANDLER_H
#define TESTCONTROLHANDLER_H

#include "jsonhandler.h"

class TestControlHandler : public JSONHandler
{
protected:
    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    void processOptics(const boost::property_tree::ptree &requestPt);
    void processLid(const boost::property_tree::ptree &requestPt);
    void processHeatSink(const boost::property_tree::ptree &requestPt);
    void processHeatBlock(const boost::property_tree::ptree &requestPt);
};

#endif // TESTCONTROLHANDLER_H

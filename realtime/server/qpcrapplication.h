#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>
#include <vector>

#include "spi.h"
#include "gpio.h"

#include "maincontrollers.h"

using namespace std;

// Class QPCRServer
class QPCRApplication: public Poco::Util::ServerApplication
{
protected:
	//from ServerApplication
	void initialize(Application& self);
	int main(const vector<string>& args);

    //port accessors
    inline SPIPort& spiPort0() { return *spiPort0_; }
    inline GPIO& spiPort0DataInSensePin() { return *spiPort0DataInSensePin_; }

private:
    std::vector<boost::shared_ptr<IControl>> controlUnits;

    //ports
    SPIPort *spiPort0_;
    GPIO *spiPort0DataInSensePin_;

};

#endif

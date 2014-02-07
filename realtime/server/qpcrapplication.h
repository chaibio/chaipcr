#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>

// Class QPCRServer
class QPCRApplication: public Poco::Util::ServerApplication
{
protected:
	//from ServerApplication
    void initialize(Poco::Util::Application &self);
    int main(const std::vector<std::string> &args);

    //port accessors
    inline SPIPort& spiPort0() { return *spiPort0_; }
    inline GPIO& spiPort0DataInSensePin() { return *spiPort0DataInSensePin_; }

private:
    std::vector<std::shared_ptr<IControl>> controlUnits;

    //ports
    SPIPort *spiPort0_;
    GPIO *spiPort0DataInSensePin_;

};

#endif

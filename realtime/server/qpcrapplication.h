#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>

class IControl;
class HeatBlock;

// Class QPCRApplication
class QPCRApplication: public Poco::Util::ServerApplication
{
public:
    inline bool isWorking() const { return workState.load(); }
    inline void close() { workState = false; }

protected:
	//from ServerApplication
    void initialize(Poco::Util::Application &self);
    int main(const std::vector<std::string> &args);

private:
    std::vector<std::shared_ptr<IControl>> controlUnits;

    std::atomic<bool> workState;
};

#endif

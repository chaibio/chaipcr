#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>

class IControl;
class ExperimentController;

// Class QPCRApplication
class QPCRApplication: public Poco::Util::ServerApplication
{
public:
    ~QPCRApplication();

    inline static QPCRApplication* getInstance() { return _instance; }

    inline bool isWorking() const { return _workState.load(); }
    inline void close() { _workState = false; }

protected:
	//from ServerApplication
    void initialize(Poco::Util::Application &self);
    int main(const std::vector<std::string> &args);

private:
    static QPCRApplication *_instance;

    std::vector<std::shared_ptr<IControl>> _controlUnits;
    std::shared_ptr<ExperimentController> _experimentController;

    std::atomic<bool> _workState;
};

#define qpcrApp QPCRApplication::getInstance()

#endif

#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>

#include <signal.h>
#include <atomic>
#include <memory>

class IControl;
class IThreadControl;
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
    void initSignals();
    bool hasSignal() const;

private:
    static QPCRApplication *_instance;

    sigset_t _signalsSet;

    std::atomic<bool> _workState;

    std::vector<std::shared_ptr<IControl>> _controlUnits;
    std::vector<std::shared_ptr<IThreadControl>> _threadControlUnits;
    std::shared_ptr<ExperimentController> _experimentController;
};

#define qpcrApp QPCRApplication::getInstance()

#endif

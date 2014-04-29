#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>

class IControl;
class DBControl;
class Experiment;

// Class QPCRApplication
class QPCRApplication: public Poco::Util::ServerApplication
{
public:
    ~QPCRApplication();

    enum MachineState
    {
        Idle,
        LidHeating,
        Running,
        Complete
    };

    inline static QPCRApplication* getInstance() { return _instance; }

    inline bool isWorking() const { return _workState.load(); }
    inline void close() { _workState = false; }

    inline MachineState machineState() const { return _machineState; }

    inline Experiment* currentExperiment() const { return _experiment; }

    bool startExperiment(int experimentId);
    void stopExperiment();

protected:
	//from ServerApplication
    void initialize(Poco::Util::Application &self);
    int main(const std::vector<std::string> &args);

    void runExperiment();
    void completeExperiment();

private:
    static QPCRApplication *_instance;

    std::vector<std::shared_ptr<IControl>> _controlUnits;

    DBControl *_dbControl;
    Experiment *_experiment;

    std::atomic<bool> _workState;
    std::atomic<MachineState> _machineState;
};

#define qpcrApp QPCRApplication::getInstance()

#endif

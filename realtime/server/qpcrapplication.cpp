#include "pcrincludes.h"
#include "boostincludes.h"
#include "utilincludes.h"
#include "pocoincludes.h"
#include "controlincludes.h"
#include "dbincludes.h"

#include "qpcrrequesthandlerfactory.h"
#include "qpcrapplication.h"
#include "qpcrfactory.h"

using namespace std;
using namespace Poco::Net;
using namespace Poco::Util;

// Class QPCRApplication
QPCRApplication* QPCRApplication::_instance = nullptr;

QPCRApplication::~QPCRApplication() {
    stopExperiment();

    _instance = nullptr;

    delete _dbControl;
}

void QPCRApplication::initialize(Application&) {
    _instance = this;
    _machineState = Idle;
    _workState = false;
    _experiment = nullptr;

    _controlUnits = QPCRFactory::constructMachine();
    _dbControl = new DBControl();

    LidInstance::getInstance()->startThresholdReached.connect(boost::bind(&QPCRApplication::runExperiment, this));
    HeatBlockInstance::getInstance()->stagesCompleted.connect(boost::bind(&QPCRApplication::completeExperiment, this));
}

int QPCRApplication::main(const vector<string>&) {
	HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), new HTTPServerParams);
    server.start();

    //HeatSinkInstace::getInstance()->setMode(true);

    _workState = true;
    while (_workState) {
        for(auto controlUnit: _controlUnits)
            controlUnit->process();
    }

	server.stop();

	return Application::EXIT_OK;
}

bool QPCRApplication::startExperiment(int experimentId) {
    if (_machineState != Idle)
        return false;

    _experiment = _dbControl->getExperiment(experimentId);

    if (!_experiment || !_experiment->protocol() || _experiment->startedAt() != boost::posix_time::not_a_date_time) {
        delete _experiment;
        _experiment = nullptr;

        return false;
    }

    _machineState = LidHeating;

    _experiment->setStartedAt(boost::posix_time::microsec_clock::local_time());
    _dbControl->startExperiment(_experiment);

    LidInstance::getInstance()->setTargetTemperature(_experiment->protocol()->lidTemperature());
    LidInstance::getInstance()->setMode(true);

    return true;
}

void QPCRApplication::runExperiment() {
    _machineState = Running;

    HeatBlockInstance::getInstance()->setMode(true);
}

void QPCRApplication::completeExperiment() {
    _machineState = Complete;

    LidInstance::getInstance()->setMode(false);
    HeatBlockInstance::getInstance()->setMode(false);

    _experiment->setCompletionStatus(Experiment::Success);
    _experiment->setCompletedAt(boost::posix_time::microsec_clock::local_time());

    _dbControl->completeExperiment(_experiment);
}

void QPCRApplication::stopExperiment() {
    if (_machineState == Idle)
        return;

    LidInstance::getInstance()->setMode(false);
    HeatBlockInstance::getInstance()->setMode(false);

    if (_machineState != Complete) {
        _experiment->setCompletionStatus(Experiment::Aborted);
        _experiment->setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment);
    }

    _machineState = Idle;

    delete _experiment;
    _experiment = nullptr;
}

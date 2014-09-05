#include <Poco/Net/HTTPServer.h>

#include "pcrincludes.h"
#include "icontrol.h"
#include "experimentcontroller.h"
#include "qpcrrequesthandlerfactory.h"
#include "qpcrfactory.h"
#include "qpcrapplication.h"

using namespace std;
using namespace Poco::Net;
using namespace Poco::Util;

// Class QPCRApplication
QPCRApplication* QPCRApplication::_instance = nullptr;

QPCRApplication::~QPCRApplication() {
    _instance = nullptr;
}

void QPCRApplication::initialize(Application&) {
    _instance = this;
    _workState = false;

    QPCRFactory::constructMachine(_controlUnits, _threadControlUnits);
    _experimentController = ExperimentController::createInstance();

    initSignals();
}

int QPCRApplication::main(const vector<string>&) {
    HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), new HTTPServerParams);
    server.start();

    for (auto threadControlUnit: _threadControlUnits)
        threadControlUnit->start();

    _workState = true;
    while (_workState && !hasSignal()) {
        for(auto controlUnit: _controlUnits)
            controlUnit->process();
    }

    for (auto threadControlUnit: _threadControlUnits)
        threadControlUnit->stop();

    server.stopAll();

	return Application::EXIT_OK;
}

void QPCRApplication::initSignals() {
    sigemptyset(&_signalsSet);
    sigaddset(&_signalsSet, SIGQUIT);
    sigaddset(&_signalsSet, SIGINT);
    sigaddset(&_signalsSet, SIGTERM);
    sigprocmask(SIG_BLOCK, &_signalsSet, nullptr);
}

bool QPCRApplication::hasSignal() const {
    siginfo_t signalInfo;
    timespec time;

    time.tv_nsec = 0;
    time.tv_sec = 0;

    return sigtimedwait(&_signalsSet, &signalInfo, &time) > 0;
}

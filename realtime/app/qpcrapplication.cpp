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
    HTTPServerParams *params = new HTTPServerParams;
    HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), params);
    server.start();

    for (auto threadControlUnit: _threadControlUnits)
        threadControlUnit->start();

    _workState = true;
    while (!waitSignal() && _workState) {
        for(auto controlUnit: _controlUnits)
            controlUnit->process();
    }

    params->setKeepAlive(false);
    server.stopAll(true);

    for (auto threadControlUnit: _threadControlUnits)
        threadControlUnit->stop();

    _experimentController->stop();

	return Application::EXIT_OK;
}

void QPCRApplication::initSignals() {
    sigemptyset(&_signalsSet);
    sigaddset(&_signalsSet, SIGQUIT);
    sigaddset(&_signalsSet, SIGINT);
    sigaddset(&_signalsSet, SIGTERM);
    sigprocmask(SIG_BLOCK, &_signalsSet, nullptr);
}

bool QPCRApplication::waitSignal() const {
    siginfo_t signalInfo;
    timespec time;

    time.tv_nsec = kAppSignalInterval;
    time.tv_sec = 0;

    return sigtimedwait(&_signalsSet, &signalInfo, &time) > 0;
}

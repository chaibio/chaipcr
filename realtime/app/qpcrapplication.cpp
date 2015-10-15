#include <Poco/Net/HTTPServer.h>

#include <unistd.h>
#include <fcntl.h>

#include "pcrincludes.h"
#include "icontrol.h"
#include "experimentcontroller.h"
#include "qpcrrequesthandlerfactory.h"
#include "qpcrfactory.h"
#include "qpcrapplication.h"
#include "exceptionhandler.h"
#include "wirelessmanager.h"
#include "maincontrollers.h"
#include "timechecker.h"
#include "settings.h"

using namespace std;
using namespace Poco::Net;
using namespace Poco::Util;

class QPCRServerSocket : public ServerSocket
{
public:
    QPCRServerSocket(Poco::UInt16 port): ServerSocket(port)
    {
        fcntl(sockfd(), F_SETFD, FD_CLOEXEC);
    }
};

// Class QPCRApplication
void QPCRApplication::initialize(Application&) {
    _workState = false;

    try {
        QPCRFactory::constructMachine(_controlUnits, _threadControlUnits);
        _experimentController = ExperimentController::createInstance();
        _wirelessManager.reset(new WirelessManager("wlan0"));
        _timeChecker.reset(new TimeChecker());

        _timeChecker->timeStateChanged.connect([&](bool state)
        {
            Settings settings;
            settings.setTimeValid(state);

            _experimentController->updateSettings(settings);
        });

        initSignals();
    }
    catch (const std::exception &ex) {
        cout << "Initialize - exception occured: " << ex.what() << '\n';
        throw;
    }
    catch (...) {
        cout << "Initialize - unknown exception occured\n";
        throw;
    }
}

int QPCRApplication::main(const vector<string>&) {
    HTTPServerParams *params = new HTTPServerParams;
    QPCRServerSocket socket(kHttpServerPort);
    HTTPServer server(new QPCRRequestHandlerFactory, socket, params);

    try
    {
        server.start();

        for (auto threadControlUnit: _threadControlUnits)
            threadControlUnit->start();

        HeatSinkInstance::getInstance()->startADCReading();

        _workState = true;
        while (!waitSignal() && _workState) {
            for (auto controlUnit: _controlUnits)
                controlUnit->process();

            if (_exception)
                rethrow_exception(_exception);
        }

        params->setKeepAlive(false);
        server.stopAll(true);

        _experimentController->stop();

        for (auto threadControlUnit: _threadControlUnits)
            threadControlUnit->stop();

        return EXIT_OK;
    }
    catch (const exception &ex)
    {
        cout << "Exception occured: " << ex.what() << '\n';

        params->setKeepAlive(false);
        server.stopAll(true);

        _experimentController->stop(ex.what());

        for (auto threadControlUnit: _threadControlUnits)
            threadControlUnit->stop();

        return EXIT_SOFTWARE;
    }
    catch (...)
    {
        cout << "Unknown exception occured\n";

        params->setKeepAlive(false);
        server.stopAll(true);

        _experimentController->stop("Unknown exception occured");

        for (auto threadControlUnit: _threadControlUnits)
            threadControlUnit->stop();

        return EXIT_SOFTWARE;
    }
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

void QPCRApplication::stopExperiment(const string &message) {
    _experimentController->stop(message);
}

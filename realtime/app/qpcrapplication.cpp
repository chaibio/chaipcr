#include <Poco/Net/HTTPServer.h>

#include <unistd.h>
#include <fcntl.h>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include "pcrincludes.h"
#include "icontrol.h"
#include "experimentcontroller.h"
#include "qpcrrequesthandlerfactory.h"
#include "qpcrfactory.h"
#include "qpcrapplication.h"
#include "dbcontrol.h"
#include "exceptionhandler.h"
#include "wirelessmanager.h"
#include "maincontrollers.h"
#include "timechecker.h"
#include "settings.h"
#include "updatemanager.h"

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
void QPCRApplication::stopExperiment(const string &message) {
    _experimentController->stop(message);
}

int QPCRApplication::getUserId(const std::string &token) const
{
    _dbControl->getUserId(token);
}

void QPCRApplication::initialize(Application&) {
    _workState = false;

    try {
        readDeviceFile();
        readConfigurationFile();

        QPCRFactory::constructMachine(_controlUnits, _threadControlUnits);

        _dbControl.reset(new DBControl());
        _experimentController = ExperimentController::createInstance(_dbControl);
        _wirelessManager.reset(new WirelessManager("wlan0"));
        _timeChecker.reset(new TimeChecker());
        _updateManager.reset(new UpdateManager(_dbControl));

        _timeChecker->timeStateChanged.connect([&](bool state)
        {
            Settings settings;
            settings.setTimeValid(state);

            _dbControl->updateSettings(settings);
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
        _updateManager->startChecking();

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

void QPCRApplication::readDeviceFile()
{
    std::ifstream deviceFile(kDeviceFilePath);

    if (deviceFile.is_open())
    {
        boost::property_tree::ptree ptree;
        boost::property_tree::read_json(deviceFile, ptree);

        boost::optional<boost::property_tree::ptree&> array = ptree.get_child_optional("capabilities.optics.emission_channels");

        if (array)
            _settings.device.opticsChannels = array.get().size();
        else
            _settings.device.opticsChannels = 1;
    }
    else
        std::cout << "QPCRApplication::readDeviceFile - unable to read device file: " << std::strerror(errno) << '\n';
}

void QPCRApplication::readConfigurationFile()
{
    std::ifstream deviceFile(kConfigurationFilePath);

    if (deviceFile.is_open())
    {
        boost::property_tree::ptree ptree;
        boost::property_tree::read_json(deviceFile, ptree);

        _settings.configuration.version = ptree.get<std::string>("software.version");
    }
    else
        std::cout << "QPCRApplication::readConfigurationFile - unable to read configuration file: " << std::strerror(errno) << '\n';
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

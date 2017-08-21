//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <QApplication>
#include <QWSServer>
#include <QtGlobal>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include <cstdio>
#include <csignal>

#include "qpcrbrowser.h"
#include "logger.h"

QPCRBrowser *browser = 0;

void messageHandler(QtMsgType type, const char *msg);

void setupSignals();
void signalHandler(int signal);

void readConfig();

int main(int argc, char **argv)
{
    Logger::setup("QPCRBrowser", "/var/log/browser.log");
    APP_LOGGER << "--------------------------qPCR Browser Started--------------------------" << std::endl;

    qInstallMsgHandler(messageHandler);

    QApplication app(argc, argv);
#ifdef Q_WS_QWS
    QWSServer::setCursorVisible( false );
#endif

    browser = new QPCRBrowser;
    browser->showFullScreen();

    setupSignals();
    readConfig();

    return app.exec();
}

void messageHandler(QtMsgType type, const char *msg)
{
    APP_LOGGER << msg << std::endl;

    switch (type) {
    case QtWarningMsg:
        if (msg == QString("QObject::startTimer: QTimer cannot have a negative interval"))
            browser->reload();

        break;

    case QtFatalMsg:
        abort();

    default:
        break;
    }
}

void setupSignals()
{
    struct sigaction action;
    sigemptyset(&action.sa_mask);
    action.sa_flags = 0;
    action.sa_handler = signalHandler;

    sigaction(SIGUSR1, &action, nullptr);
}

void signalHandler(int signal)
{
    if (signal == SIGUSR1)
        readConfig();
}

void readConfig()
{
    try
    {
        boost::property_tree::ptree ptree;
        boost::property_tree::json_parser::read_json("/etc/chai/browser.conf", ptree);

        browser->toggleRequestLogger(ptree.get<bool>("requests_logger"));
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "readConfig - unable to read the config file: " << ex.what() << std::endl;
    }
}

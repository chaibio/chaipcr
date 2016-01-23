#include <QApplication>
#include <QWSServer>
#include <QtGlobal>
#include <cstdio>

#include "qpcrbrowser.h"

QPCRBrowser *browser = 0;

void messageHandler(QtMsgType type, const char *msg)
{
    fprintf(stderr, "%s\n", msg);

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

int main(int argc, char **argv)
{
    qInstallMsgHandler(messageHandler);

    QApplication app(argc, argv);
#ifdef Q_WS_QWS
    QWSServer::setCursorVisible( false );
#endif

    browser = new QPCRBrowser;
    browser->showFullScreen();

    return app.exec();
}

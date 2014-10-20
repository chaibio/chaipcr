#include <QApplication>
#include <QWSServer>
#include "qpcrbrowser.h"

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
#ifdef Q_WS_QWS
    QWSServer::setCursorVisible( false );
#endif
    QPCRBrowser *browser = new QPCRBrowser;

    browser->showFullScreen();

    return app.exec();
}

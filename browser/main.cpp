#include <QApplication>
#include "qpcrbrowser.h"

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    QPCRBrowser *browser = new QPCRBrowser;

    browser->showFullScreen();

    return app.exec();
}

#include "qpcrbrowser.h"
#include "qpcrpage.h"

#include <QtGui>

QPCRBrowser::QPCRBrowser()
{
    setPage(new QPCRPage(this));
    setCursor(Qt::BlankCursor);
    showSplashScreen();
    load(QPCR_ROOT_URL);
}

QPCRBrowser::~QPCRBrowser()
{

}

void QPCRBrowser::showSplashScreen()
{
    QFile file("./resources/splash.html");
    if (file.open(QFile::ReadOnly))
    {
        setHtml(file.readAll());

        file.close();
    }
    else
        setHtml("QPCRBrowser::showSplashScreen - unable to open splash.html");
}

void QPCRBrowser::closeEvent(QCloseEvent *event)
{
    event->ignore();
}

void QPCRBrowser::contextMenuEvent(QContextMenuEvent *event)
{
    event->ignore();
}

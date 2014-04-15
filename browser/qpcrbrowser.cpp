#include "qpcrbrowser.h"
#include "qpcrpage.h"

#include <QtGui>

QPCRBrowser::QPCRBrowser()
{
    setPage(new QPCRPage(this));
    setCursor(Qt::BlankCursor);
    load(QPCR_ROOT_URL);
}

QPCRBrowser::~QPCRBrowser()
{

}

void QPCRBrowser::closeEvent(QCloseEvent *event)
{
    event->ignore();
}

void QPCRBrowser::contextMenuEvent(QContextMenuEvent *event)
{
    event->ignore();
}

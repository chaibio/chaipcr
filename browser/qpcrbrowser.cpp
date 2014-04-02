#include "qpcrbrowser.h"

#include <QtGui>
#include <QtNetwork>
#include <QtWebKit>

#define QPCR_ROOT_URL QUrl("http://www.bash.im")

#define ROOT_RETRY_INTERVAL 2000
#define RETRY_INTERVAL 5000

QPCRBrowser::QPCRBrowser()
{
    repeatState = true;

    connect(page()->networkAccessManager(), SIGNAL(finished(QNetworkReply*)), SLOT(reply(QNetworkReply*)));
    connect(this, SIGNAL(loadFinished(bool)), SLOT(loaded(bool)));

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

void QPCRBrowser::reply(QNetworkReply *reply)
{
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError)
    {
        stop();

        if (reply->url() == QPCR_ROOT_URL)
        {
            setHtml(QString());

            QTimer::singleShot(ROOT_RETRY_INTERVAL, this, SLOT(reload()));
        }
        else
        {
            if (repeatState)
            {
                setHtml(QString("Error occured: %1 (%2)").arg(reply->error()).arg(reply->errorString()));

                QTimer::singleShot(RETRY_INTERVAL, this, SLOT(reload()));

                repeatState = false;
            }
            else
            {
                setHtml(QString());
                load(QPCR_ROOT_URL);
            }
        }
    }
}

void QPCRBrowser::loaded(bool isSuccess)
{
    if (isSuccess)
        repeatState = true;
}

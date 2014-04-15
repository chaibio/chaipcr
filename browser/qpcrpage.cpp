#include "qpcrpage.h"

#include <QtCore>
#include <QtWebKit>

#define VIEW ((QWebView*)view())

QPCRPage::QPCRPage(QObject *parent)
    :QWebPage(parent)
{
    repeatState = true;

    connect(networkAccessManager(), SIGNAL(finished(QNetworkReply*)), SLOT(reply(QNetworkReply*)));
    connect(this, SIGNAL(loadFinished(bool)), SLOT(loaded(bool)));
}

QPCRPage::~QPCRPage()
{

}

void QPCRPage::reply(QNetworkReply *reply)
{
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError)
    {
        VIEW->stop();

        if (reply->url() == QPCR_ROOT_URL)
        {
            VIEW->setHtml(QString());

            QTimer::singleShot(ROOT_RETRY_INTERVAL, this, SLOT(reload()));
        }
        else
        {
            if (repeatState)
            {
                VIEW->setHtml(QString("Error occured: %1 (%2)").arg(reply->error()).arg(reply->errorString()));

                QTimer::singleShot(RETRY_INTERVAL, view(), SLOT(reload()));

                repeatState = false;
            }
            else
            {
                VIEW->setHtml(QString());
                VIEW->load(QPCR_ROOT_URL);
            }
        }
    }
}

void QPCRPage::loaded(bool isSuccess)
{
    if (isSuccess)
        repeatState = true;
}

void QPCRPage::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceId)
{
    qDebug() << "Line:" << lineNumber << "SourceId:" << sourceId << "Message:" << message;
}

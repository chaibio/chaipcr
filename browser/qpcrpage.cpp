#include "qpcrpage.h"
#include "qpcrbrowser.h"

#include <QtCore>
#include <QtWebKit>

QPCRPage::QPCRPage(QPCRBrowser *browser)
    :QWebPage(browser)
{
    this->browser = browser;
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
        browser->stop();

        if (reply->url() == QPCR_ROOT_URL)
        {
            browser->showSplashScreen();

            QTimer::singleShot(ROOT_RETRY_INTERVAL, this, SLOT(reload()));
        }
        else
        {
            if (repeatState)
            {
                browser->setHtml(QString("Error occured: %1 (%2)").arg(reply->error()).arg(reply->errorString()));

                QTimer::singleShot(RETRY_INTERVAL, browser, SLOT(reload()));

                repeatState = false;
            }
            else
            {
                browser->setHtml(QString());
                browser->load(QPCR_ROOT_URL);
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

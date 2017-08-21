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

#include "qpcrpage.h"
#include "qpcrbrowser.h"
#include "qpcrnam.h"

#include <QtCore>
#include <QtWebKit>

QPCRPage::QPCRPage(QPCRBrowser *browser)
    :QWebPage(browser)
{
    this->browser = browser;
    repeatState = true;

    setNetworkAccessManager(new QPCRNam(this));

    connect(networkAccessManager(), SIGNAL(finished(QNetworkReply*)), SLOT(reply(QNetworkReply*)));
    connect(this, SIGNAL(loadFinished(bool)), SLOT(loaded(bool)));
}

QPCRPage::~QPCRPage()
{

}

void QPCRPage::toggleRequestLogger(bool state)
{
    static_cast<QPCRNam*>(networkAccessManager())->toggleRequestLogger(state);
}

void QPCRPage::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceId)
{
    qWarning() << "QPCRPage::javaScriptConsoleMessage - Line:" << lineNumber << "SourceId:" << sourceId << "Message:" << message;
}

void QPCRPage::reply(QNetworkReply *reply)
{
    reply->deleteLater();

    //temp disable reloading
    return;
    if (reply->error() != QNetworkReply::NoError)
    {
        qDebug() << "QPCRPage::reply::error -" << reply->error() << reply->errorString();

        browser->stop();

        if (reply->url() == QPCR_ROOT_URL)
        {
            browser->loadSplashScreen();

            QTimer::singleShot(ROOT_RETRY_INTERVAL, browser, SLOT(loadRoot()));
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
                browser->loadRoot();
        }
    }
}

void QPCRPage::loaded(bool isSuccess)
{
    if (isSuccess)
        repeatState = true;
}

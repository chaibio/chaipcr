#include "qpcrnam.h"
#include "logger.h"

#include <QNetworkRequest>
#include <QUrl>
#include <QString>

QPCRNam::QPCRNam(QObject *parent):
    QNetworkAccessManager(parent)
{
    _requestsLoggerState = false;
}

void QPCRNam::toggleRequestLogger(bool state)
{
    if (_requestsLoggerState != state)
    {
        _requestsLoggerState = state;

        if (_requestsLoggerState)
            APP_LOGGER << "QPCRNam::toggleRequestLogger - logger enabled" << std::endl;
        else
            APP_LOGGER << "QPCRNam::toggleRequestLogger - logger disabled" << std::endl;
    }
}

QNetworkReply* QPCRNam::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    if (_requestsLoggerState)
        APP_LOGGER << "QPCRNam::createRequest - New request: " << request.url().toString().toStdString() << std::endl;

    return QNetworkAccessManager::createRequest(op, request, outgoingData);
}

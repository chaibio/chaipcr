#ifndef QPCRNAM_H
#define QPCRNAM_H

#include <QNetworkAccessManager>

class QPCRNam : public QNetworkAccessManager
{Q_OBJECT
public:
    QPCRNam(QObject *parent = nullptr);

public slots:
    void toggleRequestLogger(bool state);

protected:
    QNetworkReply* createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData);

private:
    bool _requestsLoggerState;
};

#endif // QPCRNAM_H

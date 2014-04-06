#ifndef QPCRPAGE_H
#define QPCRPAGE_H

#include <QWebPage>

class QPCRPage : public QWebPage
{Q_OBJECT
public:
    QPCRPage(QObject *parent = 0);
    ~QPCRPage();

protected:
    void javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceId);

private slots:
    void reply(QNetworkReply *reply);
    void loaded(bool isSuccess);

private:
    bool repeatState;
};

#endif // QPCRPAGE_H

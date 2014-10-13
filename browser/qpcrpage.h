#ifndef QPCRPAGE_H
#define QPCRPAGE_H

#include <QWebPage>

class QPCRBrowser;

class QPCRPage : public QWebPage
{Q_OBJECT
public:
    QPCRPage(QPCRBrowser *browser);
    ~QPCRPage();

protected:
    void javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceId);

private slots:
    void reply(QNetworkReply *reply);
    void loaded(bool isSuccess);

private:
    QPCRBrowser *browser;

    bool repeatState;
};

#endif // QPCRPAGE_H

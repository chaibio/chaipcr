#ifndef QPCRBROWSER_H
#define QPCRBROWSER_H

#include <QWebView>

class QNetworkReply;

class QPCRBrowser : public QWebView
{Q_OBJECT
public:
    QPCRBrowser();
    ~QPCRBrowser();

protected:
    void closeEvent(QCloseEvent *event);
    void contextMenuEvent(QContextMenuEvent *event);

private slots:
    void reply(QNetworkReply *reply);
    void loaded(bool isSuccess);

private:
    bool repeatState;
};

#endif // QPCRBROWSER_H

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
};

#endif // QPCRBROWSER_H

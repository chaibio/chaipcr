#ifndef QPCRBROWSER_H
#define QPCRBROWSER_H

#include <QWebView>

class QPCRBrowser : public QWebView
{Q_OBJECT
public:
    QPCRBrowser();
    ~QPCRBrowser();

public slots:
    void loadSplashScreen();
    void loadRoot();

protected:
    void closeEvent(QCloseEvent *event);
    void contextMenuEvent(QContextMenuEvent *event);
};

#endif // QPCRBROWSER_H

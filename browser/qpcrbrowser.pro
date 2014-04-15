QT += network webkit

target.path = /home/root/tmp
INSTALLS += target

DEFINES += "QPCR_ROOT_URL=\"QUrl(\\\"http://www.bash.im\\\")\""

DEFINES += "ROOT_RETRY_INTERVAL=2000"
DEFINES += "RETRY_INTERVAL=5000"

SOURCES += \
    main.cpp \
    qpcrbrowser.cpp \
    qpcrpage.cpp

HEADERS += \
    qpcrbrowser.h \
    qpcrpage.h

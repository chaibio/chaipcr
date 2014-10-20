QT += network webkit

target.path = /root/tmp
INSTALLS += target

DEFINES += "QPCR_ROOT_URL=\"QUrl(\\\"http://localhost:8000/status\\\")\""

DEFINES += "ROOT_RETRY_INTERVAL=2000"
DEFINES += "RETRY_INTERVAL=5000"

SOURCES += \
    main.cpp \
    qpcrbrowser.cpp \
    qpcrpage.cpp

HEADERS += \
    qpcrbrowser.h \
    qpcrpage.h

QMAKE_CC = arm-unknown-linux-gnueabi-gcc
QMAKE_CXX = arm-unknown-linux-gnueabi-g++
QMAKE_LINK = arm-unknown-linux-gnueabi-g++

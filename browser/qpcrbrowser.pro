QT += network webkit

QMAKE_CXXFLAGS += -std=c++11

target.path = /root/tmp
INSTALLS += target

DEFINES += "QPCR_ROOT_URL=\"QUrl(\\\"http://localhost:8000/status\\\")\""

DEFINES += "ROOT_RETRY_INTERVAL=2000"
DEFINES += "RETRY_INTERVAL=5000"

INCLUDEPATH += $(BOOST_INCLUDE_PATH)
INCLUDEPATH += $$PWD/../realtime/libraries/include
LIBS += -L$$PWD/../realtime/libraries/lib -lPocoFoundation

SOURCES += \
    main.cpp \
    qpcrbrowser.cpp \
    qpcrpage.cpp \
    logger.cpp \
    qpcrnam.cpp

HEADERS += \
    qpcrbrowser.h \
    qpcrpage.h \
    logger.h \
    qpcrnam.h

QMAKE_CC = arm-unknown-linux-gnueabi-gcc
QMAKE_CXX = arm-unknown-linux-gnueabi-g++
QMAKE_LINK = arm-unknown-linux-gnueabi-g++

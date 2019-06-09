QT -= core gui network

OBJECTS_DIR = tmp
INCLUDEPATH += ./app/
INCLUDEPATH += ./control/
INCLUDEPATH += ./server/
INCLUDEPATH += ./util/
INCLUDEPATH += ./db/
INCLUDEPATH += ./test/
#INCLUDEPATH += /usr/include/
INCLUDEPATH += /usr/local/include/soci #for internal SOCI use
INCLUDEPATH += /usr/include/mysql
INCLUDEPATH += $(BOOST_INCLUDE_PATH)

LIBS += -L/usr/local/lib/

#Poco
LIBS += -lPocoFoundation
LIBS += -lPocoNet
LIBS += -lPocoUtil
LIBS += -lPocoXML
LIBS += -lPocoJSON

#Google Test and Mock
#LIBS += -lgtest
#LIBS += -lgmock

#SOCI
LIBS += -lsoci_core

LIBS += -lmysqlclient
LIBS += -lsoci_mysql

#Boost
LIBS += -lboost_system
LIBS += -lboost_chrono

LIBS += -ldl
LIBS += -lrt

#Ignore Boost warnings
QMAKE_CXXFLAGS += -Wno-unused-local-typedefs -Wno-unused-parameter -Wno-unused-but-set-parameter

DEFINES += BOOST_CB_DISABLE_DEBUG

QMAKE_CXXFLAGS += -std=c++11
QMAKE_CXXFLAGS -= -m64
QMAKE_LFLAGS += -rdynamic
QMAKE_LFLAGS -= -m64

unix:!unix_m {
    QMAKE_CC = arm-unknown-linux-gnueabi-gcc
    QMAKE_CXX = arm-unknown-linux-gnueabi-g++
    QMAKE_LINK = arm-unknown-linux-gnueabi-g++

    INCLUDEPATH += $(BOOST_INCLUDE_PATH)

    #QMAKE_CXXFLAGS += -Wno-unused-local-typedefs -Wno-unused-parameter

    target.path = /root/tmp/
    INSTALLS += target
}

unix_m: {
    QMAKE_CC = arm-unknown-linux-gnueabi-gcc
    QMAKE_CXX = arm-unknown-linux-gnueabi-g++
    QMAKE_LINK = arm-unknown-linux-gnueabi-g++

    QMAKE_CXXFLAGS += -mfloat-abi=hard

    INCLUDEPATH += /opt/local/include/

    target.path = /root/tmp
    INSTALLS += target
}

HEADERS += \
    app/pins.h \
    app/pcrincludes.h \
    app/exceptions.h \
    app/constants.h \
    app/chaistatus.h \
    control/thermistor.h \
    control/optics.h \
    control/ltc2444.h \
    control/ledcontroller.h \
    control/heatblock.h \
    control/adccontroller.h \
    util/spi.h \
    util/pwm.h \
    util/gpio.h \
    util/mux.h \
    server/qpcrrequesthandlerfactory.h \
    server/jsonhandler.h \
    server/testcontrolhandler.h \
    control/instance.h \
    control/icontrol.h \
    control/maincontrollers.h \
    app/qpcrapplication.h \
    util/utilincludes.h \
    control/controlincludes.h \
    util/pid.h \
    db/experiment.h \
    db/dbcontrol.h \
    db/protocol.h \
    db/stage.h \
    db/step.h \
    db/ramp.h \
    db/stagecomponent.h \
    db/dbincludes.h \
    test/servertest.h \
    db/sociincludes.h \
    test/dbtest.h \
    server/statushandler.h \
    control/adcconsumer.h \
    app/qpcrfactory.h \
    control/temperaturecontroller.h \
    server/controlhandler.h \
    control/bidirectionalpwmcontroller.h \
    control/lid.h \
    control/heatsink.h \
    app/experimentcontroller.h \
    db/temperaturelog.h \
    test/apptest.h \
    test/controltest.h \
    util/filters.h \
    db/settings.h \
    server/settingshandler.h \
    util/adcpin.h \
    util/exceptionhandler.h \
    control/test/adccontrollermock.h \
    util/lockfreesignal.h \
    util/instance.h \
    server/httpcodehandler.h \
    util/wirelessmanager.h \
    util/timechecker.h \
    util/networkinterfaces.h \
    server/networkmanagerhandler.h \
    db/upgrade.h \
    app/updatemanager.h \
    util/util.h \
    server/updatehandler.h \
    server/datahandler.h \
    server/updateuploadhandler.h \
    util/logger.h \
    util/timercallback.h \
    server/changeexperimenthandler.h \
    util/adcdebuglogger.h \
    util/adcdebuglogger.ipp \
    util/watchdog.h

SOURCES += \
    app/pins.cpp \
    app/main.cpp \
    app/exceptions.cpp \
    control/thermistor.cpp \
    control/optics.cpp \
    control/ltc2444.cpp \
    control/ledcontroller.cpp \
    control/heatblock.cpp \
    control/adccontroller.cpp \
    util/spi.cpp \
    util/pwm.cpp \
    util/gpio.cpp \
    util/mux.cpp \
    server/qpcrrequesthandlerfactory.cpp \
    server/jsonhandler.cpp \
    server/testcontrolhandler.cpp \
    app/qpcrapplication.cpp \
    util/pid.cpp \
    db/experiment.cpp \
    db/protocol.cpp \
    db/stage.cpp \
    db/step.cpp \
    db/ramp.cpp \
    db/stagecomponent.cpp \
    test/servertest.cpp \
    db/dbcontrol.cpp \
    test/dbtest.cpp \
    server/statushandler.cpp \
    app/qpcrfactory.cpp \
    server/controlhandler.cpp \
    control/temperaturecontroller.cpp \
    control/bidirectionalpwmcontroller.cpp \
    control/lid.cpp \
    control/heatsink.cpp \
    app/experimentcontroller.cpp \
    test/apptest.cpp \
    test/controltest.cpp \
    util/filters.cpp \
    server/settingshandler.cpp \
    util/adcpin.cpp \
    control/test/adccontrollermock.cpp \
    server/httpcodehandler.cpp \
    util/wirelessmanager.cpp \
    util/timechecker.cpp \
    util/networkinterfaces.cpp \
    server/networkmanagerhandler.cpp \
    app/updatemanager.cpp \
    util/util.cpp \
    server/updatehandler.cpp \
    server/datahandler.cpp \
    server/updateuploadhandler.cpp \
    util/logger.cpp \
    server/changeexperimenthandler.cpp \
    util/adcdebuglogger.cpp \
    util/watchdog.cpp

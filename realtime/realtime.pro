QT -= core gui network

INCLUDEPATH += ./app/
INCLUDEPATH += ./control/
INCLUDEPATH += ./server/
INCLUDEPATH += ./util/
INCLUDEPATH += ./db/
INCLUDEPATH += ./test/
INCLUDEPATH += ./libraries/include/
INCLUDEPATH += ./libraries/include/soci #for internal SOCI use
INCLUDEPATH += $(BOOST_INCLUDE_PATH)

LIBS += -L$$_PRO_FILE_PWD_/libraries/libhf/

#Poco
LIBS += -lPocoFoundation
LIBS += -lPocoNet
LIBS += -lPocoUtil
LIBS += -lPocoXML

#Google Test and Mock
LIBS += -lgtest
#LIBS += -lgmock

#SOCI
LIBS += -lsqlite3
LIBS += -lsoci_core
LIBS += -lsoci_sqlite3

unix:!unix_m {
    QMAKE_CC = arm-unknown-linux-gnueabi-gcc
    QMAKE_CXX = arm-unknown-linux-gnueabi-g++
    QMAKE_LINK = arm-unknown-linux-gnueabi-g++

    INCLUDEPATH += $(BOOST_INCLUDE_PATH)

    #QMAKE_CXXFLAGS += -Wno-unused-local-typedefs -Wno-unused-parameter

    target.path = /root/Dev/
    INSTALLS += target
}

unix_m: {
    QMAKE_CC = arm-unknown-linux-gnueabi-gcc
    QMAKE_CXX = arm-unknown-linux-gnueabi-g++
    QMAKE_LINK = arm-unknown-linux-gnueabi-g++

    QMAKE_CXXFLAGS += -mfloat-abi=soft -Wno-unused-local-typedefs

    INCLUDEPATH += /opt/local/include/

    target.path = /root/tmp
    INSTALLS += target
}

QMAKE_CXXFLAGS += -std=c++11

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
    control/fan.h \
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
    app/boostincludes.h \
    app/pocoincludes.h \
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
    server/httpstatushandler.h \
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
    db/debugtemperaturelog.h

SOURCES += \
    app/pins.cpp \
    app/main.cpp \
    app/exceptions.cpp \
    control/thermistor.cpp \
    control/optics.cpp \
    control/ltc2444.cpp \
    control/ledcontroller.cpp \
    control/heatblock.cpp \
    control/fan.cpp \
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
    server/httpstatushandler.cpp \
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
    control/adcconsumer.cpp \
    util/filters.cpp \
    db/settings.cpp \
    server/settingshandler.cpp

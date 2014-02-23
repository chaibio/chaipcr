QT -= core gui

INCLUDEPATH += ./app/
INCLUDEPATH += ./control/
INCLUDEPATH += ./server/
INCLUDEPATH += ./util/
INCLUDEPATH += ./libraries/include/
INCLUDEPATH += $(BOOST_INCLUDE_PATH)

LIBS += -L../realtime/libraries/lib/

#Poco
LIBS += -lPocoFoundation
LIBS += -lPocoNet
LIBS += -lPocoUtil
LIBS += -lPocoXML

#Google Test and Mock
LIBS += -lgtest
LIBS += -lgmock

unix:!unix_m {
    QMAKE_CC = arm-unknown-linux-gnueabi-gcc
    QMAKE_CXX = arm-unknown-linux-gnueabi-g++
    QMAKE_LINK = arm-unknown-linux-gnueabi-g++

    INCLUDEPATH += $(BOOST_INCLUDE_PATH)

    QMAKE_CXXFLAGS += -Wno-unused-local-typedefs -Wno-unused-parameter

    target.path = /home/root/tmp
    INSTALLS += target
}

unix_m: {
    QMAKE_CC = arm-unknown-linux-gnueabi-gcc
    QMAKE_CXX = arm-unknown-linux-gnueabi-g++
    QMAKE_LINK = arm-unknown-linux-gnueabi-g++

    QMAKE_CXXFLAGS += -mfloat-abi=soft -Wno-unused-local-typedefs

    INCLUDEPATH += /opt/local/include/
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
    control/heatsink.h \
    control/heatblockzone.h \
    control/heatblock.h \
    control/fan.h \
    control/adccontroller.h \
    util/spi.h \
    util/pwm.h \
    util/gpio.h \
    server/qpcrrequesthandlerfactory.h \
    server/jsonhandler.h \
    server/statushandler.h \
    server/testcontrolhandler.h \
    util/instance.h \
    control/icontrol.h \
    control/maincontrollers.h \
    server/qpcrapplication.h \
    app/boostincludes.h \
    app/pocoincludes.h \
    util/utilincludes.h \
    control/controlincludes.h \
    util/pid.h \
    control/lid.h

SOURCES += \
    app/pins.cpp \
    app/main.cpp \
    app/exceptions.cpp \
    control/thermistor.cpp \
    control/optics.cpp \
    control/ltc2444.cpp \
    control/ledcontroller.cpp \
    control/heatsink.cpp \
    control/heatblockzone.cpp \
    control/heatblock.cpp \
    control/fan.cpp \
    control/adccontroller.cpp \
    util/spi.cpp \
    util/pwm.cpp \
    util/gpio.cpp \
    server/qpcrrequesthandlerfactory.cpp \
    server/jsonhandler.cpp \
    server/statushandler.cpp \
    server/testcontrolhandler.cpp \
    server/qpcrapplication.cpp \
    util/pid.cpp \
    control/lid.cpp

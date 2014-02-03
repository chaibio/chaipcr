QT -= core gui

INCLUDEPATH += ./app/
INCLUDEPATH += ./control/
INCLUDEPATH += ./server/
INCLUDEPATH += ./util/
INCLUDEPATH += ./libraries/include/

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
    QMAKE_CC = arm-linux-gnueabi-gcc
    QMAKE_CXX = arm-linux-gnueabi-g++
    QMAKE_LINK = arm-linux-gnueabi-g++

    INCLUDEPATH += $(BOOST_INCLUDE_PATH)
}

unix_m: {
    QMAKE_CC = arm-unknown-linux-gnueabi-gcc
    QMAKE_CXX = arm-unknown-linux-gnueabi-g++
    QMAKE_LINK = arm-unknown-linux-gnueabi-g++

    QMAKE_CXXFLAGS += -mfloat-abi=hard -Wno-unused-local-typedefs

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
    control/qpcrcycler.h \
    control/optics.h \
    control/ltc2444.h \
    control/ledcontroller.h \
    control/heatsink.h \
    control/heatblockzone.h \
    control/heatblock.h \
    control/fan.h \
    control/adccontroller.h \
    server/StatusHandler.h \
    server/RequestHandlerFactory.h \
    server/qpcrserver.h \
    util/spi.h \
    util/pwm.h \
    util/gpio.h

SOURCES += \
    app/pins.cpp \
    app/main.cpp \
    app/exceptions.cpp \
    control/thermistor.cpp \
    control/qpcrcycler.cpp \
    control/optics.cpp \
    control/ltc2444.cpp \
    control/ledcontroller.cpp \
    control/heatsink.cpp \
    control/heatblockzone.cpp \
    control/heatblock.cpp \
    control/fan.cpp \
    control/adccontroller.cpp \
    server/StatusHandler.cpp \
    server/RequestHandlerFactory.cpp \
    server/qpcrserver.cpp \
    util/spi.cpp \
    util/pwm.cpp \
    util/gpio.cpp
